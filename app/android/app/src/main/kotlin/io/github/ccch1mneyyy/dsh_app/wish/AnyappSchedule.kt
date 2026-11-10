package io.github.ccch1mneyyy.dsh_app.wish
object AnyappSchedule {
    fun next(anchor:Long,zone:String,repeat:String,minutes:Int,after:Long):Long? {
        if(repeat=="interval"){require(minutes in 15..10080);val step=minutes*60000L;return anchor+(((after-anchor).coerceAtLeast(0)/step)+1)*step}
        return WishRepeat.next(anchor,zone,repeat,after)
    }
}
