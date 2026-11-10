package io.github.ccch1mneyyy.dsh_app.wish
import android.app.*
import android.content.*
import android.os.Build
import androidx.core.app.NotificationManagerCompat
import io.github.ccch1mneyyy.dsh_app.MainActivity
import io.github.ccch1mneyyy.dsh_app.R

object AnyappEvents {
    fun post(ctx:Context,work:String,title:String,message:String,route:String?=null):Map<String,Any> {
        WishDeviceStore.check(work);require(title.length in 1..120 && message.length<=4000)
        if(!NotificationManagerCompat.from(ctx).areNotificationsEnabled())return mapOf("posted" to false,"reason" to "notifications-disabled")
        val nm=ctx.getSystemService(NotificationManager::class.java)
        val zh=!io.github.ccch1mneyyy.dsh_app.i18n.AppStrings.isEnglish(ctx)
        if(Build.VERSION.SDK_INT>=26)nm.createNotificationChannel(NotificationChannel("anyapp-results-v1",if(zh)"作品与任务结果" else "App and task results",NotificationManager.IMPORTANCE_DEFAULT))
        val intent=Intent(ctx,MainActivity::class.java).putExtra("wishProject",work).putExtra("wishDestination",route).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val open=PendingIntent.getActivity(ctx,work.hashCode(),intent,PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val public=Notification.Builder(ctx,"anyapp-results-v1").setSmallIcon(R.drawable.ic_stat_dsh).setContentTitle("DSH AnyApp").setContentText(if(zh)"有一条新的作品或任务结果" else "A new app or task result is ready").build()
        val notification=Notification.Builder(ctx,"anyapp-results-v1").setSmallIcon(R.drawable.ic_stat_dsh).setLargeIcon(AnyappBrand.bitmap(ctx)).setContentTitle(title).setContentText(message.take(160)).setStyle(Notification.BigTextStyle().bigText(message)).setContentIntent(open).setVisibility(Notification.VISIBILITY_PRIVATE).setPublicVersion(public).setAutoCancel(true).build()
        nm.notify("anyapp:$work",7,notification);return mapOf("posted" to true)
    }
}
