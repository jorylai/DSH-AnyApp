package io.github.ccch1mneyyy.dsh_app.wish
import android.app.*
import android.content.*
import android.content.pm.ServiceInfo
import android.os.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.FlutterInjector
import io.flutter.plugin.common.MethodChannel
import io.github.ccch1mneyyy.dsh_app.R

object AnyappTaskBridge {
    private val channels=linkedMapOf<Any,MethodChannel>()
    var onReady:(()->Unit)?=null
    fun ready(owner:Any,channel:MethodChannel){channels[owner]=channel;onReady?.invoke()}
    fun detach(owner:Any){channels.remove(owner)}
    fun latest():MethodChannel?=channels.values.lastOrNull()
    fun call(method:String,args:Any?,result:MethodChannel.Result):Boolean {val channel=channels.values.lastOrNull()?:return false;channel.invokeMethod(method,args,result);return true}
}
class AnyappTaskService:Service(){
    private var engine:FlutterEngine?=null
    private var wake:PowerManager.WakeLock?=null
    private var job:Map<String,Any?>?=null
    private var dispatched=false
    private var workerChannel:MethodChannel?=null
    private val main=Handler(Looper.getMainLooper())
    private val timeout=Runnable{val active=job?:return@Runnable;cancel(active["work"] as String,active["id"] as String);finish("interrupted","")}
    override fun onBind(i:Intent?):IBinder?=null
    override fun onCreate(){super.onCreate();current=this;val nm=getSystemService(NotificationManager::class.java);nm.createNotificationChannel(NotificationChannel("anyapp-background-v1","DSH AnyApp",NotificationManager.IMPORTANCE_LOW))}
    override fun onStartCommand(i:Intent?,flags:Int,startId:Int):Int {
        val work=i?.getStringExtra("work");val taskId=i?.getStringExtra("id")
        val openIntent=Intent(this,io.github.ccch1mneyyy.dsh_app.MainActivity::class.java).putExtra("wishProject",work).putExtra("wishDestination","background").addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val open=PendingIntent.getActivity(this,4071,openIntent,PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val stop=PendingIntent.getBroadcast(this,4071,Intent(this,AnyappJobReceiver::class.java).setAction("anyapp.cancel").putExtra("work",work).putExtra("id",taskId),PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val english=io.github.ccch1mneyyy.dsh_app.i18n.AppStrings.isEnglish(this)
        val notification=Notification.Builder(this,"anyapp-background-v1").setSmallIcon(R.drawable.ic_stat_dsh).setLargeIcon(AnyappBrand.bitmap(this)).setContentTitle("DSH AnyApp").setContentText(if(english)"Running your background task" else "正在处理你的后台任务").setContentIntent(open).setVisibility(Notification.VISIBILITY_PRIVATE).addAction(Notification.Action.Builder(null,if(english)"Stop" else "停止",stop).build()).setOngoing(true).build()
        if(Build.VERSION.SDK_INT>=34)startForeground(4071,notification,ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)else startForeground(4071,notification)
        val w=i?.getStringExtra("work");val id=i?.getStringExtra("id");if(w==null||id==null){stopSelf();return START_NOT_STICKY}
        val next=AnyappTasks.claim(this,w,id);if(next==null){if(job==null)stopSelf();return START_NOT_STICKY}
        if(job!=null){AnyappTasks.finish(this,next,"waiting-resource");return START_NOT_STICKY}
        job=next;wake=getSystemService(PowerManager::class.java).newWakeLock(PowerManager.PARTIAL_WAKE_LOCK,"dshAnyapp:job").apply{setReferenceCounted(false);acquire(22*60000L)}
        AnyappTaskBridge.onReady={pump()};main.postDelayed(timeout,21*60000L)
        if(!pump()){
            val loader=FlutterInjector.instance().flutterLoader();loader.startInitialization(applicationContext);loader.ensureInitializationComplete(applicationContext,null)
            engine=FlutterEngine(applicationContext).also{e->e.plugins.add(io.github.ccch1mneyyy.dsh_app.runtime.RuntimePlugin());e.plugins.add(io.github.ccch1mneyyy.dsh_app.phone.PhonePlugin());e.plugins.add(WishDevicePlugin());e.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint(loader.findAppBundlePath(),"anyappBackground"))}
            main.postDelayed({if(!dispatched)finish("failed","")},30000)
        }
        return START_NOT_STICKY
    }
    private fun pump():Boolean {
        if(dispatched)return true
        val active=job?:return false
        val channel=AnyappTaskBridge.latest()?:return false
        workerChannel=channel
        channel.invokeMethod("scheduledJob",active,object:MethodChannel.Result{
            override fun success(value:Any?){val row=value as? Map<*,*>;val phase=row?.get("phase") as? String ?: "failed";finish(if(phase in setOf("succeeded","failed","stopped","interrupted","waiting-resource"))phase else "failed",row?.get("text") as? String ?: "")}
            override fun error(code:String,message:String?,details:Any?){finish("failed","")}
            override fun notImplemented(){finish("failed","")}
        });dispatched=true;return true
    }
    fun cancel(work:String,id:String){val active=job?:return;if(active["work"]!=work||active["id"]!=id)return;if(!dispatched){finish("stopped","");return};workerChannel?.invokeMethod("cancelScheduledJob",active,object:MethodChannel.Result{override fun success(v:Any?){finish("stopped","")};override fun error(c:String,m:String?,d:Any?){finish("interrupted","")};override fun notImplemented(){finish("interrupted","")}})}
    private fun finish(phase:String,text:String){val active=job?:return;job=null;AnyappTasks.finish(this,active,phase,text);stopForeground(STOP_FOREGROUND_REMOVE);stopSelf()}
    override fun onDestroy(){main.removeCallbacksAndMessages(null);job?.let{AnyappTasks.finish(this,it,"interrupted","")};job=null;AnyappTaskBridge.onReady=null;engine?.destroy();engine=null;wake?.let{if(it.isHeld)it.release()};wake=null;if(current===this)current=null;super.onDestroy()}
    companion object {var current:AnyappTaskService?=null;private set}
}
