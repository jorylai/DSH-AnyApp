package io.github.ccch1mneyyy.dsh_app.wish

import android.app.*
import android.content.*
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationManagerCompat
import io.github.ccch1mneyyy.dsh_app.MainActivity
import io.github.ccch1mneyyy.dsh_app.R
import org.json.JSONArray
import org.json.JSONObject

/** AlarmManager owns deadlines; no WebView, Node process or running Activity is required. */
object WishReminders {
    private const val CHANNEL = "wish-reminders"
    private fun prefs(c: Context) = c.getSharedPreferences("wish-reminders-v1", Context.MODE_PRIVATE)
    private fun rows(c: Context): MutableList<JSONObject> {
        val a = JSONArray(prefs(c).getString("rows", "[]")); return (0 until a.length()).map { a.getJSONObject(it) }.toMutableList()
    }
    private fun save(c: Context, list: List<JSONObject>) { check(prefs(c).edit().putString("rows", JSONArray(list).toString()).commit()) }
    private fun alarm(c: Context) = c.getSystemService(AlarmManager::class.java)
    fun exact(c: Context) = Build.VERSION.SDK_INT < 31 || alarm(c).canScheduleExactAlarms()
    private fun pending(c: Context, work: String, id: String): PendingIntent = PendingIntent.getBroadcast(c, 0,
        Intent(c, WishReminderReceiver::class.java).setAction("wish.remind").setData(Uri.parse("dshwish-reminder://$work/$id"))
            .putExtra("work", work).putExtra("id", id), PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    private fun arm(c: Context, row: JSONObject): String {
        val at = row.getLong("at"); val pi = pending(c, row.getString("work"), row.getString("id"))
        if (exact(c)) {
            try { alarm(c).setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi); return "exact" } catch (_: SecurityException) { }
        }
        alarm(c).setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi); return "inexact"
    }
    @Synchronized fun schedule(c: Context, work: String, id: String, at: Long, title: String, body: String, repeat: String = "none", timeZone: String = java.util.TimeZone.getDefault().id): Map<String, Any> {
        WishDeviceStore.check(work)
        WishRepeat.next(at, timeZone, repeat, at)
        require(Regex("^[a-zA-Z0-9_-]{1,64}$").matches(id)) { "invalid-reminder-id" }
        require(title.isNotBlank() && title.length <= 100 && body.length <= 500) { "invalid-reminder-text" }
        require(at > System.currentTimeMillis() && at <= System.currentTimeMillis() + 366L * 86400_000) { "invalid-reminder-time" }
        check(WishDeviceStore.granted(c, work, "reminders")) { "reminders-not-authorized" }
        check(NotificationManagerCompat.from(c).areNotificationsEnabled()) { "notifications-disabled" }
        val list = rows(c); val old = list.firstOrNull { it.optString("work") == work && it.optString("id") == id }
        check(list.count { it.optString("work") == work && it.optString("state") == "scheduled" } < 64 || old != null) { "reminder-limit" }
        val row = JSONObject().put("work", work).put("id", id).put("at", at).put("title", title).put("body", body).put("state", "scheduled").put("repeat", repeat).put("timeZone", timeZone).put("repeatAnchor",at)
        row.put("timing", if (exact(c)) "exact" else "inexact")
        val next = (list.filterNot { it.optString("work") == work && it.optString("id") == id } + row)
        save(c, next)
        try { row.put("timing", arm(c, row)); save(c, next) } catch (e: Exception) { alarm(c).cancel(pending(c, work, id)); save(c, list); throw e }
        return mapOf("id" to id, "at" to at, "timing" to row.getString("timing"), "scheduled" to true)
    }
    @Synchronized fun list(c: Context, work: String): List<Map<String, Any>> = rows(c).filter { it.optString("work") == work }.map { r ->
        r.keys().asSequence().filter { it != "work" }.associateWith { r.get(it) }
    }
    @Synchronized fun cancel(c: Context, work: String, id: String) {
        alarm(c).cancel(pending(c, work, id)); save(c, rows(c).filterNot { it.optString("work") == work && it.optString("id") == id })
        c.getSystemService(NotificationManager::class.java).cancel("$work:$id", 0)
    }
    @Synchronized fun clear(c: Context, work: String) { list(c, work).forEach { cancel(c, work, it["id"] as String) } }
    @Synchronized fun restore(c: Context) {
        val list = rows(c)
        list.filter { it.optString("state") == "scheduled" }.forEach {
            if (!WishDeviceStore.granted(c, it.getString("work"), "reminders")) it.put("state", "cancelled")
            else if (it.getLong("at") <= System.currentTimeMillis()) {
                val next=WishRepeat.next(it.optLong("repeatAnchor",it.getLong("at")),it.optString("timeZone",java.util.TimeZone.getDefault().id),it.optString("repeat","none"),System.currentTimeMillis())
                if(next==null)it.put("state","missed") else {it.put("at",next).put("lastMissed",true);try{it.put("timing",arm(c,it))}catch(_:Exception){it.put("state","failed")}}
            }
            else try { it.put("timing", arm(c, it)) } catch (_: Exception) { it.put("state", "failed") }
        }
        save(c, list)
    }
    @Synchronized fun fire(c: Context, work: String, id: String) {
        val list = rows(c); val row = list.firstOrNull { it.optString("work") == work && it.optString("id") == id && it.optString("state") == "scheduled" } ?: return
        if (!WishDeviceStore.granted(c, work, "reminders")) return
        val nm = c.getSystemService(NotificationManager::class.java)
        nm.createNotificationChannel(NotificationChannel(CHANNEL, c.getString(R.string.wish_reminder_channel), NotificationManager.IMPORTANCE_HIGH))
        val intent = Intent(c, MainActivity::class.java).setAction("wish.open").setData(Uri.parse("dshwish-work://$work"))
            .putExtra("wishProject", work).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val pi = PendingIntent.getActivity(c, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        try {
            if (!NotificationManagerCompat.from(c).areNotificationsEnabled() || nm.getNotificationChannel(CHANNEL)?.importance == NotificationManager.IMPORTANCE_NONE) {
                row.put("state", "blocked")
            } else {
                nm.notify("$work:$id", 0, Notification.Builder(c, CHANNEL).setSmallIcon(R.drawable.ic_tile_new_chat)
                    .setContentTitle(row.getString("title")).setContentText(row.optString("body"))
                    .setStyle(Notification.BigTextStyle().bigText(row.optString("body"))).setContentIntent(pi).setAutoCancel(true).build())
                row.put("state", "delivered")
            }
        } catch (_: SecurityException) { row.put("state", "blocked") }
        row.put("firedAt", System.currentTimeMillis())
        val next=WishRepeat.next(row.optLong("repeatAnchor",row.getLong("at")),row.optString("timeZone",java.util.TimeZone.getDefault().id),row.optString("repeat","none"),System.currentTimeMillis())
        if(next!=null && row.optString("state")=="delivered") {row.put("at",next).put("state","scheduled");try{row.put("timing",arm(c,row))}catch(_:Exception){row.put("state","failed")}}
        save(c, list.filter { it.optString("state") == "scheduled" } + list.filter { it.optString("state") != "scheduled" }.takeLast(200))
    }
}
class WishReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "wish.remind") {
            val work = intent.getStringExtra("work") ?: return; val id = intent.getStringExtra("id") ?: return
            WishReminders.fire(context, work, id)
        } else WishReminders.restore(context)
    }
}
