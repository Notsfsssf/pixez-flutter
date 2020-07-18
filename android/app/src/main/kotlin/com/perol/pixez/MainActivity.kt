package com.perol.pixez

import android.content.ContentValues
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.preference.PreferenceManager
import com.waynejo.androidndkgif.GifEncoder
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.core.Observable
import io.reactivex.rxjava3.schedulers.Schedulers
import java.io.File
import java.io.IOException
import java.lang.Exception

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.perol.dev/save"
    private val ENCODE_CHANNEL = "samples.flutter.dev/battery"
    val pref by lazy {
        PreferenceManager.getDefaultSharedPreferences(this)
    }
    var storePath = ""

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        storePath = pref.getString("store_path", "${Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)}${File.separator}pixez")!!
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            if (call.method == "save") {
                val data = call.argument<ByteArray>("data") as ByteArray
                val type = call.argument<String>("name") as String
                insertImageOldWay(data, type)
                result.success(true)
            }
            if (call.method == "scan") {
                val path = call.argument<String>("path") as String
                MediaScannerConnection.scanFile(
                        this@MainActivity,
                        arrayOf(path),
                        arrayOf(
                                MimeTypeMap.getSingleton()
                                        .getMimeTypeFromExtension(File(path).extension)
                        )
                ) { _, _ ->
                }
                result.success(true);

            }
            if (call.method == "select_path") {
                result.success("")
            }
            if (call.method == "get_path") {
                result.success(getPath())
            }
            if (call.method == "restore_path") {
                pref.edit().putString("store_path", "${Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)}${File.separator}pixez").apply()
                result.success("")
            }
            if (call.method == "exist") {
                val type = call.argument<String>("name") as String
                val isFileExist = isOldFileExist(type)
                result.success(isFileExist)
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ENCODE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val name = call.argument<String>("name")!!
                val path = call.argument<String>("path")!!
                val delay = call.argument<Int>("delay")!!
                encodeGif(name, path, delay)
                result.success(true)
            }
        }
    }

    private fun getPath() = pref.getString("store_path", "${Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)}${File.separator}pixez")

    private fun encodeGif(name: String, path: String, delay: Int) {
        val file = File(path)
        file.let {
            val tempFile = File(applicationContext.cacheDir, "${name}.gif")
            Observable.create<File> { ot ->
                try {

                    if (!tempFile.exists()) {
                        tempFile.createNewFile()
                    }
                    Log.d("tempFile path:", tempFile.path)
                    val listFiles = it.listFiles()
                    if (listFiles == null || listFiles.isEmpty()) {
                        throw RuntimeException("unzip files not found")
                    }
                    val arrayFile = mutableListOf<File>()
                    for (i in listFiles) {
                        if (i.name.contains("jpg") || i.name.contains("png")) {
                            arrayFile.add(i)
                        }
                    }

                    arrayFile.sortWith(Comparator { o1, o2 -> o1.name.compareTo(o2.name) })
                    val bitmap: Bitmap = BitmapFactory.decodeFile(arrayFile.first().path)
                    val encoder = GifEncoder()
                    encoder.init(bitmap.width, bitmap.height, tempFile.path, GifEncoder.EncodingType.ENCODING_TYPE_STABLE_HIGH_MEMORY)
                    for (i in arrayFile.indices) {
                        if (i != 0) {
                            encoder.encodeFrame(BitmapFactory.decodeFile(arrayFile[i].path), delay)
                        } else encoder.encodeFrame(bitmap, delay)
                    }

                    encoder.close()
                    val targetFile = File(storePath, "${name}.gif")
                    tempFile.copyTo(targetFile, overwrite = true)
                    ot.onNext(targetFile)
                    ot.onComplete()
                } catch (e: Exception) {
                    Log.d("exception", "${e.localizedMessage}")
                    tempFile.delete()
                    it.deleteRecursively()
                }
            }.subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).subscribe({
                MediaScannerConnection.scanFile(
                        this@MainActivity,
                        arrayOf(it.path),
                        arrayOf(
                                MimeTypeMap.getSingleton()
                                        .getMimeTypeFromExtension(it.extension)
                        )
                ) { _, _ ->

                }
                Toast.makeText(this, "encode success", Toast.LENGTH_SHORT).show()
            }, {}, {})

        }
    }

    private fun insertImageOldWay(data: ByteArray, name: String) {
        File(storePath, name).run {
            if (!this.exists()) {
                this.createNewFile()
            }
            outputStream().apply {
                write(data)
                flush()
                close()
            }
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

    private fun isOldFileExist(name: String) = File(storePath, name).exists()
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
                Environment.DIRECTORY_PICTURES + File.separator + "pixez"

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
                Environment.DIRECTORY_PICTURES + File.separator + "pixez"
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
