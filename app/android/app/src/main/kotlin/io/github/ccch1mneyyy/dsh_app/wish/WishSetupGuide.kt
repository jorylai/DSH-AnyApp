package io.github.ccch1mneyyy.dsh_app.wish

import android.Manifest
import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.github.ccch1mneyyy.dsh_app.phone.PhoneControl
import io.github.ccch1mneyyy.dsh_app.phone.PhoneRegistry
import io.github.ccch1mneyyy.dsh_app.phone.RestrictedSettings
import io.github.ccch1mneyyy.dsh_app.runtime.VendorSettings

/** Read-only setup facts and user-initiated settings navigation. No settings are changed here. */
object WishSetupGuide {
    /** A null value stays unknown: visiting a settings page is never proof of authorization. */
    fun flag(value: Int?): Boolean? = when (value) { 0 -> false; 1 -> true; else -> null }

    fun info(ctx: Context): Map<String, Any?> {
        fun has(permission: String): Boolean? = runCatching {
            ctx.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
        }.getOrNull()
        fun global(key: String): Boolean? = flag(runCatching {
            Settings.Global.getInt(ctx.contentResolver, key)
        }.getOrNull())
        val phone = PhoneControl.get(ctx)
        return mapOf(
            "phone" to mapOf("enabled" to phone.isEnabled(), "bridgeListening" to phone.bridgeListening),
            "appLabel" to ctx.applicationInfo.loadLabel(ctx.packageManager).toString(),
            "manufacturer" to Build.MANUFACTURER,
            "brand" to Build.BRAND,
            "model" to Build.MODEL,
            "sdkInt" to Build.VERSION.SDK_INT,
            "release" to Build.VERSION.RELEASE,
            "vendor" to VendorSettings.vendorOf(Build.MANUFACTURER, Build.BRAND),
            "developerOptions" to global(Settings.Global.DEVELOPMENT_SETTINGS_ENABLED),
            "usbDebugging" to global(Settings.Global.ADB_ENABLED),
            // There is no public Android API for the Wi-Fi debugging toggle or OEM switches.
            "wirelessDebugging" to null,
            "wirelessDebuggingSupported" to (Build.VERSION.SDK_INT >= 30),
            "accessibility" to mapOf(
                "enabled" to runCatching { phone.a11yEnabledInSettings() }.getOrNull(),
                "serviceConnected" to (PhoneRegistry.mainDriver != null),
                "restricted" to RestrictedSettings.read(ctx),
            ),
            "notifications" to mapOf(
                "enabled" to runCatching { NotificationManagerCompat.from(ctx).areNotificationsEnabled() }.getOrNull(),
                "listenerEnabled" to runCatching {
                    NotificationManagerCompat.getEnabledListenerPackages(ctx).contains(ctx.packageName)
                }.getOrNull(),
            ),
            "permissions" to mapOf(
                "overlay" to runCatching { Settings.canDrawOverlays(ctx) }.getOrNull(),
                "batteryExempt" to runCatching {
                    ctx.getSystemService(PowerManager::class.java).isIgnoringBatteryOptimizations(ctx.packageName)
                }.getOrNull(),
                "exact" to runCatching { WishReminders.exact(ctx) }.getOrNull(),
                "allFiles" to if (Build.VERSION.SDK_INT >= 30) runCatching {
                    Environment.isExternalStorageManager()
                }.getOrNull() else has(Manifest.permission.READ_EXTERNAL_STORAGE),
                "microphone" to has(Manifest.permission.RECORD_AUDIO),
                "camera" to has(Manifest.permission.CAMERA),
                "calendarRead" to has(Manifest.permission.READ_CALENDAR),
                "calendarWrite" to has(Manifest.permission.WRITE_CALENDAR),
                "location" to combineLocation(has(Manifest.permission.ACCESS_COARSE_LOCATION), has(Manifest.permission.ACCESS_FINE_LOCATION)),
            ),
            "vendorSettings" to mapOf("autostart" to null, "background" to null, "popup" to null),
        )
    }

    fun combineLocation(coarse: Boolean?, fine: Boolean?): Boolean? = when {
        coarse == true || fine == true -> true
        coarse == false && fine == false -> false
        else -> null
    }

