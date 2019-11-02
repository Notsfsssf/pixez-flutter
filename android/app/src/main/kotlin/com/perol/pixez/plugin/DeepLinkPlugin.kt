package com.perol.pixez.plugin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.NewIntentListener

class DeepLinkPlugin : FlutterPlugin,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler,
    ActivityAware,
    NewIntentListener {
    private var context: Context? = null

    private var changeReceiver: BroadcastReceiver? = null

    private var initialLink: String? = null
    private var latestLink: String? = null
    private var initialIntent = true

    companion object {
        private val MESSAGES_CHANNEL = "deep_links/messages"
        private val EVENTS_CHANNEL = "deep_links/events"
    }

    private fun handleIntent(context: Context, intent: Intent) {
        val action = intent.action
        val dataString = intent.dataString
        if (Intent.ACTION_VIEW == action) {
            if (initialIntent) {
                initialLink = dataString
                initialIntent = false
            }
            latestLink = dataString
            changeReceiver?.onReceive(context, intent)
        }
        if (intent.extras != null && intent.hasExtra("iid")) {
            val iid = intent.getLongExtra("iid", 0)
            val link = "pixez://www.pixiv.net/artworks/$iid"
            if (initialIntent) {
                initialLink = link
                initialIntent = false
            }
            latestLink = link
            changeReceiver?.onReceive(context, intent)
        }
    }

    private fun register(messenger: BinaryMessenger, plugin: DeepLinkPlugin) {
        val methodChannel = MethodChannel(messenger, MESSAGES_CHANNEL)
        methodChannel.setMethodCallHandler(plugin)
        val eventChannel = EventChannel(messenger, EVENTS_CHANNEL)
        eventChannel.setStreamHandler(plugin)
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.context = binding.applicationContext;
        register(binding.binaryMessenger, this);
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getInitialLink" -> {
                result.success(initialLink)
            }

            "getLatestLink" -> {
                result.success(latestLink)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        events?.let {
            changeReceiver = createChangeReceiver(it)
        }
    }

    private fun createChangeReceiver(events: EventSink): BroadcastReceiver {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.hasExtra("iid")) {
                    val iid = intent.getLongExtra("iid", 0)
                    val link = "pixez://www.pixiv.net/artworks/$iid"
                    events.success(link)
                    return
                }
                val dataString = intent.dataString
                if (dataString == null) {
                    events.error("UNAVAILABLE", "Link unavailable", null)
                } else {
                    events.success(dataString)
                }
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        changeReceiver = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(this)
        context?.let {
            handleIntent(it, binding.activity.intent)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(this)
        context?.let {
            handleIntent(it, binding.activity.intent)
        }
    }

    override fun onDetachedFromActivity() {
    }

    override fun onNewIntent(intent: Intent): Boolean {
        context?.let {
            handleIntent(it, intent)
        }
        return false
    }
}