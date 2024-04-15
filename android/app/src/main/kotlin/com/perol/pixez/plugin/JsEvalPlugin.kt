package com.perol.pixez.plugin

import android.annotation.SuppressLint
import android.app.Activity
import android.webkit.WebView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.lastOrNull
import kotlinx.coroutines.launch

@SuppressLint("SetJavaScriptEnabled")
class JsEvalPlugin(val activity: Activity) {
    val webview by lazy {
        WebView(activity).also {
            it.settings.javaScriptEnabled = true
        }
    }

    private val CHANNEL = "com.perol.dev/eval"

    fun bindChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "eval" -> {
                    val json = call.argument<String>("json")!!
                    val func = call.argument<String>("func")!!
                    val part = call.argument<Int>("part")!!
                    val mime = call.argument<String>("mime")!!
                    MainScope().launch {
                        val name = eval(json, func, part, mime).lastOrNull()
                        result.success(name)
                    }
                }
            }
        }
    }

    fun eval(json: String, jsString: String, part: Int, mime: String) = callbackFlow {
        val escapedJson = json.replace("\\", "\\\\").replace("'", "\\'")
        webview.evaluateJavascript(
            """
        ${jsString}
        javascript:eval(JSON.parse('$escapedJson'), $part, '$mime')
        """.trimIndent()
        ) { v ->
            trySend((v ?: "").trim('"'))
            channel.close()
        }
        awaitClose { }
    }
}