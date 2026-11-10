package io.github.ccch1mneyyy.dsh_app.wish

import android.graphics.BitmapFactory
import android.util.Base64
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.plugin.common.MethodChannel

object WishOcr {
    fun recognize(args: Map<String, Any?>, result: MethodChannel.Result) {
        val encoded=args["data"] as? String ?: error("ocr-image-required")
        require(encoded.length<=2800000){"ocr-image-too-large"}
        val bytes=Base64.decode(encoded,Base64.DEFAULT)
        val bounds=BitmapFactory.Options().apply{inJustDecodeBounds=true};BitmapFactory.decodeByteArray(bytes,0,bytes.size,bounds)
        require(bounds.outWidth>0&&bounds.outHeight>0){"invalid-ocr-image"}
        val options=BitmapFactory.Options().apply{inSampleSize=1};while(bounds.outWidth/options.inSampleSize>2048||bounds.outHeight/options.inSampleSize>2048)options.inSampleSize*=2
        val bitmap=BitmapFactory.decodeByteArray(bytes,0,bytes.size,options) ?: error("invalid-ocr-image")
        val engine=if(args["script"]=="latin")TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS) else TextRecognition.getClient(ChineseTextRecognizerOptions.Builder().build())
        engine.process(InputImage.fromBitmap(bitmap,0)).addOnSuccessListener { text ->
            result.success(mapOf("text" to text.text,"width" to bitmap.width,"height" to bitmap.height,"local" to true,"blocks" to text.textBlocks.take(200).map{block->
                mapOf("text" to block.text,"bounds" to block.boundingBox?.let{listOf(it.left,it.top,it.right,it.bottom)})}))
        }.addOnFailureListener { result.error("wish-ocr","ocr-recognition-failed",null) }.addOnCompleteListener {engine.close();bitmap.recycle()}
    }
}
