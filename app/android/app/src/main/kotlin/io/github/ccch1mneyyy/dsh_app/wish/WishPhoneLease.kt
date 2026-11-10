package io.github.ccch1mneyyy.dsh_app.wish

import java.util.UUID

/** An explicit, non-renewing 30 minute user task. Never persisted across engine launches. */
class WishPhoneLease(private val clock: () -> Long = { System.nanoTime() / 1_000_000 }) {
    @Volatile var work: String? = null
        private set
    private var owner: String? = null
    private var ticket: String? = null
    private var until = 0L
    @Synchronized fun launch(work: String?) { this.work = work; owner = null; ticket = null; until = 0 }
    @Synchronized fun begin(work: String, granted: Boolean): String {
        check(this.work == work && granted) { "phone-not-authorized" }
        check(ticket == null || clock() >= until) { "phone-task-busy" }
        owner = work; ticket = UUID.randomUUID().toString(); until = clock() + 30 * 60_000
        return ticket!!
    }
    @Synchronized fun allowed(work: String?, token: String?, granted: Boolean): Boolean = work != null &&
        this.work == work && owner == work && ticket != null && (token == null || token == ticket) && clock() < until && granted
    @Synchronized fun end(work: String) { if (owner == work) { ticket = null; owner = null; until = 0 } }
}
