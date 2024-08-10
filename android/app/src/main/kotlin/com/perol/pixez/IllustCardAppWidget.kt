package com.perol.pixez

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import androidx.core.widget.RemoteViewsCompat.setImageViewColorFilter
import coil.imageLoader
import coil.request.ImageRequest
import coil.transform.RoundedCornersTransformation
import com.google.android.material.color.MaterialColors
import com.perol.pixez.glance.GlanceDBManager
import com.perol.pixez.glance.GlanceIllust

class IllustCardAppWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"
            val sharedPreferences =
                context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
            val glanceDBManager = GlanceDBManager()
            val type = sharedPreferences.getString("flutter.widget_illust_type", "recom") ?: "recom"
            val typeArray = mutableSetOf(type)
            typeArray.addAll(arrayOf("recom", "rank", "follow_illust"))
            var illust: GlanceIllust? = null
            for (i in typeArray) {
                illust = kotlin.runCatching { glanceDBManager.fetch(context, i).randomOrNull() }
                    .getOrNull()
                if (illust != null)
                    break
            }
            if (illust != null) {
                illust.let {
                    val host = sharedPreferences.getString("flutter.picture_source", null)
                    updateWidget(
                        context,
                        appWidgetManager,
                        appWidgetId,
                        illust,
                        host
                    )
                }
            } else {
                val views = RemoteViews(context.packageName, R.layout.card_app_widget)
                val manager = AppWidgetManager.getInstance(context)
                views.setViewVisibility(R.id.appwidget_warning_title, View.VISIBLE);
                manager.updateAppWidget(appWidgetId, views)
            }
        }
    }

    override fun onEnabled(context: Context) {
    }

    override fun onDisabled(context: Context) {
    }

}

private fun updateWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int,
    illust: GlanceIllust,
    host: String?
) {
    val url = illust.pictureUrl
    val iId = illust.illustId
    val views = RemoteViews(context.packageName, R.layout.illust_app_widget)
    try {
        val trueUrl = if (host != null) {
            url.replace("i.pximg.net", host)
        } else {
            url
        }
        val scale = context.resources.displayMetrics.density
        val dp = 16.0f
        val radius = (dp * scale + 0.5f)
        val request = ImageRequest.Builder(context)
            .data(trueUrl)
            .transformations(RoundedCornersTransformation(radius))
            .size(540, 540)
            .setHeader("referer", "https://app-api.pixiv.net/")
            .setHeader("User-Agent", "PixivIOSApp/5.8.0")
            .setHeader("host", Uri.parse(trueUrl).host!!)
            .listener(onError = { i, j ->
                Log.e("Card app widget", "url error: ${trueUrl}", j.throwable)
            })
            .target(object : coil.target.Target {
                override fun onStart(placeholder: Drawable?) {
                    Log.d("Card app widget", "url: ${trueUrl}")
                }

                @SuppressLint("UnspecifiedImmutableFlag")
                override fun onSuccess(result: Drawable) {
                    Log.d("Card app widget", "url success: ${trueUrl}")
                    views.setImageViewBitmap(
                        R.id.appwidget_image,
                        (result as? BitmapDrawable)?.bitmap
                    )
                    val intent = Intent(context, MainActivity::class.java).apply {
                        putExtra("iid", iId)
                    }
                    val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        PendingIntent.getActivity(
                            context,
                            url.hashCode() + views.hashCode(),
                            intent,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                        )
                    } else {
                        PendingIntent.getActivity(
                            context,
                            url.hashCode() + views.hashCode(),
                            intent,
                            PendingIntent.FLAG_UPDATE_CURRENT
                        )
                    }
                    views.setTextViewText(R.id.appwidget_title, illust.title)
                    views.setTextViewText(R.id.appwidget_subtitle, illust.userName)
                    views.setOnClickPendingIntent(R.id.appwidget_normal_container, pendingIntent)
                    views.setViewVisibility(R.id.appwidget_warning_container, View.GONE)
                    views.setImageViewResource(
                        R.id.appwidget_app_icon,
                        R.mipmap.ic_launcher_foreground
                    )
                    views.setImageViewColorFilter(
                        R.id.appwidget_app_icon,
                        MaterialColors.getColor(
                            context,
                            android.R.attr.colorAccent,
                            Color.BLACK
                        )
                    )
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                }

                override fun onError(error: Drawable?) {
                }
            })
            .build()
        context.imageLoader.enqueue(request)
    } catch (throwable: Throwable) {
        Log.d("Card app widget", throwable.toString())
    }

}
