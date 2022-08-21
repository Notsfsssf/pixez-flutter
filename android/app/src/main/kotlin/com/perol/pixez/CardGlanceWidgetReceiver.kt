package com.perol.pixez

import android.appwidget.AppWidgetManager
import android.content.Context
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import com.perol.pixez.glance.ImageGlanceWidget
import com.perol.pixez.glance.ImageWorker
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class CardGlanceWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget
        get() = ImageGlanceWidget()

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
//        GlobalScope.launch {
//            kotlin.runCatching {
//                val glanceIds =
//                    GlanceAppWidgetManager(context).getGlanceIds(ImageGlanceWidget::class.java)
//                for (glanceId in glanceIds) {
//                    ImageWorker.enqueue(context, DpSize(0.dp, 0.dp), glanceId, true)
//                }
//            }
//        }
    }
}