package io.github.ccch1mneyyy.dsh_app.wish

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** dsh-wish own onboarding permissions: camera + notifications only. */
class WishPermissionPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var result: MethodChannel.Result? = null
    private var pending: String? = null
    private val listener = io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener { code, perms, grants ->
        if (code == REQUEST) { onResult(code, perms, grants); true } else false
    }
    private var binding: ActivityPluginBinding? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "dsh/wish/permissions")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "status" -> {
                val ctx = activity
                if (ctx == null) { result.success(mapOf("camera" to false, "notifications" to false)); return }
                result.success(mapOf(
                    "camera" to has(Manifest.permission.CAMERA),
                    "microphone" to has(Manifest.permission.RECORD_AUDIO),
                    "notifications" to NotificationManagerCompat.from(ctx).areNotificationsEnabled(),
                ))
            }
            "requestCalendar" -> request(Manifest.permission.READ_CALENDAR, "calendarRead", result)
            "requestCalendarWrite" -> request(Manifest.permission.WRITE_CALENDAR, "calendarWrite", result)
            "requestLocation" -> request(Manifest.permission.ACCESS_COARSE_LOCATION, "location", result)
            "requestMicrophone" -> request(Manifest.permission.RECORD_AUDIO, "microphone", result)
            "requestCamera" -> request(Manifest.permission.CAMERA, "camera", result)
            "requestNotifications" -> {
                if (Build.VERSION.SDK_INT >= 33) request(Manifest.permission.POST_NOTIFICATIONS, "notifications", result)
                else result.success(mapOf("notifications" to (activity?.let { NotificationManagerCompat.from(it).areNotificationsEnabled() } ?: false)))
            }
            "openSettings" -> {
                val ctx = activity ?: return result.success(false)
                ctx.startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", ctx.packageName, null)).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun has(permission: String): Boolean {
        val ctx: Context = activity ?: return false
        return ctx.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
    }

    private fun request(permission: String, kind: String, result: MethodChannel.Result) {
        val act = activity ?: return result.success(mapOf(kind to false))
        if (has(permission)) return result.success(mapOf(kind to true))
        if (this.result != null) return result.success(mapOf(kind to false))
        this.result = result
        pending = kind
        act.requestPermissions(arrayOf(permission), REQUEST)
    }

    private fun onResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (requestCode != REQUEST) return
        val ok = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        val kind = pending ?: "camera"
        pending = null
        val r = result
        result = null
        r?.success(mapOf(kind to ok))
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
        activity = binding.activity
        binding.addRequestPermissionsResultListener(listener)
    }

    override fun onDetachedFromActivityForConfigChanges() { binding?.removeRequestPermissionsResultListener(listener); binding = null; activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { onAttachedToActivity(binding) }
    override fun onDetachedFromActivity() { onDetachedFromActivityForConfigChanges(); result?.success(mapOf((pending ?: "camera") to false)); result = null; pending = null }

    companion object { private const val REQUEST = 7301 }
}
