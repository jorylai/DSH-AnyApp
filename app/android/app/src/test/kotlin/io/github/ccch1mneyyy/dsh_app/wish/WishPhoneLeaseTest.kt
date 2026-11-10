package io.github.ccch1mneyyy.dsh_app.wish
import org.junit.Assert.*
import org.junit.Test

class WishPhoneLeaseTest {
    @Test fun explicitStartScopeAndTicketAreRequired() {
        val lease = WishPhoneLease { 100 }
        lease.launch("local-a")
        assertFalse(lease.allowed("local-a", null, true))
        try { lease.begin("local-a", false); fail() } catch (_: IllegalStateException) { }
        val ticket = lease.begin("local-a", true)
        assertTrue(lease.allowed("local-a", ticket, true))
        assertFalse(lease.allowed("local-b", ticket, true))
        assertFalse(lease.allowed("local-a", "old-ticket", true))
        assertFalse(lease.allowed("local-a", ticket, false))
        try { lease.begin("local-a", true); fail() } catch (_: IllegalStateException) { }
    }
    @Test fun stopRevokesAndRestartNeverResumesAutomatically() {
        val lease = WishPhoneLease { 100 }
        lease.launch("local-a"); val ticket = lease.begin("local-a", true)
        lease.end("local-b"); assertTrue(lease.allowed("local-a", ticket, true))
        lease.end("local-a"); assertFalse(lease.allowed("local-a", ticket, true))
        lease.begin("local-a", true)
        lease.launch("local-a"); assertFalse(lease.allowed("local-a", null, true))
        lease.launch("local-b")
        try { lease.begin("local-a", true); fail() } catch (_: IllegalStateException) { }
    }
    @Test fun actionsDoNotExtendTaskDeadline() {
        var now = 0L; val lease = WishPhoneLease { now }
        lease.launch("local-a"); val ticket = lease.begin("local-a", true)
        now = 1_799_999; assertTrue(lease.allowed("local-a", ticket, true))
        now = 1_800_000; assertFalse(lease.allowed("local-a", ticket, true))
        val next = lease.begin("local-a", true)
        assertNotEquals(ticket,next); assertTrue(lease.allowed("local-a",next,true))
    }
}
