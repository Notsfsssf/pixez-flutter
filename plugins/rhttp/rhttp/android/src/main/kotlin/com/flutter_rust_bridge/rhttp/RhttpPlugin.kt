package com.flutter_rust_bridge.rhttp

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** RhttpPlugin */
class RhttpPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        init {
            System.loadLibrary("rhttp")
        }
    }

    private external fun initAndroid(ctx: Context)

    private external fun deinitAndroid()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        initAndroid(flutterPluginBinding.applicationContext)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        deinitAndroid()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        throw NotImplementedError()
    }
}