    /** A platform-free plan keeps the route allowlist and fallback behavior testable. */
    data class Route(
        val destination: String,
        val action: String? = null,
        val packageUri: Boolean = false,
        val vendorPage: VendorSettings.Page? = null,
    )

    val targets = setOf("accessibility", "appDetails", "notifications", "notificationAccess", "overlay",
        "battery", "exact", "allFiles", "developer", "usbDebugging", "wirelessDebugging",
        "autostart", "background", "popup")

    fun routes(target: String, vendor: String?, sdk: Int): List<Route> {
        require(target in targets) { "setup-target-invalid" }
        val primary = when (target) {
            "accessibility" -> listOf(Route(target, Settings.ACTION_ACCESSIBILITY_SETTINGS))
            "appDetails" -> emptyList()
            "notifications" -> listOf(Route(target, Settings.ACTION_APP_NOTIFICATION_SETTINGS))
            "notificationAccess" -> listOf(Route(target, Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
            // Keep our identity even on newer Android. HyperOS uses package:
            // to open this app's own permission page; dropping it opens a list.
            "overlay" -> listOf(Route(target, Settings.ACTION_MANAGE_OVERLAY_PERMISSION, true),
                Route("overlayList", Settings.ACTION_MANAGE_OVERLAY_PERMISSION))
            "battery" -> listOf(Route(target, Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
            "exact" -> if (sdk >= 31) listOf(Route(target, Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, true)) else emptyList()
            "allFiles" -> if (sdk >= 30) listOf(Route(target, Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION, true)) else emptyList()
            // Opening Developer options is an explicit advanced action, not a prerequisite for accessibility.
            "developer", "usbDebugging", "wirelessDebugging" -> listOf(Route("developer", Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS))
            else -> VendorSettings.pages(vendor, VendorSettings.Switch.parse(target)!!).map { Route(target, vendorPage = it) }
        }
        return primary + Route("appDetails", Settings.ACTION_APPLICATION_DETAILS_SETTINGS, true) + Route("settings", Settings.ACTION_SETTINGS)
    }

    fun outcome(target: String, destination: String?): Map<String, Any?> = mapOf(
        "opened" to (destination != null), "target" to target, "resolvedTarget" to destination,
        "fallback" to (destination != null && destination != target && !(target in setOf("usbDebugging", "wirelessDebugging") && destination == "developer")),
    )

    fun open(ctx: Context, activity: Activity?, target: String): Map<String, Any?> {
        val plans = routes(target, VendorSettings.vendorOf(Build.MANUFACTURER, Build.BRAND), Build.VERSION.SDK_INT)
        if (activity == null || activity.isFinishing || activity.isDestroyed) return outcome(target, null)
        val pm = ctx.packageManager
        for (route in plans) {
            val page = route.vendorPage
            val intent = if (page != null) {
                val candidate = if (page.cls != null) Intent().setComponent(ComponentName(page.pkg, page.cls))
                    else Intent(page.action).setPackage(page.pkg)
                page.packageExtra?.let { candidate.putExtra(it, ctx.packageName) }
                page.labelExtra?.let { candidate.putExtra(it, ctx.applicationInfo.loadLabel(pm).toString()) }
                val resolved = runCatching { candidate.resolveActivityInfo(pm, 0) }.getOrNull()
                if (resolved?.exported != true) continue
                if (page.cls == null) candidate.setClassName(resolved.packageName, resolved.name)
                candidate
            } else {
                Intent(route.action).apply {
                    if (route.packageUri) data = Uri.parse("package:${ctx.packageName}")
                    if (route.destination == "notifications") putExtra(Settings.EXTRA_APP_PACKAGE, ctx.packageName)
                    if (route.destination == "accessibility") {
                        val component = io.github.ccch1mneyyy.dsh_app.phone.a11y.PhoneA11yService.component(ctx).flattenToString()
                        putExtra(":settings:fragment_args_key", component)
                        putExtra(":settings:show_fragment_args", android.os.Bundle().apply { putString(":settings:fragment_args_key", component) })
                    }
                }
            }
            if (runCatching { activity.startActivity(intent) }.isSuccess) return outcome(target, route.destination)
        }
        return outcome(target, null)
    }
}
