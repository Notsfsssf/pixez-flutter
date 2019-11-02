package com.perol.pixez.plugin

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class SupporterPlugin {
    private val SUPPORTER_CHANNEL = "com.perol.dev/supporter"
    fun bindChannel(activity: FlutterActivity, flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SUPPORTER_CHANNEL
        ).setMethodCallHandler { call, result ->
            activity.apply {
                when (call.method) {
                    "exit" -> {
                        result.success(true)
                        finishAndRemoveTask()
                    }

                    "process_text" -> {
                        try {
                            val queryIntentActivities =
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                    packageManager.queryIntentActivities(
                                        Intent().apply {
                                            type = "text/plain"
                                            action = Intent.ACTION_PROCESS_TEXT
                                        },
                                        PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_DEFAULT_ONLY.toLong())
                                    )
                                } else {
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                        packageManager.queryIntentActivities(
                                            Intent(Intent.ACTION_PROCESS_TEXT).apply {
                                                type = "text/plain"
                                            },
                                            0
                                        )
                                    } else {
                                        packageManager.queryIntentActivities(
                                            Intent(Intent.ACTION_SEND).apply {
                                                type = "text/plain"
                                            },
                                            0
                                        )
                                    }
                                }
                            result.success(queryIntentActivities.isNotEmpty())
                        } catch (ignore: Throwable) {
                            result.success(false)
                        }
                    }

                    "process" -> {
                        val text = call.argument<String>("text")
                        val intent = Intent()
                            .setType("text/plain")
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            intent.action = Intent.ACTION_PROCESS_TEXT
                            intent.putExtra(Intent.EXTRA_PROCESS_TEXT, text)
                        } else {
                            intent.action = Intent.ACTION_SEND
                            intent.putExtra(Intent.EXTRA_TEXT, text)
                        }
                        result.success(0)
                        try {
                            startActivity(intent)
                        } catch (_: Throwable) {
                        }
                    }
                }
            }
        }

    }
}