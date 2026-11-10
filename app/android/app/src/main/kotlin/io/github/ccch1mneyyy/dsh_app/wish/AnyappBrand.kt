package io.github.ccch1mneyyy.dsh_app.wish
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import io.github.ccch1mneyyy.dsh_app.R
object AnyappBrand {
    private val images=mutableMapOf<Int,Bitmap>()
    @Synchronized fun bitmap(ctx:Context,size:Int=96):Bitmap {
        images[size]?.let{return it}
        val image=Bitmap.createBitmap(size,size,Bitmap.Config.ARGB_8888)
        ctx.getDrawable(R.drawable.ic_wish_launcher)!!.apply{setBounds(0,0,size,size);draw(Canvas(image))}
        images[size]=image;return image
    }
}
