package com.perol.pixez

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain

/**
 * Implementation of App Widget functionality.
 */
class CardAppWidget : AppWidgetProvider(), MethodChannel.Result {

    companion object {
        private var channel: MethodChannel? = null;
    }

    private lateinit var context: Context
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        this.context = context
        // There may be multiple widgets active, so update all of them
        initializeFlutter()
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
            // Pass over the id so we can update it later...
            channel?.invokeMethod("update", appWidgetId, this)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    private fun initializeFlutter() {
        if (channel == null) {
            FlutterMain.startInitialization(context)
            FlutterMain.ensureInitializationComplete(context, arrayOf())

            val handle = WidgetHelper.getRawHandle(context)
            if (handle == WidgetHelper.NO_HANDLE) {
                return
            }

            val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(handle)
            // You could also use a hard coded value to save you from all
            // the hassle with SharedPreferences, but alas when running your
            // app in release mode this would fail.
            val entryPointFunctionName = callbackInfo.callbackName

            // Instantiate a FlutterEngine.
            val engine = FlutterEngine(context.applicationContext)
            val entryPoint = DartExecutor.DartEntrypoint(FlutterMain.findAppBundlePath(), entryPointFunctionName)
            engine.dartExecutor.executeDartEntrypoint(entryPoint)

            // Register Plugins when in background. When there
            // is already an engine running, this will be ignored (although there will be some
            // warnings in the log).
            GeneratedPluginRegistrant.registerWith(engine)

            channel = MethodChannel(engine.dartExecutor.binaryMessenger, WidgetHelper.CHANNEL)
        }
    }

    override fun success(result: Any?) {
        val args = result as HashMap<*, *>
        val id = args["id"] as Int
        val value = args["value"] as ByteArray

//        updateWidget("onDart $value", id, context)
        updateWidget(context, value, id)
    }

    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
    }

    override fun notImplemented() {
    }
}

internal fun updateWidget(context: Context, byteArray: ByteArray, appWidgetId: Int) {
    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.card_app_widget)
    val bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.lastIndex)
    views.setImageViewBitmap(R.id.appwidget_image, bitmap)
    val manager = AppWidgetManager.getInstance(context)
    // Instruct the widget manager to update the widget
    manager.updateAppWidget(appWidgetId, views)
}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.card_app_widget)
//    views.setImageViewBitmap(R.id.appwidget_image, BitmapFactory.decodeResource(context.resources,R.drawable.ic_baseline_folder_open_24))

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}