package com.perol.pixez.plugin

//import androidx.webkit.ProxyConfig
//import androidx.webkit.ProxyController
//import androidx.webkit.WebViewFeature
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object Weiss {
    private const val WEISS_CHANNEL = "com.perol.dev/weiss"
    private const val TAG = "weiss"
    var port = "9876"

    fun bindChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WEISS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val p = call.argument<String>("port")
                    val map = call.argument<String>("map") ?: ""
                    port = p ?: "9876"
                    start(map)
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

    fun start(json: String) {
//        try {
//            weiss.Weiss.start(port, json)
//        } catch (e: Throwable) {
//        }
    }

    fun stop() {
//        try {
//            weiss.Weiss.close()
//        } catch (e: Throwable) {
//        }
    }

    fun proxy() {
//        if (WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)) {
//            val proxyUrl = "127.0.0.1:$port"
//            val proxyConfig: ProxyConfig = ProxyConfig.Builder()
//                    .addProxyRule(proxyUrl)
//                    .addDirect()
//                    .build()
//            ProxyController.getInstance().setProxyOverride(proxyConfig, { command -> command?.run() }, { android.util.Log.w("d", "WebView proxy") })
//        } else {
//        }
    }
}