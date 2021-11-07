package com.perol.pixez

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.FileOutputStream

object Safer {
    private const val SAF_CHANNEL = "com.perol.dev/saf"
    private const val CREATE_FILE_CODE = 1111
    private var pendingResult: MethodChannel.Result? = null
    private var pendingWriteResult: MethodChannel.Result? = null

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
                    pendingWriteResult = result
                    val uriString = call.argument<String>("uri")!!
                    val byteArray = call.argument<ByteArray>("data")!!
                    val uri = Uri.parse(uriString)
                    activity.writeUri(uri, byteArray)
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
            pendingWriteResult?.success("${uri}")
            pendingWriteResult = null
        } catch (e: Throwable) {
            pendingWriteResult?.error("d", "d", "d")
            pendingWriteResult = null
        }
    }
}