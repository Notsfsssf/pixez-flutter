package com.perol.pixez.plugin

import android.app.Activity
import android.os.Build
import android.view.WindowManager.LayoutParams
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class SecurePlugin(val activity: Activity) {
    private val CHANNEL = "com.perol.dev/secure"

    fun bindChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "configSecureWindow" -> {
                    val secure = call.argument<Boolean>("value")!!
                    if (secure) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            activity.setRecentsScreenshotEnabled(false)
                        }
                        activity.window?.addFlags(LayoutParams.FLAG_SECURE)
                    } else {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            activity.setRecentsScreenshotEnabled(true)
                        }
                        activity.window?.clearFlags(LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                }
            }
        }
    }
}