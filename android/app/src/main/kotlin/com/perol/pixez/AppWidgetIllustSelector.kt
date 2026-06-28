package com.perol.pixez

import android.content.Context
import com.perol.pixez.glance.GlanceDBManager
import com.perol.pixez.glance.GlanceIllust

private const val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"
private const val WIDGET_ILLUST_TYPE_KEY = "flutter.widget_illust_type"
private val supportedWidgetTypes = listOf("recom", "rank", "follow_illust")

fun selectAppWidgetIllust(context: Context, glanceDBManager: GlanceDBManager): GlanceIllust? {
    val sharedPreferences =
        context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
    val selectedType = sharedPreferences.getString(WIDGET_ILLUST_TYPE_KEY, "recom") ?: "recom"
    val normalizedType = selectedType.takeIf { it in supportedWidgetTypes } ?: "recom"

    return runCatching { glanceDBManager.fetch(context, normalizedType).randomOrNull() }.getOrNull()
}
