package io.github.ccch1mneyyy.dsh_app.runtime

import android.content.Context
import java.io.File

/** Installs only shipped bridge files; user bundles remain in their own profiles. */
object AppFormGuest {
    private const val DIR = "/opt/dsh-app/forms"
    const val PATCH = "$DIR/forms.patch.yml"
    private const val BASE_PATCH = "--patch /etc/dsh-app/dsh-web.patch.yml"

    fun writeFiles(context: Context, rootfs: File, profile: String?) {
        val form = profile?.takeIf { it.startsWith("app-local-") }?.removePrefix("app-")
        require(form == null || Regex("^local-[a-z0-9][a-z0-9-]{0,42}$").matches(form))
        val dir = File(rootfs, DIR.removePrefix("/"))
        check(dir.mkdirs() || dir.isDirectory)
        for (name in listOf("index.mjs", "store.mjs", "host.mjs", "mobile-core.mjs", "mobile.mjs", "releases.mjs", "recover.mjs")) {
            val bytes = context.assets.open("flutter_assets/assets/engine/forms/$name").use { it.readBytes() }
            val target = File(dir, name)
            val tmp = File(dir, "$name.tmp")
            tmp.writeBytes(bytes)
            check(tmp.renameTo(target))
        }
        File(dir, "forms.patch.yml").writeText("""
- insert:
    - id: dsh-wish-app-form
      name: $DIR/index.mjs
      config:
        form: ${form ?: "null"}
    - id: dsh-wish-mobile
      name: $DIR/mobile.mjs
      config:
        form: ${form ?: "null"}
""".trimStart())
        // Ship a public design/bridge reference; existing Creator sessions can read it on their next turn.
        copyAssets(context, "flutter_assets/assets/design-kit", File(rootfs, "opt/dsh-app/wish-design"))
        if (form != null) writeCreatorContext(context, rootfs, form)
        // This is a source template, not an accepted/installed work.
        val sample = File(rootfs, "root/.dsh/wish/workspaces/local-food-camera")
        if (!File(sample, "dsh-wish.app.json").exists()) {
            copyAssets(context, "flutter_assets/assets/forms/food-camera", sample)
        }
    }

    private fun writeCreatorContext(context: Context, rootfs: File, form: String) {
        val workspace = File(rootfs, "root/.dsh/wish/workspaces/$form")
        if (java.nio.file.Files.isSymbolicLink(workspace.toPath())) return
        check(workspace.mkdirs() || workspace.isDirectory)
        val file = File(workspace, "AGENTS.md")
        if (java.nio.file.Files.isSymbolicLink(file.toPath())) return
        val start = "<!-- dsh-wish:creator-context:start -->"
        val end = "<!-- dsh-wish:creator-context:end -->"
        val old = if (file.exists()) file.readText() else ""
        val begin = old.indexOf(start); val finish = old.indexOf(end)
        val retained = if (begin >= 0 && finish >= begin) old.removeRange(begin, finish + end.length).trimEnd() else old.trimEnd()
        val guide = context.assets.open("flutter_assets/assets/design-kit/CREATOR.md").bufferedReader().use { it.readText() }
        val phone = io.github.ccch1mneyyy.dsh_app.phone.PhoneControl.get(context).status()
        val a11y = phone["a11y"] as? Map<*, *>
        val grants = org.json.JSONObject().put("phone", io.github.ccch1mneyyy.dsh_app.wish.WishDeviceStore.granted(context, form, "phone"))
            .put("reminders", io.github.ccch1mneyyy.dsh_app.wish.WishDeviceStore.granted(context, form, "reminders"))
            .put("phoneEnabled", phone["enabled"] == true).put("phoneToolsMounted", phone["bridgeListening"] == true)
            .put("accessibilityConnected", a11y?.get("serviceConnected") == true).put("aiDirect", true)
        val next = retained + "\n\n" + start + "\n当前作品：$form。系统状态快照：$grants。运行时以 capabilities.status() 为准。\n\n" +
            "这是本作品的创作工作区。先检查已有源码；导入作品的实际源码通常在 ./package/，已安装的包名为 @local/$form。继续完善现有代码，不另建一个替代品，不更换作品 ID、数据命名空间或删除已有记录。此会话是本机的独立创作会话，不需要原作者的聊天记录。\n\n" + guide + "\n" + end + "\n"
        val tmp = File(workspace, ".wish-agents.tmp")
        tmp.writeText(next); check(tmp.renameTo(file))
    }

    private fun copyAssets(context: Context, source: String, target: File) {
        val children = context.assets.list(source).orEmpty()
        if (children.isEmpty()) {
            check(target.parentFile!!.mkdirs() || target.parentFile!!.isDirectory)
            context.assets.open(source).use { input -> target.outputStream().use { input.copyTo(it) } }
        } else {
            check(target.mkdirs() || target.isDirectory)
            for (name in children) copyAssets(context, "$source/$name", File(target, name))
        }
    }

    fun launchArg(arg: String, profile: String? = null, rootfs: File? = null): String? {
        if (!arg.contains("/usr/local/bin/dsh ") || !arg.contains(BASE_PATCH)) return null
        val patched = arg.replaceFirst(BASE_PATCH, "$BASE_PATCH --patch $PATCH")
        val work = profile?.takeIf { Regex("^app-local-[a-z0-9][a-z0-9-]{0,42}$").matches(it) }?.removePrefix("app-")
        if (work == null || rootfs == null || !File(rootfs, "root/.dsh/wish/work-versions/$work/pending.json").isFile) return patched
        // Recover interrupted source replacement before DSH imports the bundle.
        // Normal starts do not incur an extra Node process.
        val launch = "exec /usr/local/bin/dsh "
        check(patched.contains(launch)) { "release-recovery-launch-unavailable" }
        return patched.replaceFirst(launch, "/usr/local/bin/node $DIR/recover.mjs $work && $launch")
    }
}
