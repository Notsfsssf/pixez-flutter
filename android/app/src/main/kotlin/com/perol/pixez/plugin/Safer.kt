package com.perol.pixez.plugin

import android.app.Activity
import android.content.ContentUris
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.provider.DocumentsContract
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException

object Safer {
    private const val SAF_CHANNEL = "com.perol.dev/saf"
    private const val CREATE_FILE_CODE = 1111
    private const val OPEN_FILE_CODE = 2222
    private const val PICK_DIR_CODE = 3333
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

                "saveToDownloads" -> {
                    val name = call.argument<String>("name")!!
                    val mimeType = call.argument<String>("mimeType") ?: "text/plain"
                    val data = call.argument<ByteArray>("data")!!
                    val relativePath = call.argument<String>("relativePath") ?: "PixEz"
                    saveToDownloads(activity, name, mimeType, data, relativePath, result)
                }

                "pickSaveDir" -> {
                    pendingResult = result
                    activity.pickSaveDir()
                }

                "saveToTree" -> {
                    val treeUri = call.argument<String>("treeUri")!!
                    val name = call.argument<String>("name")!!
                    val mimeType = call.argument<String>("mimeType") ?: "text/plain"
                    val data = call.argument<ByteArray>("data")!!
                    val subDir = call.argument<String>("subDir")
                    saveToTree(activity, treeUri, name, mimeType, data, subDir, result)
                }
            }
        }
    }

    /// 直接落盘到 Download/<relativePath>/<name>，无需系统选择器。
    /// Android 10 (Q) 以下写公共目录需要运行时存储权限，这里直接返回错误让 Dart 侧回退到 SAF。
    private fun saveToDownloads(
        activity: Activity,
        name: String,
        mimeType: String,
        data: ByteArray,
        relativePath: String,
        result: MethodChannel.Result,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            Handler(Looper.getMainLooper()).post {
                result.error("unsupported", "Android 10 以下请使用另存为", null)
            }
            return
        }
        Thread {
            try {
                val resolver = activity.contentResolver
                val collection = MediaStore.Downloads.getContentUri(
                    MediaStore.VOLUME_EXTERNAL_PRIMARY
                )
                val relativeDir = "${Environment.DIRECTORY_DOWNLOADS}/$relativePath"
                // 同名文件先删除，避免反复保存产生 "标题 (1).txt"
                runCatching {
                    resolver.query(
                        collection,
                        arrayOf(MediaStore.MediaColumns._ID),
                        "${MediaStore.MediaColumns.DISPLAY_NAME}=? AND " +
                            "${MediaStore.MediaColumns.RELATIVE_PATH}=?",
                        arrayOf(name, "$relativeDir/"),
                        null
                    )?.use { cursor ->
                        if (cursor.moveToFirst()) {
                            val old = ContentUris.withAppendedId(
                                collection, cursor.getLong(0)
                            )
                            resolver.delete(old, null, null)
                        }
                    }
                }
                val values = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, name)
                    put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                    put(MediaStore.MediaColumns.RELATIVE_PATH, relativeDir)
                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                }
                val uri = resolver.insert(collection, values)
                    ?: throw IOException("insert failed")
                resolver.openOutputStream(uri)?.use { it.write(data) }
                    ?: throw IOException("open output stream failed")
                val done = ContentValues().apply {
                    put(MediaStore.MediaColumns.IS_PENDING, 0)
                }
                resolver.update(uri, done, null, null)
                val savedPath = "Download/$relativePath/$name"
                Handler(Looper.getMainLooper()).post { result.success(savedPath) }
            } catch (e: Throwable) {
                Handler(Looper.getMainLooper()).post {
                    result.error("save_failed", e.message ?: "save failed", null)
                }
            }
        }.start()
    }

    fun Activity.createFile(name: String, mimeType: String) {
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, name)
        }
        startActivityForResult(intent, CREATE_FILE_CODE)
    }

    /// 打开系统目录选择器（SAF），用于自定义小说的保存位置。
    fun Activity.pickSaveDir() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION
                    or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
            )
        }
        startActivityForResult(intent, PICK_DIR_CODE)
    }

    /// 把用户可读的目录名转出来，例如 primary:Download/Novel -> 内部存储/Download/Novel
    private fun treeDisplay(activity: Activity, uri: Uri): String {
        return try {
            val docId = DocumentsContract.getTreeDocumentId(uri)
            when {
                docId.startsWith("primary:") ->
                    "内部存储/" + docId.removePrefix("primary:")
                docId.startsWith("home:") -> "文档/" + docId.removePrefix("home:")
                docId.contains(":") -> docId.substringAfter(":")
                else -> docId
            }
        } catch (e: Throwable) {
            uri.toString()
        }
    }

    /// 在 tree 目录下解析（必要时创建）子目录，返回 父目录 uri 与路径后缀。
    /// 创建失败时退回 tree 根目录，保证保存不中断。
    private fun resolveSubDir(
        activity: Activity,
        treeUri: Uri,
        subDir: String?,
    ): Pair<Uri, String> {
        val rootDocId = DocumentsContract.getTreeDocumentId(treeUri)
        val rootUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, rootDocId)
        if (subDir.isNullOrBlank()) return rootUri to ""
        return try {
            val resolver = activity.contentResolver
            val childrenUri =
                DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, rootDocId)
            var existDocId: String? = null
            runCatching {
                resolver.query(
                    childrenUri,
                    arrayOf(
                        DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                        DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                        DocumentsContract.Document.COLUMN_MIME_TYPE
                    ),
                    null, null, null
                )?.use { cursor ->
                    while (cursor.moveToNext()) {
                        val mime = cursor.getString(2)
                        if (cursor.getString(1) == subDir &&
                            mime == DocumentsContract.Document.MIME_TYPE_DIR
                        ) {
                            existDocId = cursor.getString(0)
                            break
                        }
                    }
                }
            }
            val docUri = if (existDocId != null) {
                DocumentsContract.buildDocumentUriUsingTree(treeUri, existDocId!!)
            } else {
                DocumentsContract.createDocument(
                    resolver, rootUri, DocumentsContract.Document.MIME_TYPE_DIR, subDir
                )
            }
            if (docUri == null) rootUri to "" else docUri to "/$subDir"
        } catch (e: Throwable) {
            Log.d("Safer", "resolveSubDir: ${e.message}")
            rootUri to ""
        }
    }

    /// 往用户选定的目录（tree uri）里写入文件；可选写入子目录；同名文件先覆盖。
    private fun saveToTree(
        activity: Activity,
        treeUriString: String,
        name: String,
        mimeType: String,
        data: ByteArray,
        subDir: String?,
        result: MethodChannel.Result,
    ) {
        Thread {
            try {
                val resolver = activity.contentResolver
                val treeUri = Uri.parse(treeUriString)
                val (parentDocUri, subSuffix) = resolveSubDir(activity, treeUri, subDir)
                val parentDocId = DocumentsContract.getDocumentId(parentDocUri)
                val childrenUri =
                    DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentDocId)
                // 同名文件先删除，避免生成 "(1)" 副本
                runCatching {
                    resolver.query(
                        childrenUri,
                        arrayOf(
                            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                            DocumentsContract.Document.COLUMN_DISPLAY_NAME
                        ),
                        null, null, null
                    )?.use { cursor ->
                        while (cursor.moveToNext()) {
                            if (cursor.getString(1) == name) {
                                val docUri = DocumentsContract.buildDocumentUriUsingTree(
                                    treeUri, cursor.getString(0)
                                )
                                runCatching {
                                    DocumentsContract.deleteDocument(resolver, docUri)
                                }
                                break
                            }
                        }
                    }
                }
                val newDoc = DocumentsContract.createDocument(
                    resolver, parentDocUri, mimeType, name
                ) ?: throw IOException("create document failed")
                resolver.openOutputStream(newDoc)?.use { it.write(data) }
                    ?: throw IOException("open output stream failed")
                val savedPath = "${treeDisplay(activity, treeUri)}$subSuffix/$name"
                Handler(Looper.getMainLooper()).post { result.success(savedPath) }
            } catch (e: Throwable) {
                Handler(Looper.getMainLooper()).post {
                    result.error("save_failed", e.message ?: "save failed", null)
                }
            }
        }.start()
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

                PICK_DIR_CODE -> {
                    val uri = data?.data
                    if (uri != null) {
                        // 持久化读写权限，App 重启后仍可写入该目录
                        try {
                            val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                            activity.contentResolver
                                .takePersistableUriPermission(uri, flags)
                        } catch (e: Throwable) {
                            Log.d("Safer", "persist permission: ${e.message}")
                        }
                        pendingResult?.success(
                            mapOf(
                                "uri" to uri.toString(),
                                "display" to treeDisplay(activity, uri)
                            )
                        )
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
            pendingResult?.success("${uri}")
            pendingResult = null
        } catch (e: Throwable) {
            pendingResult?.error("d", "d", "d")
            pendingResult = null
        }
    }
}