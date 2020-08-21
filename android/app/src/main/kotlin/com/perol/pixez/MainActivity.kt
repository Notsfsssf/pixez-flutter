package com.perol.pixez

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Environment
import android.webkit.MimeTypeMap
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.documentfile.provider.DocumentFile
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

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.perol.dev/save"
    private val ENCODE_CHANNEL = "samples.flutter.dev/battery"

    val OPEN_DOCUMENT_TREE_CODE = 190
    fun choiceFolder() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
        }
        startActivityForResult(intent, OPEN_DOCUMENT_TREE_CODE)
    }

    fun needChoice() =
            contentResolver.persistedUriPermissions.takeWhile { it.isReadPermission && it.isWritePermission }
                    .isEmpty()


    fun isFileExist(name: String): Boolean {
        val treeDocument = DocumentFile.fromTreeUri(this@MainActivity, contentResolver.persistedUriPermissions.takeWhile { it.isReadPermission && it.isWritePermission }.first().uri)!!
        return treeDocument.findFile(name) != null
    }

    fun writeFileUri(fileName: String): Uri? {
        val mimeType = if (fileName.endsWith("jpg", ignoreCase = true) || fileName.endsWith("jpeg", ignoreCase = true)) {
            "image/jpg"
        } else {
            if (fileName.endsWith("png")) {
                "image/png"
            } else {
                "image/gif"
            }
        }
        val takeWhile =
                contentResolver.persistedUriPermissions.takeWhile { it.isReadPermission && it.isWritePermission }
        if (takeWhile.isEmpty()) {
            choiceFolder()
            return null
        }
        val parentUri =
                takeWhile
                        .first().uri
        val treeDocument = DocumentFile.fromTreeUri(this@MainActivity, parentUri)!!
        var targetFile =
                treeDocument.findFile(fileName)
        if (targetFile != null) {
            if (targetFile.exists()) {
                targetFile.delete()
            }
        }
        targetFile = treeDocument.createFile(mimeType, fileName)
        return targetFile?.uri
    }


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "save") {
                val data = call.argument<ByteArray>("data")!!
                val name = call.argument<String>("name")!!
                writeFileUri(name)?.run {
                    contentResolver.openOutputStream(this, "w")?.write(data)
                }
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

            if (call.method == "get_path") {
                result.success(getPath())
            }
            if (call.method == "exist") {
                val name = call.argument<String>("name")!!
                val isFileExist = isFileExist(name)
                result.success(isFileExist)
            }
            if (call.method == "need_choice") {
                result.success(needChoice())
            }
            if (call.method == "choice_folder") {
                result.success(true)
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

    override fun onActivityResult(
            requestCode: Int, resultCode: Int,
            data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            OPEN_DOCUMENT_TREE_CODE ->
                if (resultCode == Activity.RESULT_OK) {
                    data?.data?.also { uri ->
                        Log.d("path", uri.toString())
                        val contentResolver = applicationContext.contentResolver
                        val takeFlags: Int = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                        contentResolver.persistedUriPermissions.takeWhile { it.isReadPermission && it.isWritePermission && it.uri != uri }
                                .forEach {
                                    contentResolver.releasePersistableUriPermission(it.uri, takeFlags)
                                }

                        contentResolver.takePersistableUriPermission(uri, takeFlags)
                    }
                } else {
                    /* Edit request not granted; explain to the user. */
                    Toast.makeText(applicationContext, "未正确取得授权，这可能会导致部分功能失效或闪退", Toast.LENGTH_SHORT).show()
                }
        }
    }

    private fun getPath(): String? {
        val list = contentResolver.persistedUriPermissions.takeWhile { it.isReadPermission && it.isWritePermission }
        if (list.isEmpty()) {
            return null
        }
        return list.first().uri.toString()
    }

    private fun encodeGif(name: String, path: String, delay: Int) {
        val file = File(path)
        file.let {
            val tempFile = File(applicationContext.cacheDir, "${name}.gif")
            Observable.create<File> { ot ->
                try {
                    val uri = writeFileUri("${name}.gif")
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
                    contentResolver.openOutputStream(uri, "w")?.write(tempFile.inputStream().readBytes())
                    ot.onNext(tempFile)
                    ot.onComplete()
                } catch (e: Exception) {
                    Log.d("exception", "${e.localizedMessage}")
                    tempFile.delete()
                    it.deleteRecursively()
                }
            }.subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).subscribe({

                Toast.makeText(this, "encode success", Toast.LENGTH_SHORT).show()
            }, {}, {})

        }
    }


}
