package com.perol.pixez

import android.content.Context
import android.content.Intent
import androidx.webkit.ProxyConfig
import androidx.webkit.ProxyController
import androidx.webkit.WebViewFeature
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.collections.HashMap

object Weiss {
    private const val WEISS_CHANNEL = "com.perol.dev/weiss"
    var port = "9876"
    var methodChannel: MethodChannel? = null

    fun bindChannel(context: Context, flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WEISS_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "launch" -> {
                    context.launch(call.argument<String>("url")!!)
                }
                "start" -> {
                    start()
                }
                "proxy" -> {
                    proxy()
                }
                "stop" -> {
                    stop()
                }
            }
            result.success(null)
        }
    }

    fun invokeDart(url: String) {
        val obj = HashMap<String, Any>()
        obj["url"] = url
        methodChannel?.invokeMethod("invoke", obj)
    }

    private fun Context.launch(url: String) {
        startActivity(Intent(this, WebViewActivity::class.java).apply {
            putExtra("url", url)
        })
    }

    fun start() {
        try {
            weiss.Weiss.start(port)
        } catch (e: Throwable) {
        }
    }

    fun stop() {
        try {
            weiss.Weiss.close()
        } catch (e: Throwable) {

        }
    }

    fun proxy() {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)) {
            val proxyUrl = "127.0.0.1:${port}"
            val proxyConfig: ProxyConfig = ProxyConfig.Builder()
                    .addProxyRule(proxyUrl)
                    .addDirect()
                    .build()
            ProxyController.getInstance().setProxyOverride(proxyConfig, { command -> command?.run() }, { android.util.Log.w("d", "WebView proxy") })
        } else {
        }
    }
}