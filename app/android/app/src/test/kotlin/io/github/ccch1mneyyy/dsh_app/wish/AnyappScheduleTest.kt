package io.github.ccch1mneyyy.dsh_app.wish
import org.junit.Assert.*
import org.junit.Test
import java.time.Instant
class AnyappScheduleTest {
 @Test fun intervalDoesNotDriftOrReplayEveryMissedRun(){val anchor=100000L;assertEquals(anchor+4*900000L,AnyappSchedule.next(anchor,"UTC","interval",15,anchor+3*900000L+1));}
 @Test fun oneShotHasNoNextRun(){assertNull(AnyappSchedule.next(1000,"UTC","none",60,2000));}
 @Test fun dailyPreservesLocalWallTimeAtDstBoundary(){val a=Instant.parse("2026-03-07T14:00:00Z").toEpochMilli();val next=AnyappSchedule.next(a,"America/New_York","daily",60,a);assertEquals(Instant.parse("2026-03-08T13:00:00Z").toEpochMilli(),next);}
 @Test(expected=IllegalArgumentException::class) fun refusesExcessivePolling(){AnyappSchedule.next(0,"UTC","interval",1,100);}
}
