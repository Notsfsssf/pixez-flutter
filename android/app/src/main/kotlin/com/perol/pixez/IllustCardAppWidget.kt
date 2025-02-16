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
import androidx.core.graphics.drawable.toBitmap
import androidx.core.widget.RemoteViewsCompat.setImageViewColorFilter
import coil3.Image
import coil3.imageLoader
import coil3.network.NetworkHeaders
import coil3.network.httpHeaders
import coil3.request.ImageRequest
import coil3.request.transformations
import coil3.toBitmap
import coil3.transform.RoundedCornersTransformation
import com.google.android.material.color.MaterialColors
import com.perol.pixez.glance.GlanceDBManager
import com.perol.pixez.glance.GlanceIllust
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

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
            .httpHeaders(
                NetworkHeaders.Builder()
                    .set("referer", "https://app-api.pixiv.net/")
                    .set("User-Agent", "PixivIOSApp/5.8.0")
                    .set("host", Uri.parse(trueUrl).host!!)
                    .build()
            )
            .size(540, 540)
            .listener(onError = { i, j ->
                Log.e("Card app widget", "url error: ${trueUrl}", j.throwable)
            })
            .target(object : coil3.target.Target {
                @SuppressLint("UnspecifiedImmutableFlag")
                override fun onSuccess(result: Image) {
                    Log.d("Card app widget", "url success: ${trueUrl}")
                    MainScope().launch {
                        val bitmap = withContext(Dispatchers.IO) {
                            runCatching {
                                val bitmap = result.toBitmap()
                                return@runCatching bitmap
                            }.getOrNull()
                        }
                        if (bitmap != null) {
                            views.setImageViewBitmap(
                                R.id.appwidget_image,
                                bitmap
                            )
                            val intent = Intent(context, MainActivity::class.java).apply {
                                putExtra("iid", iId)
                            }
                            val pendingIntent =
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
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
                            views.setOnClickPendingIntent(
                                R.id.appwidget_normal_container,
                                pendingIntent
                            )
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
                    }
                }

            })
            .build()
        context.imageLoader.enqueue(request)
    } catch (throwable: Throwable) {
        Log.d("Card app widget", throwable.toString())
    }

}
