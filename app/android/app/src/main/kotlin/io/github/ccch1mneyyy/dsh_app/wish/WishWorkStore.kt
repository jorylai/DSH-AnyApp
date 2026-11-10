package io.github.ccch1mneyyy.dsh_app.wish

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/** Native metadata owns user overrides. Plugin descriptions cannot replace them. */
object WishWorkStore {
    private fun prefs(ctx: Context) = ctx.getSharedPreferences("wish-works-v1", Context.MODE_PRIVATE)
    private fun load(ctx: Context, work: String): JSONObject {
        WishDeviceStore.check(work)
        return JSONObject(prefs(ctx).getString(work, "{}") ?: "{}")
    }
    private fun view(data:JSONObject):Map<String,Any?> { val out=map(data).toMutableMap();if(data.has("customActions"))out["actions"]=out["customActions"];out.remove("customActions");return out }
    fun get(ctx: Context, work: String) = view(load(ctx, work))
    fun all(ctx: Context): Map<String, Any?> = prefs(ctx).all.keys.associateWith { get(ctx, it) }
    @Synchronized fun update(ctx: Context, work: String, args: Map<String, Any?>, user: Boolean): Map<String, Any?> {
        val data = load(ctx, work)
        val keys = if (user) listOf("customName", "icon", "actions") else listOf("title", "description", "actions", "icon")
        for (key in keys) if (args.containsKey(key)) {
            val value = args[key]
            when (key) {
                "customName", "title" -> {
                    require(value is String && value.length <= 80) { "invalid-work-name" }
                    data.put(key, value.trim())
                }
                "description" -> { require(value is String && value.length <= 500); data.put(key, value) }
                "icon" -> data.put(if(user)"icon" else "declaredIcon", icon(value))
                "actions" -> data.put(if(user) "customActions" else key, actions(value))
            }
        }
        check(prefs(ctx).edit().putString(work, data.toString()).commit()) { "metadata-save-failed" }
        return view(data)
    }
    fun remove(ctx: Context, work: String) { WishDeviceStore.check(work); WishDeviceStore.remove(ctx,work); WishNotifications.select(ctx,work,emptyList()); prefs(ctx).edit().remove(work).commit()
        val entry=ctx.getSharedPreferences("wish-entry-v1",0)
        if(entry.getString("selected",null)==work){entry.edit().remove("selected").commit();android.os.Handler(android.os.Looper.getMainLooper()).post{WishActionOverlay.hide()}}
        val shortcuts=ctx.getSystemService(android.content.pm.ShortcutManager::class.java)
        val ids=shortcuts.pinnedShortcuts.filter{it.id.startsWith("wish:$work:")}.map{it.id}
        if(ids.isNotEmpty())shortcuts.disableShortcuts(ids)
        ctx.getSharedPreferences("wish-widget-v1",0).edit().remove("snapshot:$work").commit() }
    fun icon(raw: Any?): JSONObject {
        require(raw is Map<*, *>) { "invalid-icon" }
        if(raw["bitmap"] is String){
            val text=raw["bitmap"] as String;require(text.length<=350000){"icon-too-large"}
            val bytes=android.util.Base64.decode(text,android.util.Base64.DEFAULT)
            require(bytes.size>8 && bytes[0]==0x89.toByte() && bytes[1]==0x50.toByte() && bytes[2]==0x4e.toByte() && bytes[3]==0x47.toByte()){"invalid-icon-image"}
            val options=android.graphics.BitmapFactory.Options().apply{inJustDecodeBounds=true};android.graphics.BitmapFactory.decodeByteArray(bytes,0,bytes.size,options)
            require(options.outWidth in 64..512 && options.outHeight==options.outWidth){"invalid-icon-size"}
            return JSONObject(bitmapMetadata(raw) + ("bitmap" to text))
        }
        if (raw["builtin"] is String) {
            require(raw["builtin"] in builtinIcons) { "invalid-icon-glyph" }
            return JSONObject(mapOf("builtin" to raw["builtin"]))
        }
        fun color(v: Any?) = (v as? String)?.takeIf { Regex("^#[0-9a-fA-F]{6}$").matches(it) } ?: error("invalid-icon-color")
        val paths = raw["paths"] as? List<*> ?: error("invalid-icon-paths")
        require(paths.size in 1..16)
        val safe = paths.map { item ->
            val p = item as? Map<*, *> ?: error("invalid-icon-path")
            val points = p["points"] as? List<*> ?: error("invalid-icon-points")
            require(points.size in 2..96)
            val xy = points.map { pair ->
                require(pair is List<*> && pair.size == 2)
                pair.map { val n = (it as? Number)?.toDouble() ?: error("invalid-coordinate"); require(n.isFinite() && n in 0.0..64.0); n }
            }
            val width = (p["width"] as? Number)?.toDouble() ?: 3.0
            require(width.isFinite() && width in 1.0..8.0)
            mapOf("points" to xy, "closed" to (p["closed"] == true), "filled" to (p["filled"] == true), "width" to width)
        }
        return JSONObject(mapOf("background" to color(raw["background"]), "color" to color(raw["color"]), "paths" to safe))
    }
    private val builtinIcons = setOf(
        "spark", "timer", "camera", "assistant", "trip", "cart", "note", "heart", "calendar", "plane",
        "book", "music", "weather", "fitness", "translate", "code", "receipt", "globe", "mail", "chart",
        "wallet", "home", "work", "search", "lightning", "leaf", "coffee", "restaurant", "pet", "gift",
        "photo", "video", "headphones", "mic", "language", "map", "compass", "train", "bike", "car",
        "walk", "bed", "health", "brain", "moon", "cloud", "rain", "water", "flower", "tree", "rocket",
        "robot", "game", "paint", "palette", "pencil", "folder", "document", "scan", "qr", "lock",
        "shield", "key", "link", "bookmark", "star", "bell", "clock", "target", "check", "list",
        "calculator", "savings", "diamond", "sunrise", "boat", "school",
    )

