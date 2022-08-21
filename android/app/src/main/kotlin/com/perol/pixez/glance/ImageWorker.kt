package com.perol.pixez.glance

import android.content.Context
import android.net.Uri
import android.util.Log
import androidx.compose.ui.unit.DpSize
import androidx.glance.GlanceId
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.appwidget.updateAll
import androidx.work.*
import coil.annotation.ExperimentalCoilApi
import coil.imageLoader
import coil.memory.MemoryCache
import coil.request.ErrorResult
import coil.request.ImageRequest
import kotlin.math.roundToInt

class ImageWorker(
    private val context: Context,
    workerParameters: WorkerParameters
) : CoroutineWorker(context, workerParameters) {

    companion object {

        private val uniqueWorkName = ImageWorker::class.java.simpleName

        fun enqueue(context: Context, size: DpSize, glanceId: GlanceId, force: Boolean = false) {
            val manager = WorkManager.getInstance(context)
            val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(glanceId)
            val requestBuilder = OneTimeWorkRequestBuilder<ImageWorker>().apply {
                addTag(glanceId.toString())
                setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                setInputData(
                    Data.Builder()
                        .putFloat("width", size.width.value.toPx)
                        .putFloat("height", size.height.value.toPx)
                        .putInt(
                            "widget_id",
                            appWidgetId
                        )
                        .putBoolean("force", force)
                        .build()
                )
            }
            val workPolicy = if (force) {
                ExistingWorkPolicy.REPLACE
            } else {
                ExistingWorkPolicy.KEEP
            }

            manager.enqueueUniqueWork(
                uniqueWorkName + appWidgetId,
                workPolicy,
                requestBuilder.build()
            )
//            manager.enqueueUniqueWork(
//                "$uniqueWorkName-workaround",
//                ExistingWorkPolicy.KEEP,
//                OneTimeWorkRequestBuilder<ImageWorker>().apply {
//                    setInitialDelay(Duration.ofDays(365))
//                }.build()
//            )
        }

        fun cancel(context: Context, glanceId: GlanceId) {
            WorkManager.getInstance(context).cancelAllWorkByTag(glanceId.toString())
        }
    }

    override suspend fun doWork(): Result {
        return try {
            val widgetId = inputData.getInt("widget_id", -1)
            if (widgetId == -1)
                return Result.failure()
            val glanceAppWidgetManager = GlanceAppWidgetManager(context)
            val list = GlanceDBManager().fetch(context)
            if (list.isEmpty())
                return Result.failure()
            val glanceIllust = list.random()
            val uri = getPictureUrl(glanceIllust.pictureUrl)
            updateImageWidget(glanceAppWidgetManager.getGlanceIdBy(widgetId), glanceIllust, uri)
            Result.success()
        } catch (e: Exception) {
            Log.e(uniqueWorkName, "Error while loading image", e)
            if (runAttemptCount < 10) {
                Result.retry()
            } else {
                Result.failure()
            }
        }
    }

    private suspend fun updateImageWidget(
        glanceId: GlanceId,
        glanceIllust: GlanceIllust,
        url: String
    ) {
        updateAppWidgetState(context, glanceId) { prefs ->
            prefs[ImageGlanceWidget.sourceUrlKey] = url
            prefs[ImageGlanceWidget.illustIdKey] = "pixez://pixiv.net/artworks/${glanceIllust.illustId}"
            prefs[ImageGlanceWidget.userLinkKey] = "pixez://pixiv.net/users/${glanceIllust.userId}"
            prefs[ImageGlanceWidget.titleKey] = glanceIllust.title
            prefs[ImageGlanceWidget.userNameKey] = glanceIllust.userName
        }
//        ImageGlanceWidget().updateAll(context)
    }

    @OptIn(ExperimentalCoilApi::class)
    private suspend fun getPictureUrl(url: String): String {
        val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"
        val sharedPreferences =
            context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        val host = sharedPreferences.getString("flutter.picture_source", null)
        val request = ImageRequest.Builder(context)
            .setHeader("referer", "https://app-api.pixiv.net/")
            .setHeader("User-Agent", "PixivIOSApp/5.8.0")
            .data(url)
            .build()

        val trueUrl = if (host != null) {
            url.replace("i.pximg.net", host)
        } else {
            url
        }

        with(context.imageLoader) {
            if (true) {
//                diskCache?.remove(url)
                memoryCache?.remove(MemoryCache.Key(trueUrl))
            }
            val result = execute(request)
            if (result is ErrorResult) {
                throw result.throwable
            }
        }

        val path = context.imageLoader.diskCache?.get(trueUrl)?.use { snapshot ->
            snapshot.data.toFile().path
        }
        return requireNotNull(path) {
            "Couldn't find cached file"
        }
    }
}