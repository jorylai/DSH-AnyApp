package io.github.ccch1mneyyy.dsh_app.wish

import android.app.Notification
import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONArray
import org.json.JSONObject

/** Stores only newly posted notifications from explicitly selected packages. */
class WishNotifications : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName !in selectedUnion(this)) return
        val extras=sbn.notification.extras
        val row=JSONObject(mapOf("key" to sbn.key,"package" to sbn.packageName,"at" to sbn.postTime,
            "title" to (extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: "").take(500),
            "text" to (extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: "").take(4000)))
        synchronized(lock){
            val p=prefs(this);val old=JSONArray(p.getString("recent","[]"));val rows=JSONArray()
            for(i in 0 until old.length())if(old.getJSONObject(i).optString("key")!=sbn.key && old.getJSONObject(i).optLong("at")>System.currentTimeMillis()-7L*86400000)rows.put(old.get(i))
            rows.put(row);val bounded=JSONArray();for(i in (rows.length()-150).coerceAtLeast(0) until rows.length())bounded.put(rows.get(i))
            p.edit().putString("recent",bounded.toString()).apply()
        }
    }
    companion object {
        private val lock=Any()
        private fun prefs(ctx:Context)=ctx.getSharedPreferences("wish-notifications-v1",0)
        fun selected(ctx:Context,work:String):Set<String> = prefs(ctx).getStringSet("apps:${WishDeviceStore.check(work)}",emptySet()) ?: emptySet()
        private fun selectedUnion(ctx:Context):Set<String> = prefs(ctx).all.keys.filter{it.startsWith("apps:")}.flatMap{prefs(ctx).getStringSet(it,emptySet()) ?: emptySet()}.toSet()
        fun select(ctx:Context,work:String,apps:List<String>){WishDeviceStore.check(work);require(apps.size<=30&&apps.all{Regex("^[a-zA-Z0-9_.]{3,160}$").matches(it)});prefs(ctx).edit().putStringSet("apps:$work",apps.toSet()).commit()}
        fun list(ctx:Context,work:String):Map<String,Any?> {
            check(androidx.core.app.NotificationManagerCompat.getEnabledListenerPackages(ctx).contains(ctx.packageName)){"notification-listener-permission-required"}
            val apps=selected(ctx,work);val rows=JSONArray(prefs(ctx).getString("recent","[]"));val out=mutableListOf<Map<String,Any?>>()
            for(i in 0 until rows.length()){val row=rows.getJSONObject(i);if(row.optString("package") in apps)out+=WishWorkStore.map(row)}
            return mapOf("items" to out.sortedByDescending{it["at"] as? Long ?: 0L},"selectedApps" to apps.toList(),"historyComplete" to false)
        }
    }
}
