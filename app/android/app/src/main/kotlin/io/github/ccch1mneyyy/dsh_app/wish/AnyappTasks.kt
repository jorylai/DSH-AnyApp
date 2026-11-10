package io.github.ccch1mneyyy.dsh_app.wish

import android.app.*
import android.content.*
import android.net.Uri
import android.os.*
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID
import java.time.ZoneId

/** Android owns deadlines; work data and the WebView do not own a job's lifetime. */
object AnyappTasks {
    private fun prefs(c:Context)=c.getSharedPreferences("anyapp-jobs-v1",0)
    private fun rows(c:Context):MutableList<JSONObject>{val a=JSONArray(prefs(c).getString("rows","[]"));return (0 until a.length()).map{a.getJSONObject(it)}.toMutableList()}
    private fun save(c:Context,rows:List<JSONObject>){check(prefs(c).edit().putString("rows",JSONArray(rows).toString()).commit())}
    private fun key(work:String,id:String)="anyapp-job://$work/$id"
    private fun pending(c:Context,w:String,id:String)=PendingIntent.getBroadcast(c,0,Intent(c,AnyappJobReceiver::class.java).setAction("anyapp.run").setData(Uri.parse(key(w,id))).putExtra("work",w).putExtra("id",id),PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    private fun arm(c:Context,row:JSONObject){
        if(!row.optBoolean("enabled"))return
        val at=row.optLong("nextAt");if(at<=0)return
        val manager=c.getSystemService(AlarmManager::class.java);val pi=pending(c,row.getString("work"),row.getString("id"))
        if(WishReminders.exact(c))try{manager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP,at,pi);return}catch(_:SecurityException){}
        manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP,at,pi)
    }
    @Synchronized fun schedule(c:Context,w:String,args:Map<String,Any?>):Map<String,Any?>{
        WishDeviceStore.check(w);check(WishDeviceStore.granted(c,w,"background")){"background-not-authorized"}
        val id=args["id"] as? String ?: UUID.randomUUID().toString();require(Regex("^[a-zA-Z0-9_-]{1,64}$").matches(id))
        val title=args["title"] as? String ?: "";val prompt=args["prompt"] as? String ?: "";require(title.isNotBlank()&&title.length<=100&&prompt.isNotBlank()&&prompt.length<=8000)
        val at=(args["at"] as? Number)?.toLong()?:error("invalid-task-time");require(at>System.currentTimeMillis()&&at<=System.currentTimeMillis()+366L*86400000)
        val repeat=args["repeat"] as? String ?: "none";require(repeat in setOf("none","daily","weekly","interval"))
        val interval=(args["intervalMinutes"] as? Number)?.toInt()?:60;require(interval in 15..10080)
        val zone=ZoneId.of(args["timeZone"] as? String ?: java.util.TimeZone.getDefault().id).id
        val list=rows(c);check(list.count{it.optString("work")==w}<32||list.any{it.optString("work")==w&&it.optString("id")==id}){"background-task-limit"}
        check(list.none{it.optString("work")==w&&it.optString("id")==id&&it.optString("phase")=="running"}){"background-task-running"}
        val row=JSONObject(mapOf("work" to w,"id" to id,"title" to title,"prompt" to prompt,"anchor" to at,"nextAt" to at,"repeat" to repeat,"intervalMinutes" to interval,"timeZone" to zone,"phone" to (args["phone"]==true),"phase" to "scheduled","enabled" to true,"timing" to if(WishReminders.exact(c))"exact" else "inexact"))
        val next=list.filterNot{it.optString("work")==w&&it.optString("id")==id}+row
        save(c,next);try{arm(c,row)}catch(e:Exception){save(c,list);throw e};return WishWorkStore.map(row)
    }
    @Synchronized fun list(c:Context,w:String):List<Map<String,Any?>> = rows(c).filter{it.optString("work")==WishDeviceStore.check(w)}.map{WishWorkStore.map(it).filterKeys{k->k!="work"}}
    @Synchronized fun cancel(c:Context,w:String,id:String){val list=rows(c);list.filter{it.optString("work")==w&&it.optString("id")==id}.forEach{it.put("enabled",false).put("phase","stopped");c.getSystemService(AlarmManager::class.java).cancel(pending(c,w,id))};save(c,list);Handler(Looper.getMainLooper()).post{AnyappTaskService.current?.cancel(w,id)}}
    @Synchronized fun clear(c:Context,w:String){list(c,w).forEach{cancel(c,w,it["id"] as String)};save(c,rows(c).filterNot{it.optString("work")==w})}
    @Synchronized fun claim(c:Context,w:String,id:String):Map<String,Any?>?{
        val list=rows(c);val row=list.find{it.optString("work")==w&&it.optString("id")==id}?:return null
        if(!row.optBoolean("enabled")||row.optString("phase")=="running"||row.optLong("nextAt")>System.currentTimeMillis()+1000)return null
        if(!WishDeviceStore.granted(c,w,"background")){row.put("phase","permission-required");save(c,list);return null}
        if(row.optBoolean("phone")&&(c.getSystemService(KeyguardManager::class.java).isKeyguardLocked||!c.getSystemService(PowerManager::class.java).isInteractive)){
            row.put("phase","waiting-unlock");save(c,list);AnyappEvents.post(c,w,row.getString("title"),if(io.github.ccch1mneyyy.dsh_app.i18n.AppStrings.isEnglish(c))"Unlock the phone to continue this task." else "请亮屏解锁后，在后台任务中继续这项手机操作。",route="background");return null
        }
        row.put("detail","running").put("phase","running").put("runId",UUID.randomUUID().toString()).put("startedAt",System.currentTimeMillis());save(c,list);return WishWorkStore.map(row)
    }
    @Synchronized fun progress(c:Context,w:String,id:String,runId:String,detail:String,session:String?) {
        require(detail in setOf("running","awaiting-confirmation","paused"))
        val list=rows(c);val row=list.find{it.optString("work")==w&&it.optString("id")==id&&it.optString("runId")==runId&&it.optString("phase")=="running"}?:return
        row.put("detail",detail);if(session!=null&&Regex("^session-[a-zA-Z0-9-]{1,80}$").matches(session))row.put("sessionId",session)
        save(c,list)
        if(detail=="awaiting-confirmation")AnyappEvents.post(c,w,row.getString("title"),if(io.github.ccch1mneyyy.dsh_app.i18n.AppStrings.isEnglish(c))"Your task needs a response. Open its conversation to continue." else "任务需要你回应，打开任务对话后可继续。",route="background")
    }
    @Synchronized fun finish(c:Context,job:Map<String,Any?>,phase:String,text:String=""){
        val list=rows(c);val row=list.find{it.optString("work")==job["work"]&&it.optString("id")==job["id"]&&it.optString("runId")==job["runId"]}?:return
        if(row.optString("phase")=="stopped")return
        row.put("phase",phase).put("finishedAt",System.currentTimeMillis()).put("result",text.take(12000))
        if(phase=="waiting-resource"){row.put("nextAt",System.currentTimeMillis()+5*60000)}else{
            val next=AnyappSchedule.next(row.getLong("anchor"),row.getString("timeZone"),row.getString("repeat"),row.optInt("intervalMinutes",60),System.currentTimeMillis())
            row.put("enabled",next!=null).put("nextAt",next?:0)
        }
        save(c,list);arm(c,row)
        if(phase in setOf("succeeded","failed","interrupted"))AnyappEvents.post(c,row.getString("work"),row.getString("title"),if(text.isNotBlank())text.take(4000)else if(io.github.ccch1mneyyy.dsh_app.i18n.AppStrings.isEnglish(c))"Task $phase. Open to review." else if(phase=="succeeded")"任务已完成，打开查看结果。" else "任务未完成，打开查看并重试。",route="background")
    }
    @Synchronized fun runNow(c:Context,w:String,id:String){val list=rows(c);val row=list.find{it.optString("work")==w&&it.optString("id")==id}?:error("task-not-found");check(row.optString("phase")!="running"){"background-task-running"};row.put("enabled",true).put("nextAt",System.currentTimeMillis()).put("phase","scheduled");save(c,list);launch(c,w,id)}
    fun launch(c:Context,w:String,id:String){val intent=Intent(c,AnyappTaskService::class.java).putExtra("work",w).putExtra("id",id);try{if(Build.VERSION.SDK_INT>=26)c.startForegroundService(intent)else c.startService(intent)}catch(_:Exception){markBlocked(c,w,id)}}
    @Synchronized private fun markBlocked(c:Context,w:String,id:String){val list=rows(c);list.find{it.optString("work")==w&&it.optString("id")==id}?.put("phase","waiting-system");save(c,list);AnyappEvents.post(c,w,"DSH AnyApp",if(io.github.ccch1mneyyy.dsh_app.i18n.AppStrings.isEnglish(c))"Open the app to resume the scheduled task." else "系统暂未允许后台启动，打开应用后可继续这项任务。",route="background")}
    @Synchronized fun restore(c:Context){val list=rows(c);list.forEach{if(it.optString("phase")=="running"){
            it.put("phase","interrupted");val next=AnyappSchedule.next(it.getLong("anchor"),it.getString("timeZone"),it.getString("repeat"),it.optInt("intervalMinutes",60),System.currentTimeMillis());it.put("enabled",next!=null).put("nextAt",next?:0)
        };if(it.optBoolean("enabled")&&it.optLong("nextAt")>0){if(it.optLong("nextAt")<System.currentTimeMillis())it.put("nextAt",System.currentTimeMillis()+60000);arm(c,it)}};save(c,list)}
}
class AnyappJobReceiver:BroadcastReceiver(){override fun onReceive(c:Context,i:Intent){if(i.action=="anyapp.cancel"){val w=i.getStringExtra("work")?:return;val id=i.getStringExtra("id")?:return;AnyappTasks.cancel(c,w,id)}else if(i.action=="anyapp.run"){val w=i.getStringExtra("work")?:return;val id=i.getStringExtra("id")?:return;AnyappTasks.launch(c,w,id)}else AnyappTasks.restore(c)}}
