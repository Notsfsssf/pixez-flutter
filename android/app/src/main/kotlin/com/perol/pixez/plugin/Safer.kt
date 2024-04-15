package com.perol.pixez.plugin

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream
import java.io.FileOutputStream

object Safer {
    private const val SAF_CHANNEL = "com.perol.dev/saf"
    private const val CREATE_FILE_CODE = 1111
    private const val OPEN_FILE_CODE = 2222
    private var pendingResult: MethodChannel.Result? = null

    fun bindChannel(activity: Activity, flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SAF_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "createFile" -> {
                    pendingResult = result
                    val name = call.argument<String>("name")!!
                    val mimeType = call.argument<String>("mimeType")!!
                    activity.createFile(name, mimeType)
                }

                "writeUri" -> {
                    pendingResult = result
                    val uriString = call.argument<String>("uri")!!
                    val byteArray = call.argument<ByteArray>("data")!!
                    val uri = Uri.parse(uriString)
                    activity.writeUri(uri, byteArray)
                }

                "openFile" -> {
                    pendingResult = result
                    val type = call.argument<String>("type")
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        this.type = type
                    }
                    activity.startActivityForResult(intent, OPEN_FILE_CODE)
                }
            }
        }
    }

    fun Activity.createFile(name: String, mimeType: String) {
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, name)
        }
        startActivityForResult(intent, CREATE_FILE_CODE)
    }

    fun bindResult(
        activity: Activity,
        requestCode: Int, resultCode: Int,
        data: Intent?
    ) {
        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                CREATE_FILE_CODE -> {
                    val uriString = data?.data?.toString()
                    if (!uriString.isNullOrBlank()) {
                        pendingResult?.success(uriString)
                        pendingResult = null
                        return
                    }
                }

                OPEN_FILE_CODE -> {
                    try {
                        val uri = data!!.data!!
                        val contentResolver = activity.contentResolver
                        contentResolver.openFileDescriptor(uri, "r")!!.use {
                            FileInputStream(it.fileDescriptor).use {
                                val byteArray = it.readBytes()
                                pendingResult?.success(byteArray)
                                pendingResult = null
                                return
                            }
                        }
                    } catch (e: Throwable) {
                        Log.d("Safer", "bindResult: ${e.message}")
                    }
                }
            }
        }
        pendingResult?.error("d", "d", "d")
        pendingResult = null
    }

    fun Activity.writeUri(uri: Uri, byteArray: ByteArray) {
        try {
            contentResolver.openFileDescriptor(uri, "wt")?.use {
                FileOutputStream(it.fileDescriptor).use {
                    it.write(byteArray)
                }
            }
            pendingResult?.success("${uri}")
            pendingResult = null
        } catch (e: Throwable) {
            pendingResult?.error("d", "d", "d")
            pendingResult = null
        }
    }
}