    /** Bitmap is authoritative; these bounded fields let the editor restore its selected style. */
    internal fun bitmapMetadata(raw: Map<*, *>): Map<String, Any> {
        val kind = raw["kind"]?.let {
            require(it is String && it in setOf("glyph", "builtin", "emoji", "vector")) { "invalid-icon-kind" }
            it
        }
        val emoji = raw["emoji"]?.let {
            require(it is String && validEmojiSequence(it)) { "invalid-icon-emoji" }
            it
        }
        require(kind != "emoji" || emoji != null) { "invalid-icon-emoji" }
        require(emoji == null || kind == "emoji") { "invalid-icon-kind" }
        val version = raw["styleVersion"]?.let {
            require(it is Number && it.toDouble().isFinite() && it.toDouble() in 1.0..2.0 && it.toDouble() % 1.0 == 0.0) { "invalid-icon-version" }
            it.toInt()
        } ?: 1
        val fields = mutableMapOf<String, Any>(
            "builtin" to ((raw["builtin"] as? String)?.takeIf { it in builtinIcons } ?: "spark"),
            "styleVersion" to version,
            "palette" to ((raw["palette"] as? String)?.takeIf { it in setOf("indigo", "violet", "mint", "amber", "rose") } ?: "indigo"),
            "variant" to ((raw["variant"] as? Number)?.toInt()?.coerceIn(0, 2) ?: 0),
        )
        if (kind != null) fields["kind"] = kind
        if (emoji != null) fields["emoji"] = emoji
        return fields
    }

    /** Structural guard only. Flutter checks membership in the bundled Unicode emoji catalog. */
    internal fun validEmojiSequence(value: String): Boolean {
        if (value.length > 128) return false
        val points = value.codePoints().toArray()
        if (points.isEmpty() || points.size > 32) return false
        var i = 0
        fun selector() { if (i < points.size && points[i] == 0xfe0f) i++ }
        fun component(): Boolean {
            if (i >= points.size) return false
            val base = points[i++]
            if (base in 0x1f1e6..0x1f1ff) {
                return i < points.size && points[i++] in 0x1f1e6..0x1f1ff
            }
            if (base == 0x23 || base == 0x2a || base in 0x30..0x39) {
                selector()
                return i < points.size && points[i++] == 0x20e3
            }
            val allowedBase = base in 0x1f000..0x1faff || base in 0x2600..0x27bf ||
                base in 0x2194..0x2199 || base in 0x21a9..0x21aa || base in 0x231a..0x231b ||
                base in 0x23e9..0x23f3 || base in 0x23f8..0x23fa || base in 0x25aa..0x25ab ||
                base in 0x25fb..0x25fe || base in 0x2b05..0x2b07 || base in 0x2b1b..0x2b1c ||
                base in setOf(0xa9, 0xae, 0x203c, 0x2049, 0x2122, 0x2139, 0x2328, 0x23cf,
                    0x24c2, 0x25b6, 0x25c0, 0x2b50, 0x2b55, 0x3030, 0x303d, 0x3297, 0x3299)
            if (!allowedBase) return false
            selector()
            if (i < points.size && points[i] in 0x1f3fb..0x1f3ff) i++
            if (base == 0x1f3f4 && i < points.size && points[i] in 0xe0061..0xe007a) {
                while (i < points.size && points[i] in 0xe0061..0xe007a) i++
                if (i >= points.size || points[i++] != 0xe007f) return false
            }
            return true
        }
        if (!component()) return false
        while (i < points.size) {
            if (points[i++] != 0x200d || !component()) return false
        }
        return true
    }

    private fun actions(raw: Any?): JSONArray {
        require(raw is List<*> && raw.size <= 8) { "invalid-work-actions" }
        val ids = mutableSetOf<String>()
        return JSONArray(raw.map { item ->
            require(item is Map<*, *>)
            val id = item["id"] as? String ?: error("invalid-action-id")
            require(Regex("^[a-z][a-z0-9-]{0,39}$").matches(id) && ids.add(id))
            val label = item["label"] as? String ?: error("invalid-action-label")
            require(label.isNotBlank() && label.length <= 40)
            val kind = item["kind"] as? String ?: "agent"
            require(kind in setOf("agent", "host", "capability"))
            val prompt = item["prompt"] as? String ?: ""
            require(prompt.length <= 10000 && (kind != "agent" || prompt.isNotBlank()))
            val apps = item["apps"] as? List<*> ?: emptyList<Any>()
            require(apps.size <= 16 && apps.all { it is String && Regex("^[a-zA-Z0-9_.]{3,160}$").matches(it) })
            val target = item["target"] as? String ?: ""
            require(target.length <= 120)
            val params = item["params"] as? Map<*, *> ?: emptyMap<Any, Any>()
            require(JSONObject(params).toString().length <= 6000)
            mapOf("id" to id, "label" to label, "kind" to kind, "prompt" to prompt, "apps" to apps, "target" to target, "params" to params)
        })
    }
    fun map(value: JSONObject): Map<String, Any?> = value.keys().asSequence().associateWith { unwrap(value.get(it)) }
    private fun unwrap(v: Any?): Any? = when (v) { JSONObject.NULL -> null; is JSONObject -> map(v); is JSONArray -> (0 until v.length()).map { unwrap(v.get(it)) }; else -> v }
}
