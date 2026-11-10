package io.github.ccch1mneyyy.dsh_app.wish

import java.time.Instant
import java.time.ZoneId

/** Calendar-day recurrence preserves local wall time across DST transitions. */
object WishRepeat {
    fun next(at: Long, zone: String, repeat: String, after: Long): Long? {
        require(repeat in setOf("none","daily","weekly")) { "invalid-reminder-repeat" }
        val tz=ZoneId.of(zone)
        if(repeat=="none")return null
        val start=Instant.ofEpochMilli(at).atZone(tz)
        var steps=0L
        var candidate=start
        val days=if(repeat=="weekly")7L else 1L
        if(at<=after){val elapsed=java.time.temporal.ChronoUnit.DAYS.between(start.toLocalDate(),Instant.ofEpochMilli(after).atZone(tz).toLocalDate()).coerceAtLeast(0);steps=elapsed/days;candidate=start.plusDays(steps*days)}
        while(candidate.toInstant().toEpochMilli()<=after){steps++;candidate=start.plusDays(steps*days)}
        return candidate.toInstant().toEpochMilli()
    }
}
