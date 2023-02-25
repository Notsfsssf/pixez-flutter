package com.perol.pixez

import android.annotation.SuppressLint
import android.webkit.WebView
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.lastOrNull
import kotlinx.coroutines.launch

@SuppressLint("SetJavaScriptEnabled")
class JsEvalPlugin(val activity: FragmentActivity) {
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
                    activity.lifecycleScope.launch {
                        val name = eval(json, func, part, mime).lastOrNull()
                        result.success(name)
                    }
                }
            }
        }
    }

    fun eval(json: String, jsString: String, part: Int, mime: String) = callbackFlow {
        webview.evaluateJavascript(
            """
            ${jsString}
            javascript:eval(JSON.parse('${json}'), ${part}, '${mime}')
        """.trimIndent()
        ) { v ->
            trySend((v ?: "").trim('"'))
            channel.close()
        }
        awaitClose { }
    }
}