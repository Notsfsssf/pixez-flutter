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

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.DocumentsContract
import android.webkit.MimeTypeMap
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.core.view.WindowCompat
import androidx.documentfile.provider.DocumentFile
import androidx.lifecycle.lifecycleScope
import com.perol.pixez.plugin.CustomTab
import com.perol.pixez.plugin.DeepLinkPlugin
import com.perol.pixez.plugin.JsEvalPlugin
import com.perol.pixez.plugin.OpenSettinger
import com.perol.pixez.plugin.Safer
import com.perol.pixez.plugin.SecurePlugin
import com.perol.pixez.plugin.SupporterPlugin
import com.perol.pixez.plugin.Weiss
import com.perol.pixez.plugin.exist
import com.perol.pixez.plugin.save
import com.waynejo.androidndkgif.GifEncoder
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.perol.dev/save"
    private val ENCODE_CHANNEL = "samples.flutter.dev/battery"
    private var saveMode = 0
    private val OPEN_DOCUMENT_TREE_CODE = 190
    private val PICK_IMAGE_FILE = 2
    private var pendingResult: MethodChannel.Result? = null
    private var pendingPickResult: MethodChannel.Result? = null
    private var helplessPath: String? = null
    private val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"
    private lateinit var sharedPreferences: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }
        super.onCreate(savedInstanceState)
    }

    private val savingPools = Collections.synchronizedList(arrayListOf<String>())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(DeepLinkPlugin())
        sharedPreferences =
            this.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        helplessPath = sharedPreferences.getString("flutter.store_path", null)
        saveMode = sharedPreferences.getLong("flutter.save_mode", 0).toInt()
        OpenSettinger.bindChannel(flutterEngine, this)
        Weiss.bindChannel(flutterEngine)
        CustomTab.bindChannel(this, flutterEngine)
        Safer.bindChannel(this, flutterEngine)
        JsEvalPlugin(this).bindChannel(flutterEngine)
        SecurePlugin(this).bindChannel(flutterEngine)
        SupporterPlugin().bindChannel(this, flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    if (Build.VERSION.SDK_INT >= 33) {
                        result.success(true)
                    }
                }

                "permissionStatus" -> {
                    if (Build.VERSION.SDK_INT >= 33) {
                        val checkSelfPermission = ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.READ_MEDIA_IMAGES
                        )
                        result.success(checkSelfPermission == PackageManager.PERMISSION_GRANTED)
                    }
                }

                "save" -> {
                    val data = call.argument<ByteArray>("data")!!
                    val name = call.argument<String>("name")!!
                    var clearOld = call.argument<Boolean>("clear_old")
                    saveMode = call.argument<Int>("save_mode") ?: 0
                    if (clearOld == null)
                        clearOld = false
                    if (savingPools.contains(name))
                        return@setMethodCallHandler;
                    savingPools.add(name)
                    lifecycleScope.launch {
                        try {
                            when (saveMode) {
                                0 -> {
                                    val path = withContext(Dispatchers.IO) {
                                        save(data, name)
                                    } ?: return@launch
                                    MediaScannerConnection.scanFile(
                                        this@MainActivity,
                                        arrayOf(path),
                                        arrayOf(
                                            MimeTypeMap.getSingleton()
                                                .getMimeTypeFromExtension(File(path).extension)
                                        )
                                    ) { _, _ ->
                                    }
                                }

                                2 -> {
                                    if (helplessPath == null) {
                                        helplessPath =
                                            sharedPreferences.getString("flutter.store_path", null)
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

                                }

                                1 -> {
                                    withContext(Dispatchers.IO) {
                                        writeFileUri(name, clearOld)?.let {
                                            wr(data, it)
                                        }
                                    }
                                }
                            }
                            result.success(true)
                        } catch (e: Throwable) {
                            Log.d("x=====", "${e.message}")
                        } finally {
                            savingPools.remove(name)
                        }
                    }
                }

                "get_path" -> {
                    saveMode = call.argument<Int>("save_mode") ?: 0
                    lifecycleScope.launch {
                        val path = withContext(Dispatchers.IO) {
                            getPath()
                        }
                        result.success(path)
                    }
                }

                "exist" -> {
                    val name = call.argument<String>("name")!!
                    saveMode = call.argument<Int>("save_mode") ?: 0
                    lifecycleScope.launch {
                        val isFileExist = withContext(Dispatchers.IO) {
                            try {
                                return@withContext isFileExist(name)
                            } catch (e: Throwable) {
                            }
                        }
                        result.success(isFileExist)
                    }
                }

                "choice_folder" -> {
                    saveMode = call.argument<Int>("save_mode") ?: 0
                    choiceFolder()
                    pendingPickResult = result
                }
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ENCODE_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val name = call.argument<String>("name")!!
                val path = call.argument<String>("path")!!
                val delay = call.argument<Int>("delay")!!
                val delayArray = call.argument<List<Int>>("delay_array")!!
                lifecycleScope.launch {
                    withContext(Dispatchers.IO) {
                        encodeGif(name, path, delay, delayArray)
                    }
                    Toast.makeText(
                        this@MainActivity,
                        getString(R.string.encode_success),
                        Toast.LENGTH_SHORT
                    ).show()
                    result.success(true)
                }
            }
        }
    }

    override fun onActivityResult(
        requestCode: Int, resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        Safer.bindResult(this, requestCode, resultCode, data)
        when (requestCode) {
            PICK_IMAGE_FILE -> if (resultCode == Activity.RESULT_OK) {
                data?.data?.also { uri ->
                    Log.d("flutter.store_path", uri.toString())
                    applicationContext.contentResolver.openInputStream(uri)?.use {
                        val dataR = it.readBytes()
                        pendingPickResult?.success(dataR)
                        pendingPickResult = null
                    }
                }
            } else {
                pendingResult?.success(null)
                pendingResult = null
            }

            OPEN_DOCUMENT_TREE_CODE ->
                if (resultCode == Activity.RESULT_OK) {
                    data?.data?.also { uri ->
                        Log.d("flutter.store_path", uri.toString())
                        if (uri.toString().lowercase().contains("download")) {
                            Toast.makeText(
                                applicationContext,
                                getString(R.string.do_not_choice_download_folder_message),
                                Toast.LENGTH_LONG
                            ).show()
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
                    Toast.makeText(
                        applicationContext,
                        getString(R.string.failure_to_obtain_authorization_may_cause_some_functions_to_fail_or_crash),
                        Toast.LENGTH_SHORT
                    ).show()
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
        val list =
            contentResolver.persistedUriPermissions.takeWhile { it.isReadPermission && it.isWritePermission }
        if (list.isEmpty()) {
            return null
        }
        return list.first().uri.toString()
    }

    private fun encodeGif(name: String, path: String, delay: Int, delayArray: List<Int>) {
        val file = File(path)
        file.let {
            val tempFile = File(
                applicationContext.cacheDir, "${
                    if (name.contains("/")) {
                        name.split("/").last()
                    } else {
                        name
                    }
                }.gif"
            )
            try {
                val fileName = "${name}.gif"
                if (saveMode == 0) {
                    if (exist(fileName))
                        return
                }
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
                arrayFile.sortWith { o1, o2 -> o1.name.compareTo(o2.name) }
                val bitmap: Bitmap = BitmapFactory.decodeFile(arrayFile.first().path)
                val encoder = GifEncoder()
                encoder.init(
                    bitmap.width,
                    bitmap.height,
                    tempFile.path,
                    GifEncoder.EncodingType.ENCODING_TYPE_STABLE_HIGH_MEMORY
                )
                for (i in arrayFile.indices) {
                    val trueDelay = if (i < delayArray.size) {
                        delayArray[i]
                    } else {
                        delay
                    }
                    if (i != 0) {
                        encoder.encodeFrame(BitmapFactory.decodeFile(arrayFile[i].path), trueDelay)
                    } else encoder.encodeFrame(bitmap, trueDelay)
                }
                encoder.close()
                if (saveMode == 0) {
                    save(tempFile.readBytes(), fileName)?.let {
                        MediaScannerConnection.scanFile(
                            this@MainActivity,
                            arrayOf(it),
                            arrayOf(
                                MimeTypeMap.getSingleton()
                                    .getMimeTypeFromExtension(File(it).extension)
                            )
                        ) { _, _ ->
                        }
                    }
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
                        arrayOf(target.path),
                        arrayOf(
                            MimeTypeMap.getSingleton()
                                .getMimeTypeFromExtension(target.extension)
                        )
                    ) { _, _ ->
                    }
                    return
                }
                val uri = writeFileUri(fileName)
                contentResolver.openOutputStream(uri!!, "w")?.use { outputStream ->
                    outputStream.write(tempFile.inputStream().readBytes())
                }
            } catch (e: Throwable) {
                e.printStackTrace()
                tempFile.delete()
                it.deleteRecursively()
            }
        }
    }

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
            Toast.makeText(
                this,
                getString(R.string.choose_a_suitable_image_storage_directory),
                Toast.LENGTH_SHORT
            ).show()
        startActivityForResult(intent, OPEN_DOCUMENT_TREE_CODE)
    }

    private fun isFileExist(name: String): Boolean {
        when (saveMode) {
            0 -> {
                return exist(name)
            }

            2 -> {
                return File("$helplessPath/$name").exists()
            }

            else -> {
                val treeDocument = DocumentFile.fromTreeUri(
                    this@MainActivity,
                    contentResolver.persistedUriPermissions.takeWhile { it.isReadPermission && it.isWritePermission }
                        .first().uri
                )!!
                if (name.contains("/")) {
                    val names = name.split("/")
                    if (names.size >= 2) {
                        val treeId = DocumentsContract.getTreeDocumentId(treeDocument.uri)
                        val folderName = names.first()
                        val fName = names.last()
                        val dirId = splicingUrl(treeId, folderName)
                        val dirUri =
                            DocumentsContract.buildDocumentUriUsingTree(treeDocument.uri, dirId)
                        val dirDocument = DocumentFile.fromSingleUri(this, dirUri)
                        return if (dirDocument == null || !dirDocument.exists()) {
                            false
                        } else if (dirDocument.isFile) {
                            dirDocument.delete()
                            false
                        } else {
                            val fileId = splicingUrl(dirId, fName)
                            val fileUri =
                                DocumentsContract.buildDocumentUriUsingTree(
                                    treeDocument.uri,
                                    fileId
                                )
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
        }
    }

    private fun writeFileUri(fileName: String, clearOld: Boolean = false): Uri? {
        val mimeType = if (fileName.endsWith("jpg", ignoreCase = true) || fileName.endsWith(
                "jpeg",
                ignoreCase = true
            )
        ) {
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
                try {
                    var folderDocument: DocumentFile? = treeDocument
                    val fName = names.last()
                    val list = names.subList(0, names.size - 1)
                    for (name in list) {
                        folderDocument = folderDocument!!.findFile(name)
                            ?: folderDocument.createDirectory(name)!!
                    }
                    return folderDocument?.createFile(mimeType, fName)?.uri
                } catch (e: Throwable) {
                    return null
                }
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
        contentResolver.openOutputStream(uri, "w")?.use {
            it.write(data)
        }
    }
}
