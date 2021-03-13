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

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import java.io.OutputStream

fun Context.save(byteArray: ByteArray, name: String) {
    val values = ContentValues();
    values.put(MediaStore.MediaColumns.DISPLAY_NAME, name.split("/").last())
    values.put(MediaStore.MediaColumns.MIME_TYPE, if (name.endsWith("png")) {
        "image/png"
    } else {
        "image/jpeg"
    })

    val path = if (name.contains("/")) {
        "${Environment.DIRECTORY_PICTURES}/PixEz/${name.split("/").first()}"
    } else {
        "${Environment.DIRECTORY_PICTURES}/PixEz"
    }
    values.put(MediaStore.MediaColumns.RELATIVE_PATH, path);
    var uri: Uri? = null
    var outputStream: OutputStream? = null
    try {
        uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
        outputStream = contentResolver.openOutputStream(uri!!)!!
        outputStream.write(byteArray)
        outputStream.flush()
        outputStream.close()
    } catch (e: Exception) {
        if (uri != null) {
            contentResolver.delete(uri, null, null);
        }
    } finally {
        outputStream?.close()
    }
}

fun Context.exist(name: String): Boolean {
    val projection = arrayOf(
            MediaStore.Images.Media._ID,
    )
    val path = if (name.contains("/")) {
        "${Environment.DIRECTORY_PICTURES}/PixEz/${name.split("/").first()}"
    } else {
        "${Environment.DIRECTORY_PICTURES}/PixEz"
    }
    //想不到吧？居然是这样写？
    //咕噜咕噜，这不翻源码写的出来？
    val selection = "${MediaStore.Images.Media.RELATIVE_PATH} LIKE ? AND ${MediaStore.Images.Media.DISPLAY_NAME} = ?"
    val selectionArgs = arrayOf(
            "%${path}%",
            name.split("/").last(),
    )
    val sortOrder = "${MediaStore.Images.Media.DISPLAY_NAME} ASC"
    val query = contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            sortOrder
    )
    query?.use { cursor ->
        while (cursor.moveToNext()) {
            return true
        }
    }
    return false
}