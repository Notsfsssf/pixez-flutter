package com.perol.pixez.plugin

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.browser.customtabs.CustomTabsIntent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


object CustomTab {
    private const val TAG = "CustomTab"
    private const val CUSTOM_TAB_CHANNEL = "com.perol.dev/custom_tab"

    fun bindChannel(context: Context, flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CUSTOM_TAB_CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "launch" -> {
                            val url = call.argument<String>("url")
                            url?.let {
                                context.launchUrl(it)
                            }
                        }
                    }
                    result.success(null)
                }
    }

    private fun Context.launchUrl(url: String) {
        try {
            val customTabsIntent = CustomTabsIntent.Builder();
            customTabsIntent.build().launchUrl(this, Uri.parse(url));
        } catch (e: Throwable) {
            val uri = Uri.parse(url)
            val intent = Intent(Intent.ACTION_VIEW, uri)
            startActivity(intent)
        }
    }
}