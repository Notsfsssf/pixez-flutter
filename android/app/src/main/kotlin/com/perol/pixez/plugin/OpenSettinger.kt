package com.perol.pixez.plugin

import android.app.Activity
import android.content.Intent
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object OpenSettinger {
    private const val OPEN_CHANNEL = "com.perol.dev/open"

    fun bindChannel(flutterEngine: FlutterEngine,activity:Activity) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OPEN_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "open" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                           try {
                               val intent = Intent().apply {
                                   action =
                                       android.provider.Settings.ACTION_APP_OPEN_BY_DEFAULT_SETTINGS
                                   addCategory(Intent.CATEGORY_DEFAULT)
                                   data = android.net.Uri.parse("package:${activity.packageName}")
                                   addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
                                   addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
                               }
                               activity.startActivity(intent)
                           } catch (ignored:Throwable) {
                           }
                        }
                }
            }
            result.success(null)
        }
    }
}