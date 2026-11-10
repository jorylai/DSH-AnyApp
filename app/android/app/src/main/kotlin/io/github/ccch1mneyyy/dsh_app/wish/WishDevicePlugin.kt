package io.github.ccch1mneyyy.dsh_app.wish

import android.content.*
import android.net.Uri
import android.os.*
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.*
import io.flutter.plugin.common.*
import io.github.ccch1mneyyy.dsh_app.phone.*
import java.util.concurrent.Executors

class WishDevicePlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler, PluginRegistry.NewIntentListener, PluginRegistry.ActivityResultListener {
    private lateinit var ctx: Context
    private lateinit var channel: MethodChannel
    private var activity: ActivityPluginBinding? = null
    private val io = Executors.newSingleThreadExecutor()
    private val phoneIo = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private lateinit var life: WishLife
    private var opened: String? = null
    private var openedDestination:String?=null
    private var pendingAction: Map<String, Any?>? = null
    private var actionReady = false
    private var overlayVisibility:((Boolean,String?)->Unit)?=null
    private var overlayDispatch:((Map<String,Any?>)->Unit)?=null
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        ctx = binding.applicationContext
        val defaults=ctx.getSharedPreferences("wish-defaults-v1",0)
        if(!defaults.getBoolean("full-mode-v1",false)) {
            PhoneControl.get(ctx).setPolicies(mapOf("confirmMode" to "always"))
            check(defaults.edit().putBoolean("full-mode-v1",true).commit())
        }
        life = WishLife(ctx) { activity?.activity }
        overlayDispatch = { action -> dispatchAction(action) }
        channel = MethodChannel(binding.binaryMessenger, "dsh/wish/device"); channel.setMethodCallHandler(this)
    }
    private fun dispatchAction(action: Map<String, Any?>) {
        if (!actionReady) { pendingAction = action; return }
        (action["work"] as? String)?.let{WishActionOverlay.starting(it,true)}
        channel.invokeMethod("action", action, object : MethodChannel.Result {
            override fun success(value: Any?) { (action["work"] as? String)?.let{WishActionOverlay.starting(it,false)} }
            override fun error(code: String, message: String?, details: Any?) { (action["work"] as? String)?.let{WishActionOverlay.starting(it,false)};actionFailure() }
            override fun notImplemented() { (action["work"] as? String)?.let{WishActionOverlay.starting(it,false)};actionFailure() }
        })
    }
    private fun actionFailure() {
        val zh = ctx.resources.configuration.locales[0].language == "zh"
        android.widget.Toast.makeText(ctx, if (zh) "动作未能启动，请在作品的执行记录中查看，并检查模型和手机权限。" else "Action could not start. Check work records, model connection and phone permissions.", android.widget.Toast.LENGTH_LONG).show()
    }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) { channel.setMethodCallHandler(null); if(WishActionOverlay.visibility===overlayVisibility)WishActionOverlay.visibility=null; actionReady=false; AnyappTaskBridge.detach(this); if(WishActionOverlay.dispatch===overlayDispatch)WishActionOverlay.dispatch=null }
    override fun onAttachedToActivity(binding: ActivityPluginBinding) { activity = binding; binding.addOnNewIntentListener(this); binding.addActivityResultListener(this); onNewIntent(binding.activity.intent) }
    override fun onDetachedFromActivity() { activity?.removeOnNewIntentListener(this); activity?.removeActivityResultListener(this); activity = null }
    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)
    override fun onActivityResult(code: Int, status: Int, data: Intent?): Boolean = life.onActivityResult(code, status, data)
    override fun onNewIntent(intent: Intent): Boolean {
        val work = intent.getStringExtra("wishProject") ?: return false
        if (runCatching { WishDeviceStore.check(work) }.isSuccess) { opened = work; openedDestination=intent.getStringExtra("wishDestination") }
        val action=intent.getStringExtra("wishAction")
        if(action!=null && intent.getStringExtra("wishEntryToken")==WishEntries.token){val source=intent.getStringExtra("wishSourcePackage")?.takeIf{Regex("^[a-zA-Z0-9_.]{3,160}$").matches(it)};val entry=mapOf("work" to work,"id" to action,"input" to (if(source!=null)mapOf("sourcePackage" to source)else emptyMap<String,String>()));dispatchAction(entry);intent.removeExtra("wishAction");intent.removeExtra("wishSourcePackage")}
        intent.removeExtra("wishProject"); return true
    }
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (life.handles(call.method) && call.method !in setOf("notifications.select", "notifications.selected", "notifications.apps")) {
            try {life.call(call.method, WishDeviceStore.check(call.argument<String>("work")!!), call.arguments as? Map<String,Any?> ?: emptyMap(), result)}
            catch(e:Exception){result.error("wish-life",e.message,null)}
            return
        }
        if (call.method in setOf("shortcuts.pin", "widget.pin", "widget.update")) {
            try {val work=WishDeviceStore.check(call.argument<String>("work")!!)
                result.success(when(call.method){
                    "shortcuts.pin" -> WishEntries.pin(ctx,work,call.argument<String>("id")!!)
                    "widget.pin" -> WishEntries.pinWidget(ctx,work,call.argument<String>("id"))
                    else -> {WishWidget.snapshot(ctx,work,call.argument<String>("value") ?: "");true}
                })
            }catch(e:Exception){result.error("wish-entry",e.message,null)};return
        }
        if (call.method == "background.listen") { AnyappTaskBridge.ready(this, channel); result.success(null); return }
        if (call.method == "actions.listen") { WishActionOverlay.dispatch = overlayDispatch; overlayVisibility = { shown, work -> channel.invokeMethod("actions.visibility", mapOf("shown" to shown, "work" to work)) }; WishActionOverlay.visibility = overlayVisibility; actionReady = true; AnyappTaskBridge.ready(this,channel); result.success(pendingAction); pendingAction = null; return }
        if (call.method == "actions.state") {
            result.success(mapOf("shown" to WishActionOverlay.isShown(), "work" to WishActionOverlay.selectedWork())); return
        }
        if (call.method == "actions.show" || call.method == "actions.hide") {
            try {
                val explicit = call.argument<Boolean>("userInitiated") == true
                val visible = if (call.method == "actions.hide") { WishActionOverlay.hide(userInitiated = explicit); true }
                    else call.argument<String>("work")?.let { WishActionOverlay.show(ctx, it, userInitiated = explicit) }
                        ?: WishActionOverlay.showEntry(ctx, userInitiated = explicit)
                result.success(visible)
            } catch(e: Exception) { result.error("wish-overlay", e.message, null) }
            return
        }
        if (call.method == "takeOpenedDestination") {result.success(openedDestination);openedDestination=null;return}
        if (call.method == "takeOpenedProject") { result.success(opened); opened = null; return }
        if (call.method == "setup.open") {
            try { result.success(WishSetupGuide.open(ctx, activity?.activity, call.argument<String>("target") ?: "")) }
            catch (_: Exception) { result.error("wish-setup", "setup-target-invalid", null) }
            return
        }
        if (call.method == "settings") {
            try {
                if (call.argument<String>("kind") == "overlay") {
                    val opened = WishSetupGuide.open(ctx, activity?.activity, "overlay")
                    check(opened["opened"] == true) { "settings-unavailable" }
                    result.success(true); return
                }
                val action = when (call.argument<String>("kind")) {
                    "notificationListener" -> Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS
                    "overlay" -> Settings.ACTION_MANAGE_OVERLAY_PERMISSION
                    "files" -> if (Build.VERSION.SDK_INT >= 30) Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION else Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                    "exact" -> if (Build.VERSION.SDK_INT >= 31) Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM else Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                    else -> Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                }
                activity?.activity?.startActivity(Intent(action).apply { if (action != Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS) data = Uri.parse("package:${ctx.packageName}") }) ?: error("activity-unavailable")
                result.success(true)
            } catch (_: Exception) { result.error("settings-unavailable", "settings-unavailable", null) }; return
        }
        (if (call.method == "phone.call") phoneIo else io).execute {
            try {
                val work = call.argument<String>("work")?.let { WishDeviceStore.check(it) }
                val phone = PhoneControl.get(ctx)
                val value: Any? = when (call.method) {
                    "notifications.apps" -> ctx.packageManager.getInstalledApplications(0).filter { ctx.packageManager.getLaunchIntentForPackage(it.packageName) != null }.map { mapOf("package" to it.packageName, "label" to ctx.packageManager.getApplicationLabel(it).toString()) }.sortedBy { it["label"] }
                    "notifications.select" -> { WishNotifications.select(ctx, work!!, call.argument<List<String>>("apps") ?: emptyList()); true }
                    "notifications.selected" -> WishNotifications.selected(ctx,work!!).toList()
                    "background.schedule" -> AnyappTasks.schedule(ctx,work!!,call.arguments as? Map<String,Any?> ?: emptyMap())
                    "background.progress" -> {AnyappTasks.progress(ctx,work!!,call.argument<String>("id")!!,call.argument<String>("runId")!!,call.argument<String>("detail")!!,call.argument<String>("sessionId"));true}
                    "background.list" -> AnyappTasks.list(ctx,work!!)
                    "background.cancel" -> {AnyappTasks.cancel(ctx,work!!,call.argument<String>("id")!!);true}
                    "background.runNow" -> {AnyappTasks.runNow(ctx,work!!,call.argument<String>("id")!!);true}
                    "events.notify" -> AnyappEvents.post(ctx,work!!,call.argument<String>("title")!!,call.argument<String>("message") ?: "")
                    "works.all" -> WishWorkStore.all(ctx)
                    "works.get" -> WishWorkStore.get(ctx, work!!)
                    "works.update" -> WishWorkStore.update(ctx, work!!, call.argument<Map<String, Any?>>("value") ?: emptyMap(), true)
                    "works.describe" -> WishWorkStore.update(ctx, work!!, call.argument<Map<String, Any?>>("value") ?: emptyMap(), false)
                    "imports.read" -> WishImport.read(ctx,work!!,call.argument<String>("id")!!)
                    "imports.list" -> WishImport.list(ctx,work!!)
                    "imports.remove" -> {WishImport.remove(ctx,work!!,call.argument<String>("id")!!);true}
                    "works.remove" -> { WishImport.clear(ctx,work!!); WishWorkStore.remove(ctx, work); true }
                    "icon.validate" -> WishWorkStore.map(WishWorkStore.icon(call.argument<Any>("value")))
                    "icon.emojiSupported" -> {
                        val emoji = call.argument<String>("value") ?: ""
                        WishWorkStore.validEmojiSequence(emoji) && android.graphics.Paint().apply {
                            textSize = 64f
                            typeface = android.graphics.Typeface.DEFAULT
                        }.hasGlyph(emoji)
                    }
                    "setup.info" -> WishSetupGuide.info(ctx)
                    "status" -> mapOf("phone" to (work?.let { WishDeviceStore.granted(ctx, it, "phone") } ?: false),
                        "reminders" to (work?.let { WishDeviceStore.granted(ctx, it, "reminders") } ?: false),
                        "life" to life.status(),
                        "background" to (work?.let { WishDeviceStore.granted(ctx,it,"background") } ?: false),
                        "calendar" to (work?.let { WishDeviceStore.granted(ctx,it,"calendar") } ?: false),
                        "location" to (work?.let { WishDeviceStore.granted(ctx,it,"location") } ?: false),
                        "notificationAccess" to (work?.let { WishDeviceStore.granted(ctx,it,"notifications") } ?: false),
                        "taskAllowed" to WishDeviceStore.allowed(ctx, work), "phoneStatus" to phone.status(),
                        "notifications" to NotificationManagerCompat.from(ctx).areNotificationsEnabled(), "exact" to WishReminders.exact(ctx),
                        "overlay" to Settings.canDrawOverlays(ctx), "files" to (if (Build.VERSION.SDK_INT >= 30) Environment.isExternalStorageManager() else ctx.checkSelfPermission(android.Manifest.permission.READ_EXTERNAL_STORAGE) == android.content.pm.PackageManager.PERMISSION_GRANTED),
                        "batteryExempt" to ctx.getSystemService(PowerManager::class.java).isIgnoringBatteryOptimizations(ctx.packageName))
                    "grant" -> {
                        val capability = call.argument<String>("capability") ?: error("invalid-capability")
                        val enabled = call.argument<Boolean>("enabled") == true
                        val owned=WishDeviceStore.work==work
                        WishDeviceStore.grant(ctx, work!!, capability, enabled)
                        if (!enabled && capability == "phone" && owned) phone.stopTask("Work permission revoked")
                        true
                    }
                    "phone.begin" -> {
                        check(phone.isEnabled() && phone.bridgeListening) { "phone-enable-in-settings" }
                        check(!phone.tasks.isActive) { "phone-task-busy" }
                        val ticket = WishDeviceStore.begin(ctx, work!!); phone.tasks.clearStop(); mapOf("ticket" to ticket)
                    }
                    "phone.call" -> {
                        check(WishDeviceStore.allowed(ctx, work, call.argument<String>("ticket"))) { "phone-task-not-active" }
                        val tool = call.argument<String>("tool") ?: error("invalid-phone-tool")
                        check(tool in PhoneToolCatalog.names) { "invalid-phone-tool" }
                        val out = phone.core.call(tool, call.argument<Map<String, Any?>>("args") ?: emptyMap())
                        mapOf("text" to out.text, "isError" to out.isError, "image" to out.image?.let { android.util.Base64.encodeToString(it, android.util.Base64.NO_WRAP) }, "mediaType" to out.imageMime)
                    }
                    "phone.end" -> { check(work != null); if (WishDeviceStore.work == work) { WishDeviceStore.end(work); phone.stopTask("Work task stopped"); phone.finishTask() }; true }
                    "phone.pause" -> { check(WishDeviceStore.allowed(ctx, work)) { "phone-task-not-active" }; phone.tasks.setPaused(call.argument<Boolean>("paused") == true); true }
                    "phone.tools" -> PhoneToolCatalog.listJson()
                    "reminders.schedule" -> WishReminders.schedule(ctx, work!!, call.argument<String>("id")!!, call.argument<Number>("at")!!.toLong(), call.argument<String>("title")!!, call.argument<String>("body") ?: "", call.argument<String>("repeat") ?: "none", call.argument<String>("timeZone") ?: java.util.TimeZone.getDefault().id)
                    "reminders.list" -> WishReminders.list(ctx, work!!)
                    "reminders.cancel" -> { WishReminders.cancel(ctx, work!!, call.argument<String>("id")!!); true }
                    "reminders.clear" -> { WishReminders.clear(ctx, work!!); true }
                    else -> error("unsupported-device-method")
                }
                main.post { result.success(value) }
            } catch (e: Exception) { main.post { result.error("wish-device", e.message ?: "device-failed", null) } }
        }
    }
}
