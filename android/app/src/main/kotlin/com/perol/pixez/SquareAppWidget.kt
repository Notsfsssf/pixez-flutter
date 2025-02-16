/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

package com.perol.pixez

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.FileProvider
import coil3.DrawableImage
import coil3.Image
import coil3.asDrawable
import coil3.imageLoader
import coil3.network.NetworkHeaders
import coil3.network.httpHeaders
import coil3.request.ImageRequest
import coil3.request.transformations
import coil3.toBitmap
import coil3.transform.RoundedCornersTransformation
import com.perol.pixez.glance.GlanceDBManager
import com.perol.pixez.glance.GlanceIllust
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

/**
 * Implementation of App Widget functionality.
 */
class SquareAppWidget : AppWidgetProvider() {

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
                illust = kotlin.runCatching { glanceDBManager.fetch(context, i) }.getOrNull()
                    ?.randomOrNull()
                if (illust != null)
                    break
            }
            if (illust != null) {
                illust.let {
                    val host = sharedPreferences.getString("flutter.picture_source", null)
                    updateWidget(
                        context,
                        it.pictureUrl,
                        appWidgetId,
                        it.illustId,
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
    url: String,
    appWidgetId: Int,
    iId: Long?,
    host: String?
) {
    val views = RemoteViews(context.packageName, R.layout.card_app_widget)
    val manager = AppWidgetManager.getInstance(context)
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
            .listener(onError = { i, j ->
                io.flutter.Log.e("Card app widget", "url error: ${trueUrl}", j.throwable)
            })
            .size(540, 540)
            .target(object : coil3.target.Target {
                override fun onSuccess(result: Image) {
                    super.onSuccess(result)
                    MainScope().launch {
                        val bitmap = withContext(Dispatchers.IO) {
                            runCatching {
                                val bitmap = result.toBitmap()
                                return@runCatching bitmap
                            }.getOrNull()
                        }
                        if (bitmap != null) {
                            try {
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
                                            url.hashCode(),
                                            intent,
                                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                                        )
                                    } else {
                                        PendingIntent.getActivity(
                                            context,
                                            url.hashCode(),
                                            intent,
                                            PendingIntent.FLAG_UPDATE_CURRENT
                                        )
                                    }
                                views.setOnClickPendingIntent(R.id.appwidget_image, pendingIntent)
                                views.setViewVisibility(
                                    R.id.appwidget_warning_container,
                                    View.GONE
                                )
                                manager.updateAppWidget(appWidgetId, views)
                                io.flutter.Log.d("Card app widget", "url success: ${trueUrl}")
                            } catch (throwable: Throwable) {
                                io.flutter.Log.d("Card app widget", throwable.toString())
                            }
                        }
                    }

                }
            }).build()

        context.imageLoader.enqueue(request)
    } catch (throwable: Throwable) {
        io.flutter.Log.d("Card app widget", throwable.toString())
    }

}
