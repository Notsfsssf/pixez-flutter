package com.perol.pixez

import android.content.ContentValues
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File
import java.io.IOException


class MainActivity : FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/battery"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val data = call.argument<ByteArray>("data") as ByteArray
                insertImage(data)
                result.success(true)
            }
        }
    }

    fun insertImage(data: ByteArray) {
        val relativeLocation =
                Environment.DIRECTORY_PICTURES + File.pathSeparator + "Date"
        val contentValues = ContentValues().apply {
            put(
                    MediaStore.MediaColumns.DISPLAY_NAME, System.currentTimeMillis()
                    .toString()
            )
            put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.MediaColumns.RELATIVE_PATH, relativeLocation)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
        }
        val resolver = this.contentResolver
        val uri =
                resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
        try {
            uri?.let {
                val stream = resolver.openOutputStream(it)
                stream?.write(data) ?: throw IOException("Failed to get output stream.")
            } ?: throw IOException("Failed to create new MediaStore record")

        } catch (e: IOException) {
            if (uri != null) {
                resolver.delete(uri, null, null)
            }
            throw IOException(e)
        } finally {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
                contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
        }

    }
}
