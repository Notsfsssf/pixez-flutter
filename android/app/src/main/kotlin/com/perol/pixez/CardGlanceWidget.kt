package com.perol.pixez

import android.graphics.Bitmap
import android.util.Log
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.core.graphics.drawable.toBitmap
import androidx.glance.*
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxWidth
import coil.ImageLoader
import coil.request.ImageRequest

class CardGlanceWidget : GlanceAppWidget() {
    companion object {
        private val thinMode = DpSize(120.dp, 120.dp)
        private val smallMode = DpSize(184.dp, 184.dp)
        private val mediumMode = DpSize(260.dp, 200.dp)
        private val largeMode = DpSize(260.dp, 280.dp)
    }

    override val sizeMode: SizeMode = SizeMode.Responsive(
        setOf(thinMode, smallMode, mediumMode, largeMode)
    )

    @Composable
    override fun Content() {
        val size = LocalSize.current
        val context = LocalContext.current
        var bitmap by remember { mutableStateOf<Bitmap?>(null) }

        LaunchedEffect(true) {
            Log.d("glanceglance","load")
            val request = ImageRequest.Builder(context)
                .data("https://img0.baidu.com/it/u=3042924924,309069755&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500")
                .target {
                    bitmap = it.toBitmap()
                    Log.d("glanceglance","loaded")
                }
                .build()
            ImageLoader(context).execute(request)
        }

        Box(
            GlanceModifier
                .fillMaxWidth()
                .fillMaxHeight()
                .background(Color.Yellow)
        ) {
            bitmap?.let {
                Image(provider = ImageProvider(it), contentDescription = "Hi")
            }
        }
    }
}
