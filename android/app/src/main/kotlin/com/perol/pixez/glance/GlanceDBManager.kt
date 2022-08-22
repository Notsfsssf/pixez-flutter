package com.perol.pixez.glance

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import androidx.work.impl.WorkDatabasePathHelper.getDatabasePath
import com.perol.pixez.PixEz
import com.tekartik.sqflite.SqflitePlugin
import java.io.File

data class GlanceIllust(
    val id: String,
    val illustId: Long,
    val title: String,
    val userId: String,
    val userName: String,
    val pictureUrl: String
)

class GlanceDBManager {
    companion object {
        const val TABLE_NAME = "glanceillustpersist"
        const val TABLE_FILE_NAME = "glanceillustpersist.db"
        const val COLUMN_ID = "id"
        const val COLUMN_TITLE = "title"
        const val COLUMN_ILLUST_ID = "illust_id"
        const val COLUMN_USER_ID = "user_id"
        const val COLUMN_PICTURE_URL = "picture_url"
        const val COLUMN_USER_NAME = "user_name"
    }

    fun fetch(context: Context): ArrayList<GlanceIllust> {
        val dummyDatabaseName = "tekartik_sqflite.db"
        val file: File = context.getDatabasePath(dummyDatabaseName)
        val path = file.parent
        val database = SQLiteDatabase.openDatabase(
            "${path}/${TABLE_FILE_NAME}", null,
            SQLiteDatabase.OPEN_READONLY
        )
        val cursor = database.rawQuery("select * from ${TABLE_NAME} ORDER BY RANDOM() LIMIT 1", arrayOf())
        cursor.moveToFirst()
        val result = arrayListOf<GlanceIllust>()
        do {
            kotlin.runCatching {
                val illustId = cursor.getLong(cursor.getColumnIndexOrThrow(COLUMN_ILLUST_ID))
                val id = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_ID))
                val userId = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_USER_ID))
                val pictureUrl = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_PICTURE_URL))
                val userName = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_USER_NAME))
                val title = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_TITLE))
                result.add(GlanceIllust(id, illustId, title, userId, userName, pictureUrl))
            }
        } while (cursor.moveToNext())
        cursor.close()
        database.close()
        return result
    }
}