package io.github.ccch1mneyyy.dsh_app.wish

import android.app.Activity
import android.app.AlertDialog
import android.content.*
import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import android.util.Base64
import io.github.ccch1mneyyy.dsh_app.MainActivity
import io.github.ccch1mneyyy.dsh_app.R
import org.json.JSONObject
import java.io.File
import java.util.UUID
import java.util.concurrent.Executors

/** User-routed inbox, separated from both agent instructions and other work namespaces. */
object WishImport {
    private fun dir(ctx:Context,work:String)=File(ctx.filesDir,"wish-imports/${WishDeviceStore.check(work)}").apply{mkdirs()}
    @Synchronized fun save(ctx:Context,work:String,source:Intent):String {
        val root=dir(ctx,work);check((root.listFiles()?.size?:0)<20){"import-inbox-full"}
        val text=(source.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT) ?: source.getCharSequenceExtra(Intent.EXTRA_TEXT))?.toString().orEmpty();require(text.length<=40000){"import-text-too-large"}
        val row=JSONObject().put("id",UUID.randomUUID().toString()).put("at",System.currentTimeMillis()).put("text",text)
        val uri=(source.getParcelableExtra<android.os.Parcelable>(Intent.EXTRA_STREAM) as? Uri) ?: source.clipData?.let{if(it.itemCount>0)it.getItemAt(0).uri else null}
        if(uri!=null){
            require(uri.scheme=="content"){"unsupported-share-uri"}
            val bytes=ctx.contentResolver.openInputStream(uri)?.use {stream->val out=java.io.ByteArrayOutputStream();val buffer=ByteArray(8192);while(out.size()<=2000000){val n=stream.read(buffer,0,minOf(buffer.size,2000001-out.size()));if(n<0)break;out.write(buffer,0,n)};out.toByteArray()} ?: error("shared-file-unreadable")
            require(bytes.size<=2000000){"shared-file-exceeds-2mb"}
            val name=ctx.contentResolver.query(uri,arrayOf(OpenableColumns.DISPLAY_NAME),null,null,null)?.use{if(it.moveToFirst())it.getString(0)else "file"} ?: "file"
            row.put("file",JSONObject(mapOf("name" to name,"mime" to ctx.contentResolver.getType(uri),"size" to bytes.size,"data" to Base64.encodeToString(bytes,Base64.NO_WRAP))))
        }
        require(text.isNotBlank()||row.has("file")){"empty-import"}
        val id=row.getString("id");File(root,"$id.json").writeText(row.toString());return id
    }
    fun list(ctx:Context,work:String):List<Map<String,Any?>> = dir(ctx,work).listFiles()?.sortedByDescending{it.lastModified()}?.take(20)?.map{val row=JSONObject(it.readText());row.optJSONObject("file")?.remove("data");WishWorkStore.map(row)} ?: emptyList()
    fun read(ctx:Context,work:String,id:String):Map<String,Any?>{require(Regex("^[a-f0-9-]{36}$").matches(id));return WishWorkStore.map(JSONObject(File(dir(ctx,work),"$id.json").readText()))}
    fun remove(ctx:Context,work:String,id:String){require(Regex("^[a-f0-9-]{36}$").matches(id));check(File(dir(ctx,work),"$id.json").let{!it.exists()||it.delete()})}
    fun clear(ctx:Context,work:String){dir(ctx,work).deleteRecursively()}
}
class WishImportActivity:Activity(){
    private val io=Executors.newSingleThreadExecutor()
    override fun onCreate(state:Bundle?){super.onCreate(state)
        val works=WishWorkStore.all(this).entries.toList()
        if(works.isEmpty()){AlertDialog.Builder(this).setMessage(R.string.wish_import_no_work).setPositiveButton(android.R.string.ok){_,_->finish()}.setOnCancelListener{finish()}.show();return}
        val names=works.map{val data=it.value as? Map<*,*>;((data?.get("customName") as? String)?.takeIf{it.isNotBlank()} ?: data?.get("title") as? String ?: it.key)}.toTypedArray()
        AlertDialog.Builder(this).setTitle(R.string.wish_import_choose).setItems(names){_,index->
            val work=works[index].key
            io.execute{try{WishImport.save(this,work,intent);runOnUiThread{startActivity(Intent(this,MainActivity::class.java).putExtra("wishProject",work).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP));finish()}}
            catch(_:Exception){runOnUiThread{AlertDialog.Builder(this).setMessage(R.string.wish_import_failed).setPositiveButton(android.R.string.ok){_,_->finish()}.setOnCancelListener{finish()}.show()}}}
        }.setOnCancelListener{finish()}.show()
    }
}
