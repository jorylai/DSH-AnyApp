package io.github.ccch1mneyyy.dsh_app.wish

import android.Manifest
import android.app.Activity
import android.content.*
import android.content.pm.PackageManager
import android.location.*
import android.net.Uri
import android.os.*
import android.provider.CalendarContract
import android.provider.OpenableColumns
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.speech.tts.TextToSpeech
import android.util.Base64
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.time.ZoneId
import java.util.*
import java.util.concurrent.Executors

/** Bounded, work-scoped adapters. System permissions remain Android-owned. */
class WishLife(private val ctx: Context, private val activity: () -> Activity?) {
    private val main = Handler(Looper.getMainLooper())
    private val io = Executors.newSingleThreadExecutor()
    private var pending: MethodChannel.Result? = null
    private var pendingMethod: String? = null
    private var exportBytes: ByteArray? = null
    private var tts: TextToSpeech? = null
    private var speaking = false
    fun status(): Map<String, Any?> = mapOf(
        "speechRecognition" to SpeechRecognizer.isRecognitionAvailable(ctx),
        "speechSynthesis" to ctx.packageManager.queryIntentServices(Intent(TextToSpeech.Engine.INTENT_ACTION_TTS_SERVICE), 0).isNotEmpty(),
        "calendarRead" to has(Manifest.permission.READ_CALENDAR), "calendarWrite" to has(Manifest.permission.WRITE_CALENDAR),
        "location" to (has(Manifest.permission.ACCESS_COARSE_LOCATION) || has(Manifest.permission.ACCESS_FINE_LOCATION)),
        "notificationListener" to androidx.core.app.NotificationManagerCompat.getEnabledListenerPackages(ctx).contains(ctx.packageName),
        "ocr" to true, "filePicker" to true, "shareReceiver" to true)
    private fun has(p: String) = ctx.checkSelfPermission(p) == PackageManager.PERMISSION_GRANTED
    private fun grant(work: String, capability: String) = check(WishDeviceStore.granted(ctx, work, capability)) { "$capability-work-permission-required" }
    fun handles(method: String) = method.startsWith("calendar.") || method.startsWith("notifications.") || method.startsWith("files.") || method.startsWith("speech.") || method in setOf("location.once", "maps.open", "life.status", "ocr.recognize")
    fun call(method: String, work: String, args: Map<String, Any?>, result: MethodChannel.Result) {
        WishDeviceStore.check(work)
        when {
            method == "life.status" -> result.success(status())
            method == "files.pick" || method == "files.export" || method == "speech.listen" -> picker(method,args,result)
            method == "speech.stop" -> { tts?.stop(); result.success(true) }
            method == "speech.speak" -> speak(args,result)
            method == "location.once" -> { grant(work,"location"); location(result) }
            method == "maps.open" -> {
                val lat=(args["latitude"] as? Number)?.toDouble() ?: error("invalid-location")
                val lon=(args["longitude"] as? Number)?.toDouble() ?: error("invalid-location")
                require(lat.isFinite() && lat in -90.0..90.0 && lon.isFinite() && lon in -180.0..180.0)
                val q=Uri.encode((args["label"] as? String ?: "").take(120))
                activity()?.startActivity(Intent(Intent.ACTION_VIEW,Uri.parse("geo:$lat,$lon?q=$lat,$lon($q)"))) ?: error("activity-unavailable")
                result.success(true)
            }
            method == "ocr.recognize" -> WishOcr.recognize(args,result)
            else -> io.execute {
                try {
                    val out=when(method) {
                        "calendar.list" -> {grant(work,"calendar"); calendarList(args)}
                        "calendar.save" -> {grant(work,"calendar"); calendarSave(work,args)}
                        "calendar.delete" -> {grant(work,"calendar"); calendarDelete(work,args)}
                        "notifications.list" -> {grant(work,"notifications"); WishNotifications.list(ctx,work)}
                        else -> error("unsupported-life-method")
                    }
                    main.post{result.success(out)}
                } catch(e:Exception){main.post{result.error("wish-life",e.message,null)}}
            }
        }
    }
    private fun calendarList(args: Map<String, Any?>): List<Map<String,Any?>> {
        check(has(Manifest.permission.READ_CALENDAR)){"calendar-system-permission-required"}
        val start=(args["from"] as? Number)?.toLong() ?: System.currentTimeMillis()
        val end=(args["to"] as? Number)?.toLong() ?: start+30L*86400000
        require(end>start && end-start<=366L*86400000)
        val uri=CalendarContract.Instances.CONTENT_URI.buildUpon().apply {ContentUris.appendId(this,start);ContentUris.appendId(this,end)}.build()
        val columns=arrayOf("event_id","title","begin","end","eventLocation","eventTimezone")
        val rows=mutableListOf<Map<String,Any?>>()
        ctx.contentResolver.query(uri,columns,null,null,"begin ASC")?.use { c -> while(c.moveToNext()&&rows.size<300) rows+=columns.indices.associate { columns[it] to if(it in setOf(0,2,3)) c.getLong(it) else c.getString(it) } }
        return rows
    }
    private fun calendarSave(work: String,args: Map<String,Any?>): Map<String,Any?> {
        check(has(Manifest.permission.WRITE_CALENDAR)&&has(Manifest.permission.READ_CALENDAR)){"calendar-system-permission-required"}
        val title=args["title"] as? String ?: error("invalid-event-title");require(title.isNotBlank()&&title.length<=200)
        val start=(args["start"] as? Number)?.toLong() ?: error("invalid-event-time")
        val end=(args["end"] as? Number)?.toLong() ?: error("invalid-event-time");require(end>start)
        val zone=ZoneId.of(args["timeZone"] as? String ?: TimeZone.getDefault().id).id
        val calendar=(args["calendarId"] as? Number)?.toLong() ?: ctx.contentResolver.query(CalendarContract.Calendars.CONTENT_URI,arrayOf("_id"),"calendar_access_level>=? AND visible=1",arrayOf("500"),"_id ASC")?.use {if(it.moveToFirst())it.getLong(0)else null} ?: error("no-writable-calendar")
        val prefs=ctx.getSharedPreferences("wish-calendar-v1",0)
        val local=args["id"] as? String ?: UUID.randomUUID().toString(); require(Regex("^[a-zA-Z0-9_-]{1,64}$").matches(local))
        val old=prefs.getLong("$work:$local",-1)
        val rule=args["repeat"] as? String
        if(!rule.isNullOrBlank())require(Regex("^FREQ=(DAILY|WEEKLY|MONTHLY)(;INTERVAL=[1-9][0-9]?)?(;COUNT=[1-9][0-9]{0,2})?$").matches(rule)){"invalid-repeat-rule"}
        val values=ContentValues().apply{put("calendar_id",calendar);put("title",title);put("dtstart",start);put("eventTimezone",zone);put("eventLocation",(args["location"] as? String ?: "").take(500));put("description",(args["description"] as? String ?: "").take(4000))
            if(rule.isNullOrBlank()){put("dtend",end);putNull("rrule");putNull("duration")}else{put("rrule",rule);put("duration","PT${(end-start)/1000}S");putNull("dtend")}}
        val id=if(old>=0){check(ctx.contentResolver.update(ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI,old),values,null,null)==1){"event-no-longer-exists"};old}
            else {val uri=ctx.contentResolver.insert(CalendarContract.Events.CONTENT_URI,values) ?: error("event-save-failed");ContentUris.parseId(uri)}
        check(prefs.edit().putLong("$work:$local",id).commit())
        return mapOf("id" to local,"eventId" to id,"saved" to true,"timeZone" to zone)
    }
    private fun calendarDelete(work: String,args: Map<String,Any?>): Boolean {
        val local=args["id"] as? String ?: error("invalid-event-id")
        val p=ctx.getSharedPreferences("wish-calendar-v1",0);val id=p.getLong("$work:$local",-1)
        require(id>=0){"event-not-owned-by-work"}
        ctx.contentResolver.delete(ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI,id),null,null)
        p.edit().remove("$work:$local").commit();return true
    }
    private fun picker(method: String,args: Map<String,Any?>,result: MethodChannel.Result) {
        val act=activity() ?: error("activity-unavailable");check(pending==null){"system-picker-busy"}
        val intent=when(method){
            "speech.listen" -> {check(SpeechRecognizer.isRecognitionAvailable(ctx)){"speech-service-unavailable"}; Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply{putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);putExtra(RecognizerIntent.EXTRA_LANGUAGE,args["language"] as? String ?: Locale.getDefault().toLanguageTag())}}
            "files.export" -> {
                val data=args["data"] as? String ?: error("invalid-export-data");require(data.length<=2800000)
                exportBytes=Base64.decode(data,Base64.DEFAULT)
                Intent(Intent.ACTION_CREATE_DOCUMENT).apply{type=(args["mime"] as? String ?: "application/octet-stream");addCategory(Intent.CATEGORY_OPENABLE);putExtra(Intent.EXTRA_TITLE,(args["name"] as? String ?: "export.json").replace(Regex("[/\\\\]"),"_").take(120))}
            }
            else -> Intent(Intent.ACTION_OPEN_DOCUMENT).apply{type=args["mime"] as? String ?: "*/*";addCategory(Intent.CATEGORY_OPENABLE);addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)}
        }
        pending=result;pendingMethod=method
        try {act.startActivityForResult(intent,7312)}catch(e:Exception){pending=null;pendingMethod=null;exportBytes=null;throw e}
    }
    fun onActivityResult(code: Int,status: Int,data: Intent?): Boolean {
        if(code!=7312)return false
        val result=pending ?: return true;val method=pendingMethod;val bytes=exportBytes;pending=null;pendingMethod=null;exportBytes=null
        if(status!=Activity.RESULT_OK){result.success(null);return true}
        if(method=="speech.listen"){result.success(mapOf("text" to data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.firstOrNull().orEmpty()));return true}
        val uri=data?.data ?: run{result.error("wish-file","missing-file",null);return true}
        io.execute {try {
            val out:Any=if(method=="files.export") {ctx.contentResolver.openOutputStream(uri,"wt")?.use{it.write(bytes?:ByteArray(0))} ?: error("export-failed");mapOf("saved" to true)} else {
                val content=ctx.contentResolver.openInputStream(uri)?.use{stream -> val out=java.io.ByteArrayOutputStream();val buffer=ByteArray(8192);while(out.size()<=2000000){val count=stream.read(buffer,0,minOf(buffer.size,2000001-out.size()));if(count<0)break;out.write(buffer,0,count)};out.toByteArray()} ?: error("file-read-failed");require(content.size<=2000000){"file-exceeds-2mb"}
                val name=ctx.contentResolver.query(uri,arrayOf(OpenableColumns.DISPLAY_NAME),null,null,null)?.use{if(it.moveToFirst())it.getString(0)else "file"} ?: "file"
                mapOf("name" to name,"mime" to ctx.contentResolver.getType(uri),"data" to Base64.encodeToString(content,Base64.NO_WRAP),"size" to content.size)
            };main.post{result.success(out)}
        }catch(e:Exception){main.post{result.error("wish-file",e.message,null)}}};return true
    }
    private fun speak(args:Map<String,Any?>,result:MethodChannel.Result){
        val text=args["text"] as? String ?: error("invalid-speech");require(text.length in 1..10000)
        check(!speaking){"speech-initializing"};speaking=true
        fun play(){speaking=false; val engine=tts ?: return result.error("wish-speech","tts-unavailable",null)
            val lang=Locale.forLanguageTag(args["language"] as? String ?: Locale.getDefault().toLanguageTag());val status=engine.setLanguage(lang)
            if(status<0){result.error("wish-speech","tts-language-unavailable",null);return}
            result.success(mapOf("started" to (engine.speak(text,TextToSpeech.QUEUE_FLUSH,null,UUID.randomUUID().toString())==TextToSpeech.SUCCESS))) }
        if(tts!=null)play() else tts=TextToSpeech(ctx){status->main.post{if(status==TextToSpeech.SUCCESS)play()else{speaking=false;tts?.shutdown();tts=null;result.error("wish-speech","tts-unavailable",null)}}}
    }
    private fun location(result:MethodChannel.Result){
        check(has(Manifest.permission.ACCESS_COARSE_LOCATION)||has(Manifest.permission.ACCESS_FINE_LOCATION)){"location-system-permission-required"}
        val manager=ctx.getSystemService(LocationManager::class.java)
        val provider=if(manager.isProviderEnabled(LocationManager.NETWORK_PROVIDER))LocationManager.NETWORK_PROVIDER else if(has(Manifest.permission.ACCESS_FINE_LOCATION)&&manager.isProviderEnabled(LocationManager.GPS_PROVIDER))LocationManager.GPS_PROVIDER else error("location-provider-unavailable")
        var done=false
        val listener=object:LocationListener{
            override fun onLocationChanged(location:Location){if(done)return;done=true;manager.removeUpdates(this);result.success(mapOf("latitude" to location.latitude,"longitude" to location.longitude,"accuracy" to location.accuracy.toDouble(),"at" to location.time,"provider" to location.provider))}
            override fun onProviderDisabled(provider:String){};override fun onProviderEnabled(provider:String){};override fun onStatusChanged(provider:String?,status:Int,extras:Bundle?){}
        }
        manager.requestSingleUpdate(provider,listener,Looper.getMainLooper())
        main.postDelayed({if(!done){done=true;manager.removeUpdates(listener);result.error("wish-location","location-timeout",null)}},25000)
    }
}
