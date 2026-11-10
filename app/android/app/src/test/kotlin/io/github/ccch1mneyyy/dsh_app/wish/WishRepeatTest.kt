package io.github.ccch1mneyyy.dsh_app.wish
import org.junit.Assert.*
import org.junit.Test
import java.time.ZonedDateTime

class WishRepeatTest {
    @Test fun dailyPreservesWallTimeAcrossDst(){
        val at=ZonedDateTime.parse("2026-03-07T09:00:00-05:00[America/New_York]").toInstant().toEpochMilli()
        val next=WishRepeat.next(at,"America/New_York","daily",at)!!
        assertEquals(23L*3600000,next-at)
        assertEquals(9,java.time.Instant.ofEpochMilli(next).atZone(java.time.ZoneId.of("America/New_York")).hour)
    }
    @Test fun springGapDoesNotPermanentlyShiftLaterDays(){
        val start=ZonedDateTime.parse("2026-03-07T02:30:00-05:00[America/New_York]").toInstant().toEpochMilli()
        val gap=WishRepeat.next(start,"America/New_York","daily",start)!!
        val next=WishRepeat.next(start,"America/New_York","daily",gap)!!
        val local=java.time.Instant.ofEpochMilli(next).atZone(java.time.ZoneId.of("America/New_York"))
        assertEquals(9,local.dayOfMonth);assertEquals(2,local.hour);assertEquals(30,local.minute)
    }
    @Test fun weeklySkipsMissedOccurrencesWithoutDrifting(){
        val at=ZonedDateTime.parse("2026-11-01T09:00:00+08:00[Asia/Shanghai]").toInstant().toEpochMilli()
        assertEquals(at+21L*86400000,WishRepeat.next(at,"Asia/Shanghai","weekly",at+15L*86400000))
        assertNull(WishRepeat.next(at,"Asia/Shanghai","none",at))
    }
    @Test(expected=IllegalArgumentException::class) fun invalidRepeatIsRejected(){WishRepeat.next(0,"Asia/Shanghai","hourly",0)}
}
