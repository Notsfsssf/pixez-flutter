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
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import coil.imageLoader
import coil.request.ImageRequest
import coil.transform.RoundedCornersTransformation
import com.perol.pixez.glance.GlanceDBManager
import com.perol.pixez.glance.GlanceIllust

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
            .setHeader("referer", "https://app-api.pixiv.net/")
            .setHeader("User-Agent", "PixivIOSApp/5.8.0")
            .setHeader("host", Uri.parse(trueUrl).host!!)
            .listener(onError = { i, j ->
                io.flutter.Log.e("Card app widget", "url error: ${trueUrl}", j.throwable)
            })
            .target(object : coil.target.Target {
                override fun onStart(placeholder: Drawable?) {
                    io.flutter.Log.d("Card app widget", "url: ${trueUrl}")
                }

                override fun onSuccess(result: Drawable) {
                    io.flutter.Log.d("Card app widget", "url success: ${trueUrl}")
                    views.setImageViewBitmap(
                        R.id.appwidget_image,
                        (result as? BitmapDrawable)?.bitmap
                    )
                    val intent = Intent(context, IntentActivity::class.java).apply {
                        putExtra("iid", iId)
                    }
                    val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
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
                    views.setViewVisibility(R.id.appwidget_warning_container, View.GONE);
                    manager.updateAppWidget(appWidgetId, views)
                }

                override fun onError(error: Drawable?) {
                }
            })
            .build()
        context.imageLoader.enqueue(request)
    } catch (throwable: Throwable) {
        io.flutter.Log.d("Card app widget", throwable.toString())
    }

}
