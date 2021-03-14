/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

package com.perol.pixez

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.webkit.MimeTypeMap
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.documentfile.provider.DocumentFile
import com.waynejo.androidndkgif.GifEncoder
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.util.*
import kotlin.Comparator

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.perol.dev/save"
    private val CRYPTO_CHANNEL = "com.perol.dev/crypto"
    private val ENCODE_CHANNEL = "samples.flutter.dev/battery"
    private val SUPPORTER_CHANNEL = "com.perol.dev/supporter"
    var saveMode = 0
    private val OPEN_DOCUMENT_TREE_CODE = 190
    private val PICK_IMAGE_FILE = 2
    var pendingResult: MethodChannel.Result? = null
    var pendingPickResult: MethodChannel.Result? = null
    var helplessPath: String? = null
    private val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"
    lateinit var sharedPreferences: SharedPreferences

    private fun splicingUrl(parentUri: String, fileName: String) = if (parentUri.endsWith(":")) {
        parentUri + fileName
    } else {
        "$parentUri/$fileName"
    }

    private fun choiceFolder(needHint: Boolean = true) {
        if (saveMode == 2 || saveMode == 0) {
            pendingPickResult?.success(true)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
        }
        if (needHint)
            Toast.makeText(context, getString(R.string.choose_a_suitable_image_storage_directory), Toast.LENGTH_SHORT).show()
        startActivityForResult(intent, OPEN_DOCUMENT_TREE_CODE)
    }

    private fun isFileExist(name: String): Boolean {
        if (saveMode == 0) {
            return exist(name)
        } else if (saveMode == 2) {
            return File("$helplessPath/$name").exists()
        }
        val treeDocument = DocumentFile.fromTreeUri(this@MainActivity, contentResolver.persistedUriPermissions.takeWhile { it.isReadPermission && it.isWritePermission }.first().uri)!!
        if (name.contains("/")) {
            val names = name.split("/")
            if (names.size >= 2) {
                val treeId = DocumentsContract.getTreeDocumentId(treeDocument.uri)
                val folderName = names.first()
                val fName = names.last()
                val dirId = splicingUrl(treeId, folderName)
                val dirUri = DocumentsContract.buildDocumentUriUsingTree(treeDocument.uri, dirId)
                val dirDocument = DocumentFile.fromSingleUri(this, dirUri)
                return if (dirDocument == null || !dirDocument.exists()) {
                    false
                } else if (dirDocument.isFile) {
                    dirDocument.delete()
                    false
                } else {
                    val fileId = splicingUrl(dirId, fName)
                    val fileUri = DocumentsContract.buildDocumentUriUsingTree(treeDocument.uri, fileId)
                    val targetFile = DocumentFile.fromSingleUri(this, fileUri)
                    targetFile != null && targetFile.exists()
                }
            } else {
                return false
            }
        }
        val treeId = DocumentsContract.getTreeDocumentId(treeDocument.uri)
        val fileId = splicingUrl(treeId, name)
        val fileUri = DocumentsContract.buildDocumentUriUsingTree(treeDocument.uri, fileId)
        val targetFile = DocumentFile.fromSingleUri(this, fileUri)
        return targetFile != null && targetFile.exists()
    }

    private fun writeFileUri(fileName: String, clearOld: Boolean = false): Uri? {
        val mimeType = if (fileName.endsWith("jpg", ignoreCase = true) || fileName.endsWith("jpeg", ignoreCase = true)) {
            "image/jpg"
        } else {
            if (fileName.endsWith("png")) {
                "image/png"
            } else {
                "image/gif"
            }
        }
        val permissions =
                contentResolver.persistedUriPermissions.takeWhile { it.isReadPermission && it.isWritePermission }
        if (permissions.isEmpty()) {
            choiceFolder()
            return null
        }
        val parentUri =
                permissions
                        .first().uri
        val treeDocument = DocumentFile.fromTreeUri(this@MainActivity, parentUri)!!
        val treeId = DocumentsContract.getTreeDocumentId(treeDocument.uri)

        if (fileName.contains("/")) {
            val names = fileName.split("/")
            if (names.size >= 2) {
                val fName = names.last()
                val folderName = names.first()
                if (clearOld && fName.contains("_p0"))
                    treeDocument.findFile(fName.replace("_p0", ""))
                var folderDocument = treeDocument.findFile(folderName)
                if (folderDocument == null) {
                    val tempFolderDocument = treeDocument.createDirectory(folderName)
                    folderDocument = treeDocument.findFile(folderName)
                    if (tempFolderDocument != null && folderDocument != null) {
                        if (tempFolderDocument.uri != folderDocument.uri) {
                            // 文件夹已经被创建过
                            tempFolderDocument.delete()
                        }
                    }
                }
                val file = folderDocument?.findFile(fName)
                if (file != null && file.exists()) {
                    file.delete()
                }
                return folderDocument?.createFile(mimeType, fName)?.uri
            }
        }
        if (clearOld && fileName.contains("_p0"))
            treeDocument.findFile(fileName.replace("_p0", ""))
        val fileId = splicingUrl(treeId, fileName)
        val fileUri = DocumentsContract.buildDocumentUriUsingTree(treeDocument.uri, fileId)
        val targetFile = DocumentFile.fromSingleUri(this, fileUri)
        if (targetFile != null) {
            if (targetFile.exists()) {
                targetFile.delete()
            }
        }
        return treeDocument.createFile(mimeType, fileName)?.uri
    }

    private fun wr(data: ByteArray, uri: Uri) {
        contentResolver.openOutputStream(uri, "w")?.write(data)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sharedPreferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        helplessPath = sharedPreferences.getString("flutter.store_path", null)
        saveMode = sharedPreferences.getLong("flutter.save_mode", 0).toInt()
        Weiss.bindChannel(flutterEngine)
        CustomTab.bindChannel(this, flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CRYPTO_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "code_verifier") {
                result.success(CodeGen.getCodeVer())
            } else if (call.method == "code_challenge") {
                result.success(CodeGen.getCodeChallenge(call.argument<String>("code")!!))
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SUPPORTER_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "process_text") {
                try {
                    val queryIntentActivities = packageManager.queryIntentActivities(Intent().apply {
                        type = "text/plain"
                    }, 0)
                    for (resolveInfo: ResolveInfo in queryIntentActivities) {
                        if (resolveInfo.activityInfo.packageName.contains("com.google.android.apps.translate")) {
                            result.success(true)
                            return@setMethodCallHandler
                        }
                    }
                } catch (ignore: Throwable) {

                }
                result.success(false)
            }
            if (call.method == "process") {
                val text = call.argument<String>("text")
                val intent = Intent()
                        .setType("text/plain")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    intent.action = Intent.ACTION_PROCESS_TEXT
                    intent.putExtra(Intent.EXTRA_PROCESS_TEXT, text)
                } else {
                    intent.action = Intent.ACTION_SEND
                    intent.putExtra(Intent.EXTRA_TEXT, text)
                }
                result.success(0)
                try {
                    startActivity(intent)

                } catch (throwable: Throwable) {
                }
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "save") {
                val data = call.argument<ByteArray>("data")!!
                val name = call.argument<String>("name")!!
                var clearOld = call.argument<Boolean>("clear_old")
                saveMode = call.argument<Int>("save_mode") ?: 0

                if (clearOld == null)
                    clearOld = false
                GlobalScope.launch(Dispatchers.Main) {
                    if (saveMode == 0) {
                        withContext(Dispatchers.IO) {
                            save(data, name)
                        }
                    } else if (saveMode == 2) {
                        if (helplessPath == null) {
                            helplessPath = sharedPreferences.getString("flutter.store_path", null)
                            if (helplessPath == null) {
                                helplessPath = "/storage/emulated/0/Pictures/pixez"
                            }
                        }
                        val fullPath = "$helplessPath/$name"
                        val file = File(fullPath)
                        withContext(Dispatchers.IO) {
                            val dirPath = file.parent
                            val dirFile = File(dirPath)
                            if (!dirFile.exists()) {
                                dirFile.mkdirs()
                            }
                            if (!file.exists()) {
                                file.createNewFile()
                            }
                            file.outputStream().write(data)
                            if (clearOld && name.contains("_p0")) {
                                val oldFileName = name.replace("_p0", "")
                                val oldFile = File("$helplessPath", oldFileName)
                                if (oldFile.exists()) {
                                    oldFile.delete()
                                }
                            }
                        }
                        MediaScannerConnection.scanFile(
                                this@MainActivity,
                                arrayOf(file.path),
                                arrayOf(
                                        MimeTypeMap.getSingleton()
                                                .getMimeTypeFromExtension(File(file.path).extension)
                                )
                        ) { _, _ ->
                        }

                    } else if (saveMode == 1) {
                        withContext(Dispatchers.IO) {
                            writeFileUri(name, clearOld)?.let {
                                wr(data, it)
                            }
                        }
                    }
                    result.success(true)
                }
            }
            if (call.method == "get_path") {
                saveMode = call.argument<Int>("save_mode") ?: 0
                GlobalScope.launch(Dispatchers.Main) {
                    val path = withContext(Dispatchers.IO) {
                        getPath()
                    }
                    result.success(path)
                }
            }
            if (call.method == "exist") {
                val name = call.argument<String>("name")!!
                saveMode = call.argument<Int>("save_mode") ?: 0
                GlobalScope.launch(Dispatchers.Main) {
                    val isFileExist = withContext(Dispatchers.IO) {
                        isFileExist(name)
                    }
                    result.success(isFileExist)
                }
            }
            if (call.method == "choice_folder") {
                saveMode = call.argument<Int>("save_mode") ?: 0
                choiceFolder()
                pendingPickResult = result
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ENCODE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val name = call.argument<String>("name")!!
                val path = call.argument<String>("path")!!
                val delay = call.argument<Int>("delay")!!
                GlobalScope.launch(Dispatchers.Main) {
                    withContext(Dispatchers.IO) {
                        encodeGif(name, path, delay)
                    }
                    Toast.makeText(this@MainActivity, getString(R.string.encode_success), Toast.LENGTH_SHORT).show()
                    result.success(true)
                }
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CardAppWidget.CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    if (call.arguments == null) return@setMethodCallHandler
                    Log.d("native", "initialize widget")
                    CardAppWidget.setHandle(this, call.arguments as Long)
                }
            }
        }
    }

    override fun onActivityResult(
            requestCode: Int, resultCode: Int,
            data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            PICK_IMAGE_FILE -> if (resultCode == Activity.RESULT_OK) {
                data?.data?.also { uri ->
                    Log.d("flutter.store_path", uri.toString())
                    val dataR = applicationContext.contentResolver.openInputStream(uri)?.readBytes()
                    pendingResult?.success(dataR)
                    pendingResult = null
                }
            } else {
                pendingResult?.success(null)
                pendingResult = null
            }
            OPEN_DOCUMENT_TREE_CODE ->
                if (resultCode == Activity.RESULT_OK) {
                    data?.data?.also { uri ->
                        Log.d("flutter.store_path", uri.toString())
                        if (uri.toString().toLowerCase(Locale.ROOT).contains("download")) {
                            Toast.makeText(applicationContext, getString(R.string.do_not_choice_download_folder_message), Toast.LENGTH_LONG).show()
                            choiceFolder(needHint = false)
                            return
                        }
                        val contentResolver = applicationContext.contentResolver
                        val takeFlags: Int = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                        contentResolver.takePersistableUriPermission(uri, takeFlags)
                        for (i in contentResolver.persistedUriPermissions) {
                            if (i.isReadPermission && i.isWritePermission && i.uri != uri) {
                                contentResolver.releasePersistableUriPermission(i.uri, takeFlags)
                            }
                        }
                        pendingPickResult?.success(true)
                        pendingPickResult = null
                    }
                } else {
                    Toast.makeText(applicationContext, getString(R.string.failure_to_obtain_authorization_may_cause_some_functions_to_fail_or_crash), Toast.LENGTH_SHORT).show()
                    pendingPickResult?.success(false)
                    pendingPickResult = null
                }
        }
    }

    private fun getPath(): String? {
        if (saveMode == 0) {
            return "Pictures/PixEz"
        }
        if (saveMode == 2) {
            helplessPath = sharedPreferences.getString("flutter.store_path", "")
            return helplessPath
        }
        val list = contentResolver.persistedUriPermissions.takeWhile { it.isReadPermission && it.isWritePermission }
        if (list.isEmpty()) {
            return null
        }
        return list.first().uri.toString()
    }

    private fun encodeGif(name: String, path: String, delay: Int) {
        val file = File(path)
        file.let {
            val tempFile = File(applicationContext.cacheDir, "${
            if (name.contains("/")) {
                name.split("/").last()
            } else {
                name
            }
            }.gif")
            try {
                val fileName = "${name}.gif"

/*                if (!tempFile.exists()) {
                    tempFile.createNewFile()
                }*/
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
                if (saveMode == 1) {
                    save(tempFile.readBytes(), fileName)
                    return
                }
                if (saveMode == 2) {
                    val target = File("$helplessPath/$fileName")
                    if (!target.exists()) {
                        target.createNewFile()
                    }
                    tempFile.copyTo(target, overwrite = true)
                    MediaScannerConnection.scanFile(
                            this@MainActivity,
                            arrayOf(helplessPath),
                            arrayOf(
                                    MimeTypeMap.getSingleton()
                                            .getMimeTypeFromExtension(target.extension)
                            )
                    ) { _, _ ->
                    }
                    return
                }
                val uri = writeFileUri(fileName)
                contentResolver.openOutputStream(uri!!, "w")?.write(tempFile.inputStream().readBytes())
            } catch (e: Exception) {
                e.printStackTrace()
                tempFile.delete()
                it.deleteRecursively()
            }
        }
    }
}
