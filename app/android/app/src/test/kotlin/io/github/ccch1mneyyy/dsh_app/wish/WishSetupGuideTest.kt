package io.github.ccch1mneyyy.dsh_app.wish

import android.provider.Settings
import org.junit.Assert.*
import org.junit.Test

class WishSetupGuideTest {
    @Test fun unreadableToggleIsUnknown() {
        assertNull(WishSetupGuide.flag(null))
        assertNull(WishSetupGuide.flag(2))
        assertEquals(false, WishSetupGuide.flag(0))
        assertEquals(true, WishSetupGuide.flag(1))
    }

    @Test fun approximateOrPreciseLocationCanBeGrantedIndependently() {
        assertEquals(true, WishSetupGuide.combineLocation(true, false))
        assertEquals(true, WishSetupGuide.combineLocation(null, true))
        assertEquals(false, WishSetupGuide.combineLocation(false, false))
        assertNull(WishSetupGuide.combineLocation(false, null))
    }

    @Test fun everyAcceptedPageHasADetailsAndGeneralSettingsEscape() {
        for (target in WishSetupGuide.targets) {
            val routes = WishSetupGuide.routes(target, "xiaomi", 36)
            assertEquals("appDetails", routes[routes.lastIndex - 1].destination)
            assertEquals("settings", routes.last().destination)
        }
    }

    @Test fun arbitraryIntentsOrPackagesCannotBeRequested() {
        for (target in listOf("", "intent://foo", "com.android.settings", "grant", "root")) {
            try { WishSetupGuide.routes(target, "xiaomi", 36); fail(target) }
            catch (error: IllegalArgumentException) { assertEquals("setup-target-invalid", error.message) }
        }
    }

    @Test fun notificationPermissionAndNotificationAccessAreDifferentDestinations() {
        assertEquals(Settings.ACTION_APP_NOTIFICATION_SETTINGS, WishSetupGuide.routes("notifications", null, 36).first().action)
        assertEquals(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS, WishSetupGuide.routes("notificationAccess", null, 36).first().action)
    }

    @Test fun unsupportedSpecialSettingsDoNotClaimTheyOpened() {
        assertEquals("appDetails", WishSetupGuide.routes("allFiles", null, 29).first().destination)
        assertEquals("appDetails", WishSetupGuide.routes("exact", null, 30).first().destination)
        assertEquals("allFiles", WishSetupGuide.routes("allFiles", null, 30).first().destination)
        assertEquals("exact", WishSetupGuide.routes("exact", null, 31).first().destination)
    }

    @Test fun oemPagesAreCandidatesRatherThanAssumedAuthorizations() {
        val xiaomi = WishSetupGuide.routes("autostart", "xiaomi", 36).first()
        assertEquals("com.miui.securitycenter", xiaomi.vendorPage?.pkg)
        assertEquals("autostart", xiaomi.destination)
        assertEquals("appDetails", WishSetupGuide.routes("autostart", "samsung", 36).first().destination)
        assertEquals("appDetails", WishSetupGuide.routes("background", null, 36).first().destination)
    }

    @Test fun overlayKeepsThisPackageOnModernPhonesAndHasAnExplicitListFallback() {
        val old = WishSetupGuide.routes("overlay", null, 29).first()
        assertEquals(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, old.action)
        assertTrue(old.packageUri)
        val modern = WishSetupGuide.routes("overlay", "xiaomi", 36).first()
        assertEquals(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, modern.action)
        assertTrue(modern.packageUri)
        val fallback = WishSetupGuide.routes("overlay", "xiaomi", 36)[1]
        assertEquals("overlayList", fallback.destination)
        assertFalse(fallback.packageUri)
        assertEquals(true, WishSetupGuide.outcome("overlay", fallback.destination)["fallback"])
    }

    @Test fun developerDebuggingAliasesOnlyNavigateToDeveloperOptions() {
        for (target in listOf("developer", "usbDebugging", "wirelessDebugging")) {
            val route = WishSetupGuide.routes(target, null, 36).first()
            assertEquals("developer", route.destination)
            assertEquals(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS, route.action)
            assertEquals(false, WishSetupGuide.outcome(target, route.destination)["fallback"])
        }
    }

    @Test fun returnValueReportsActualFallbackOrFailure() {
        val fallback = WishSetupGuide.outcome("autostart", "appDetails")
        assertEquals(true, fallback["opened"])
        assertEquals(true, fallback["fallback"])
        assertEquals("appDetails", fallback["resolvedTarget"])
        val failure = WishSetupGuide.outcome("accessibility", null)
        assertEquals(false, failure["opened"])
        assertEquals(false, failure["fallback"])
        assertNull(failure["resolvedTarget"])
    }
}
