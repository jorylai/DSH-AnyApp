package io.github.ccch1mneyyy.dsh_app.wish

import android.app.*
import android.appwidget.*
import android.content.*
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build
import android.os.Bundle
import android.service.quicksettings.TileService
import android.widget.RemoteViews
import io.github.ccch1mneyyy.dsh_app.MainActivity
import io.github.ccch1mneyyy.dsh_app.R

object WishEntries {
    val token: String = java.util.UUID.randomUUID().toString()
    fun entry(ctx:Context,work:String,action:String?):Intent = Intent(ctx,WishEntryActivity::class.java).setAction("wish.entry").putExtra("work",WishDeviceStore.check(work)).apply{putExtra("actionId",action)}
    fun pin(ctx:Context,work:String,action:String):Boolean {
        val data=WishWorkStore.get(ctx,work)
        val row=(data["actions"] as? List<*>)?.filterIsInstance<Map<*,*>>()?.firstOrNull{it["id"]==action} ?: error("action-not-registered")
        val manager=ctx.getSystemService(ShortcutManager::class.java)
        check(manager.isRequestPinShortcutSupported){"launcher-shortcuts-unavailable"}
        return manager.requestPinShortcut(ShortcutInfo.Builder(ctx,"wish:$work:$action").setShortLabel((row["label"] as String).take(40)).setIcon(Icon.createWithResource(ctx,R.drawable.ic_wish_launcher)).setIntent(entry(ctx,work,action)).build(),null)
    }
    fun pinWidget(ctx:Context,work:String,action:String?):Boolean {
        WishDeviceStore.check(work)
        val manager=ctx.getSystemService(AppWidgetManager::class.java)
        check(manager.isRequestPinAppWidgetSupported){"launcher-widgets-unavailable"}
        val callback=PendingIntent.getBroadcast(ctx,work.hashCode(),Intent(ctx,WishWidgetPinReceiver::class.java).setAction("wish.pin").putExtra("work",work).putExtra("actionId",action),PendingIntent.FLAG_UPDATE_CURRENT or (if(Build.VERSION.SDK_INT>=31)PendingIntent.FLAG_MUTABLE else 0))
        return manager.requestPinAppWidget(ComponentName(ctx,WishWidget::class.java),Bundle(),callback)
    }
}
class WishEntryActivity:Activity(){
    override fun onCreate(state:Bundle?){super.onCreate(state)
        val work=intent.getStringExtra("work")
        if(work!=null&&runCatching{WishDeviceStore.check(work)}.isSuccess){
            startActivity(Intent(this,MainActivity::class.java).setAction("wish.entry").putExtra("wishProject",work).putExtra("wishAction",intent.getStringExtra("actionId")).putExtra("wishEntryToken",WishEntries.token).putExtra("wishSourcePackage",intent.getStringExtra("sourcePackage")).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP))
        };finish()
    }
}
class WishTile:TileService(){
    override fun onStartListening(){super.onStartListening();qsTile?.apply{label="dsh-wish";state=android.service.quicksettings.Tile.STATE_INACTIVE;updateTile()}}
    override fun onClick(){super.onClick()
        val work=getSharedPreferences("wish-entry-v1",0).getString("selected",null)
        if(work!=null&&android.provider.Settings.canDrawOverlays(this)){WishActionOverlay.show(this,work,userInitiated=true);return}
        val intent=Intent(this,MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        if(Build.VERSION.SDK_INT>=34)startActivityAndCollapse(PendingIntent.getActivity(this,0,intent,PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))else @Suppress("DEPRECATION") startActivityAndCollapse(intent)
    }
}
class WishWidget:AppWidgetProvider(){
    override fun onUpdate(ctx:Context,manager:AppWidgetManager,ids:IntArray){ids.forEach{update(ctx,it)}}
    override fun onDeleted(ctx:Context,ids:IntArray){val p=ctx.getSharedPreferences("wish-widget-v1",0);ids.forEach{p.edit().remove("work:$it").remove("action:$it").apply()}}
    companion object{
        fun update(ctx:Context,id:Int){
            val prefs=ctx.getSharedPreferences("wish-widget-v1",0);val work=prefs.getString("work:$id",null)
            val views=RemoteViews(ctx.packageName,R.layout.wish_widget)
            val data=work?.let{runCatching{WishWorkStore.get(ctx,it)}.getOrNull()}
            val title=(data?.get("customName") as? String)?.takeIf{it.isNotBlank()} ?: data?.get("title") as? String ?: "dsh-wish"
            views.setTextViewText(R.id.wish_widget_title,title)
            val snapshot=if(work!=null)JSONObjectOrEmpty(prefs.getString("snapshot:$work",null)) else emptyMap()
            views.setTextViewText(R.id.wish_widget_value,snapshot["value"] as? String ?: ctx.getString(R.string.wish_widget_open))
            val intent=if(work!=null)WishEntries.entry(ctx,work,prefs.getString("action:$id",null))else Intent(ctx,MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.wish_widget_root,PendingIntent.getActivity(ctx,id,intent,PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
            AppWidgetManager.getInstance(ctx).updateAppWidget(id,views)
        }
        private fun JSONObjectOrEmpty(s:String?):Map<String,Any?> = runCatching{WishWorkStore.map(org.json.JSONObject(s?:"{}"))}.getOrDefault(emptyMap())
        fun snapshot(ctx:Context,work:String,value:String){WishDeviceStore.check(work);require(value.length<=300);ctx.getSharedPreferences("wish-widget-v1",0).edit().putString("snapshot:$work",org.json.JSONObject(mapOf("value" to value,"at" to System.currentTimeMillis())).toString()).commit();AppWidgetManager.getInstance(ctx).getAppWidgetIds(ComponentName(ctx,WishWidget::class.java)).forEach{update(ctx,it)}}
    }
}
class WishWidgetPinReceiver:BroadcastReceiver(){
    override fun onReceive(ctx:Context,intent:Intent){val id=intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID,-1);val work=intent.getStringExtra("work")?:return;if(id<0||runCatching{WishDeviceStore.check(work)}.isFailure)return
        ctx.getSharedPreferences("wish-widget-v1",0).edit().putString("work:$id",work).putString("action:$id",intent.getStringExtra("actionId")).commit();WishWidget.update(ctx,id)
    }
}
