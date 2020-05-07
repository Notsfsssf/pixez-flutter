package com.perol.pixez

import android.content.ContentValues
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import android.webkit.MimeTypeMap
import android.widget.Toast
import androidx.preference.PreferenceManager
import com.afollestad.materialdialogs.MaterialDialog
import com.afollestad.materialdialogs.files.folderChooser
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.perol.dev/save"
    private val UGOIRA_CHANNEL = "samples.flutter.dev/battery"
    val pref by lazy {
        PreferenceManager.getDefaultSharedPreferences(this)
    }

    var storePath = pref.getString("store_path", Environment.DIRECTORY_PICTURES + File.separator + "pxez")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "save") {
                val data = call.argument<String>("data") as ByteArray
                val type = call.argument<String>("name") as String
                insertImageOldWay(data, type)
                result.success(true)
            }
            if (call.method == "select_path") {
                selectSavePath()
            }
            if (call.method == "get_path") {
                getPath()
            }
            if (call.method == "exist") {
                val type = call.argument<String>("name") as String
                val isFileExist = isOldFileExist(type)
                result.success(isFileExist)
            }
        }
        MethodChannel(flutterView, UGOIRA_CHANNEL).setMethodCallHandler { call, result ->
/*            platform.invokeMethod('getBatteryLevel', {
                "path": snapshot.listSync.first.parent.path,
                "delay": snapshot.frames.first.delay
            });*/
            if (call.method == "getBatteryLevel") {
                val name = call.argument<String>("name")!!
                val path = call.argument<String>("path")!!
                val delay = call.argument<Int>("delay")!!
                encodeGif(name, path, delay)
                result.success(true)
            }
        }
    }

    private fun getPath() {

    }

    private fun selectSavePath() {
        MaterialDialog(this).show {
            title(R.string.title_save_path)
            folderChooser(allowFolderCreation = true) { _, folder ->
                PreferenceManager.getDefaultSharedPreferences(applicationContext).apply {
                    this.edit().putString("store_path", folder.absolutePath).apply()
                }
            }
            cornerRadius(2.0F)
            negativeButton(android.R.string.cancel)
            positiveButton(android.R.string.ok)
        }
    }

    private fun encodeGif(name: String, path: String, delay: Int) {
        val file = File(path)
        file.parentFile?.let {
            val listFiles = it.listFiles()
            if (listFiles == null || listFiles.isEmpty()) {
                throw RuntimeException("unzip files not found")
            }
            listFiles.sortWith(Comparator { o1, o2 -> o1.name.compareTo(o2.name) })
            val bos = ByteArrayOutputStream()
            val encoder = AnimatedGifEncoder()
            encoder.start(bos)
            for (i in listFiles) {
                encoder.addFrame(BitmapFactory.decodeFile(i.path))
            }
            encoder.finish()
            val tempFile = File.createTempFile(name, "gif")
            bos.writeTo(tempFile.outputStream())
            val targetFile = File(storePath, name + File.separator + ".gif")
            tempFile.copyTo(targetFile, overwrite = true)
            MediaScannerConnection.scanFile(
                    this@MainActivity,
                    arrayOf(targetFile.path),
                    arrayOf(
                            MimeTypeMap.getSingleton()
                                    .getMimeTypeFromExtension(targetFile.extension)
                    )
            ) { _, _ ->

            }
            Toast.makeText(this,"encode success",Toast.LENGTH_SHORT).show()
        }
    }

    private fun insertImageOldWay(data: ByteArray, name: String) {
        File(storePath, name).run {
            outputStream().write(data)
            MediaScannerConnection.scanFile(
                    this@MainActivity,
                    arrayOf(this.path),
                    arrayOf(
                            MimeTypeMap.getSingleton()
                                    .getMimeTypeFromExtension(this.extension)
                    )
            ) { _, _ ->

            }
        }

    }

    private fun isOldFileExist(name: String) = File(storePath,name).exists()
    private fun isFileExist(name: String): Boolean {
        /**
         * A key concept when working with Android [ContentProvider]s is something called
         * "projections". A projection is the list of columns to request from the provider,
         * and can be thought of (quite accurately) as the "SELECT ..." clause of a SQL
         * statement.
         *
         * It's not _required_ to provide a projection. In this case, one could pass `null`
         * in place of `projection` in the call to [ContentResolver.query], but requesting
         * more data than is required has a performance impact.
         *
         * For this sample, we only use a few columns of data, and so we'll request just a
         * subset of columns.
         */
        val projection = arrayOf(
                MediaStore.Images.Media._ID,
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Images.Media.DATE_ADDED
        )
        val relativeLocation =
                Environment.DIRECTORY_PICTURES + File.separator + "pxez"

        /**
         * The `selection` is the "WHERE ..." clause of a SQL statement. It's also possible
         * to omit this by passing `null` in its place, and then all rows will be returned.
         * In this case we're using a selection based on the date the image was taken.
         *
         * Note that we've included a `?` in our selection. This stands in for a variable
         * which will be provided by the next variable.
         */
        val selection = "${MediaStore.MediaColumns.DISPLAY_NAME} = ? and ${MediaStore.MediaColumns.RELATIVE_PATH} = ?"

        /**
         * The `selectionArgs` is a list of values that will be filled in for each `?`
         * in the `selection`.
         */
        val selectionArgs = arrayOf<String>(name, relativeLocation)

        /**
         * Sort order to use. This can also be null, which will use the default sort
         * order. For [MediaStore.Images], the default sort order is ascending by date taken.
         */
        val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"
        Log.d("cursor count", name)
        applicationContext.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                sortOrder
        )?.use { cursor ->
            Log.d("cursor count", cursor.count.toString())
            if (cursor.count > 0) {
                while (cursor.moveToNext()) {
                    // Use an ID column from the projection to get
                    // a URI representing the media item itself.
                    return true
                }
            } else return false

        }
        return false
    }

    private fun insertImage(data: ByteArray, name: String) {
        val relativeLocation =
                Environment.DIRECTORY_PICTURES + File.separator + "pxez"
        val contentValues = ContentValues().apply {
            put(
                    MediaStore.MediaColumns.DISPLAY_NAME, name
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
                stream.flush()
                stream.close()
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
