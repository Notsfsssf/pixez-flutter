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

//Use glance
//package com.perol.pixez
//
//import android.app.PendingIntent
//import android.appwidget.AppWidgetManager
//import android.appwidget.AppWidgetProvider
//import android.content.Context
//import android.content.Intent
//import android.graphics.Bitmap
//import android.os.Build
//import android.widget.RemoteViews
//import com.bumptech.glide.Glide
//import com.bumptech.glide.load.model.GlideUrl
//import com.bumptech.glide.load.model.LazyHeaders
//import com.bumptech.glide.load.resource.bitmap.RoundedCorners
//import com.bumptech.glide.request.RequestOptions
//import com.bumptech.glide.request.target.SimpleTarget
//import com.bumptech.glide.request.transition.Transition
//import org.json.JSONObject
//
///**
// * Implementation of App Widget functionality.
// */
//class CardAppWidget : AppWidgetProvider() {
//
//    override fun onUpdate(
//        context: Context,
//        appWidgetManager: AppWidgetManager,
//        appWidgetIds: IntArray
//    ) {
//        for (appWidgetId in appWidgetIds) {
//            val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"
//            val sharedPreferences =
//                context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
//            val data = sharedPreferences.getString("flutter.app_widget_data", null)
//            val host = sharedPreferences.getString("flutter.picture_source", null)
//            data?.let {
//                try {
//                    val time = sharedPreferences.getLong("flutter.app_widget_time", 0)
//                    val jsonData = JSONObject(it)
//                    val jsonArray = jsonData.getJSONArray("illusts")
//                    val jsonObject = jsonArray.getJSONObject((0 until jsonArray.length()).random())
//                    updateWidget(
//                        context,
//                        jsonObject.getJSONObject("image_urls").getString("square_medium"),
//                        appWidgetId,
//                        jsonObject.getInt("id"),
//                        host
//                    )
//                    if (time < 10)
//                        sharedPreferences.edit().putLong("flutter.app_widget_time", time + 1)
//                            .apply()
//                    else {
//                        sharedPreferences.edit().remove("flutter.app_widget_time").apply()
//                        sharedPreferences.edit().remove("flutter.app_widget_data").apply()
//                    }
//                } catch (e: Throwable) {
//                    sharedPreferences.edit().remove("flutter.app_widget_data").apply()
//                    io.flutter.Log.d("Card app widget", e.toString())
//                }
//
//            }
//        }
//    }
//
//    override fun onEnabled(context: Context) {
//    }
//
//    override fun onDisabled(context: Context) {
//    }
//
//}
//
//internal fun updateWidget(
//    context: Context,
//    url: String,
//    appWidgetId: Int,
//    iId: Int?,
//    host: String?
//) {
//    val views = RemoteViews(context.packageName, R.layout.card_app_widget)
//    val manager = AppWidgetManager.getInstance(context)
//    try {
//        val trueUrl = if (host != null) {
//            url.replace("i.pximg.net", host)
//        } else {
//            url
//        }
//        val glideUrl = GlideUrl(
//            trueUrl, LazyHeaders.Builder()
//                .addHeader("referer", "https://app-api.pixiv.net/")
//                .addHeader("User-Agent", "PixivIOSApp/5.8.0")
//                .build()
//        )
//        Glide.with(context)
//            .asBitmap()
//            .load(glideUrl)
//            .apply(RequestOptions.bitmapTransform(RoundedCorners(20)))
//            .into(object : SimpleTarget<Bitmap>() {
//                override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
//                    views.setImageViewBitmap(R.id.appwidget_image, resource)
//                    val intent = Intent(context, IntentActivity::class.java).apply {
//                        putExtra("iid", iId)
//                    }
//                    val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                        PendingIntent.getActivity(
//                            context,
//                            url.hashCode(),
//                            intent,
//                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
//                        )
//                    } else {
//                        PendingIntent.getActivity(
//                            context,
//                            url.hashCode(),
//                            intent,
//                            PendingIntent.FLAG_UPDATE_CURRENT
//                        )
//                    }
//                    views.setOnClickPendingIntent(R.id.appwidget_image, pendingIntent)
//                    manager.updateAppWidget(appWidgetId, views)
//                }
//            });
//    } catch (throwable: Throwable) {
//        io.flutter.Log.d("Card app widget", throwable.toString())
//    }
//
//}
