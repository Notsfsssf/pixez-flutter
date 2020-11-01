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
import android.util.Log
import android.widget.RemoteViews
import com.bumptech.glide.Glide
import com.bumptech.glide.load.model.GlideUrl
import com.bumptech.glide.load.model.LazyHeaders
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.bumptech.glide.request.RequestOptions
import com.bumptech.glide.request.target.SimpleTarget
import com.bumptech.glide.request.transition.Transition
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain


/**
 * Implementation of App Widget functionality.
 */
class CardAppWidget : AppWidgetProvider(), MethodChannel.Result {

    companion object {
        private var channel: MethodChannel? = null;
        private const val WIDGET_PREFERENCES_KEY = "widget_preferences"
        private const val WIDGET_HANDLE_KEY = "handle"

        const val CHANNEL = "com.example.app/widget"
        const val NO_HANDLE = -1L

        fun setHandle(context: Context, handle: Long) {
            context.getSharedPreferences(
                    WIDGET_PREFERENCES_KEY,
                    Context.MODE_PRIVATE
            ).edit().apply {
                putLong(WIDGET_HANDLE_KEY, handle)
                apply()
            }
        }

        fun getRawHandle(context: Context): Long {
            return context.getSharedPreferences(
                    WIDGET_PREFERENCES_KEY,
                    Context.MODE_PRIVATE
            ).getLong(WIDGET_HANDLE_KEY, NO_HANDLE)
        }
    }

    private lateinit var context: Context
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        this.context = context
        init()
        for (appWidgetId in appWidgetIds) {
            channel?.invokeMethod("update", appWidgetId, this)
        }
    }

    override fun onEnabled(context: Context) {
    }

    override fun onDisabled(context: Context) {
    }

    private fun init() {
        if (channel == null) {
            FlutterMain.startInitialization(context)
            FlutterMain.ensureInitializationComplete(context, arrayOf())
            val handle = getRawHandle(context)
            if (handle == NO_HANDLE) {
                return
            }
            val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(handle)
            val entryPointFunctionName = callbackInfo.callbackName
            val engine = FlutterEngine(context.applicationContext)
            val entryPoint = DartExecutor.DartEntrypoint(FlutterMain.findAppBundlePath(), entryPointFunctionName)
            engine.dartExecutor.executeDartEntrypoint(entryPoint)
            engine.plugins.add(io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin())
            engine.plugins.add(com.tekartik.sqflite.SqflitePlugin())
            channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
            Log.d("w", "success initializeFlutter")
        }
    }

    override fun success(result: Any?) {
        result ?: return
        val args = result as HashMap<*, *>
        val code = args["code"] as Int
        if (code == 400) {
            val message = args["message"] as String?
            Log.d("update error", "message=$message")
            return
        }
        val id = args["id"] as Int
        val iId = args["iid"] as Int
        val value = args["value"] as String
        Log.d("w", "success${iId}")
        updateWidget(context, value, id, iId)
    }

    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
    }

    override fun notImplemented() {
    }
}

internal fun updateWidget(context: Context, url: String, appWidgetId: Int, iId: Int?) {
    val views = RemoteViews(context.packageName, R.layout.card_app_widget)
    val manager = AppWidgetManager.getInstance(context)
    try {
        val glideUrl = GlideUrl(url, LazyHeaders.Builder()
                .addHeader("referer", "https://app-api.pixiv.net/")
                .addHeader("User-Agent", "PixivIOSApp/5.8.0")
                .build())
        Glide.with(context)
                .asBitmap()
                .load(glideUrl)
                .apply(RequestOptions.bitmapTransform(RoundedCorners(20)))
                .into(object :SimpleTarget<Bitmap>() {
                    override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                        views.setImageViewBitmap(R.id.appwidget_image, resource)
                        val intent = Intent(context, IntentActivity::class.java).apply {
                            putExtra("iid", iId)
                            setPackage("com.perol.pixez")
                        }
                        val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
                        views.setOnClickPendingIntent(R.id.appwidget_image, pendingIntent)
                        manager.updateAppWidget(appWidgetId, views)
                    }
                });
    } catch (throwable: Throwable) {
        Log.d("throw", "Throwable=" + throwable.message)
    }

}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    val views = RemoteViews(context.packageName, R.layout.card_app_widget)
    appWidgetManager.updateAppWidget(appWidgetId, views)
}