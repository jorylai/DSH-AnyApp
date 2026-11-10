package io.github.ccch1mneyyy.dsh_app.wish

import android.content.Context

/** Native capability grants are separate from model/plugin code and Linux file permissions. */
object WishDeviceStore {
    private val id = Regex("^local-[a-z0-9][a-z0-9-]{0,42}$")
    private val lease = WishPhoneLease()
    val work: String? get() = lease.work
    fun check(work: String): String { require(id.matches(work)) { "invalid-project" }; return work }
    private fun prefs(ctx: Context) = ctx.getSharedPreferences("wish-device-v1", Context.MODE_PRIVATE)
    fun granted(ctx: Context, work: String, capability: String): Boolean = prefs(ctx).getBoolean("${check(work)}:$capability", false)
    fun grant(ctx: Context, work: String, capability: String, value: Boolean) {
        require(capability in setOf("phone", "reminders", "calendar", "location", "notifications", "background"))
        kotlin.check(prefs(ctx).edit().putBoolean("${check(work)}:$capability", value).commit())
        if (!value && capability == "phone") end(work)
        if (!value && capability == "reminders") WishReminders.clear(ctx, work)
        if (!value && capability == "background") AnyappTasks.clear(ctx,work)
    }
    fun remove(ctx: Context, work: String) {
        check(work); end(work); WishReminders.clear(ctx,work); AnyappTasks.clear(ctx,work)
        val p=prefs(ctx); val edit=p.edit()
        p.all.keys.filter{it.startsWith("$work:")}.forEach{edit.remove(it)}
        kotlin.check(edit.commit())
    }
    fun launch(profile: String?) {
        lease.launch(profile?.takeIf { it.startsWith("app-local-") }?.removePrefix("app-")?.takeIf { id.matches(it) })
    }
    fun begin(ctx: Context, work: String): String = lease.begin(work, granted(ctx, work, "phone"))
    fun allowed(ctx: Context, work: String?, token: String? = null): Boolean =
        lease.allowed(work, token, work != null && granted(ctx, work, "phone"))
    fun end(work: String) = lease.end(work)
}
