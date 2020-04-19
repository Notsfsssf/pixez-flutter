package com.perol.pixez

import android.R.attr.mimeType
import android.content.ContentValues
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.*


class MainActivity : FlutterActivity() {
  @Throws(IOException::class)
  private fun insertImage(image: File): Boolean {
    var values: ContentValues
    // 向 Media Store 插入标记为待定的空白文件
    values = ContentValues()

    values.put(MediaStore.Images.ImageColumns.RELATIVE_PATH, Environment.DIRECTORY_PICTURES.toString() + "test") // 不同类型文件可用 RELATIVE_PATH 不用，具体请参阅 MediaProvider 源码
    values.put(MediaStore.Images.ImageColumns.DISPLAY_NAME, System.currentTimeMillis().toString())
    values.put(MediaStore.Images.ImageColumns.IS_PENDING, true)
    val uri: Uri = getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            ?: return false
    // 写入文件内容
    val `is`: InputStream = FileInputStream(image)
    val os: OutputStream = getContentResolver().openOutputStream(uri, "rw")
    val b = ByteArray(8192)
    var r: Int
    while (`is`.read(b).also({ r = it }) != -1) {
      os.write(b, 0, r)
    }
    os.flush()
    os.close()
    `is`.close()
    // 移除待定标记，其他应用可访问该文件
    values = ContentValues()
    values.put(MediaStore.Images.ImageColumns.IS_PENDING, false)
    return getContentResolver().update(uri, values, null, null) === 1
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
  }
}
