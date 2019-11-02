//package com.perol.pixez.glance
//
//import android.app.NotificationChannel
//import android.app.NotificationManager
//import android.content.Context
//import android.os.Build
//import android.util.Log
//import androidx.compose.ui.unit.DpSize
//import androidx.core.app.NotificationCompat
//import androidx.glance.GlanceId
//import androidx.glance.appwidget.GlanceAppWidgetManager
//import androidx.glance.appwidget.state.updateAppWidgetState
//import androidx.work.*
//import coil.annotation.ExperimentalCoilApi
//import coil.imageLoader
//import coil.memory.MemoryCache
//import coil.request.ErrorResult
//import coil.request.ImageRequest
//import com.perol.pixez.R
//
//class ImageWorker(
//    private val context: Context,
//    workerParameters: WorkerParameters
//) : CoroutineWorker(context, workerParameters) {
//
//    companion object {
//
//        private val uniqueWorkName = ImageWorker::class.java.simpleName
//
//        fun enqueue(context: Context, size: DpSize, glanceId: GlanceId, force: Boolean = false) {
//            val manager = WorkManager.getInstance(context)
//            val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(glanceId)
//            val requestBuilder = OneTimeWorkRequestBuilder<ImageWorker>().apply {
//                addTag(glanceId.toString())
//                setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
//                setInputData(
//                    Data.Builder()
//                        .putFloat("width", size.width.value.toPx)
//                        .putFloat("height", size.height.value.toPx)
//                        .putInt(
//                            "widget_id",
//                            appWidgetId
//                        )
//                        .putBoolean("force", force)
//                        .build()
//                )
//            }
//            val workPolicy = if (force) {
//                ExistingWorkPolicy.REPLACE
//            } else {
//                ExistingWorkPolicy.KEEP
//            }
//
//            manager.enqueueUniqueWork(
//                uniqueWorkName + appWidgetId,
//                workPolicy,
//                requestBuilder.build()
//            )
////            manager.enqueueUniqueWork(
////                "$uniqueWorkName-workaround",
////                ExistingWorkPolicy.KEEP,
////                OneTimeWorkRequestBuilder<ImageWorker>().apply {
////                    setInitialDelay(Duration.ofDays(365))
////                }.build()
////            )
//        }
//
//        fun cancel(context: Context, glanceId: GlanceId) {
//            WorkManager.getInstance(context).cancelAllWorkByTag(glanceId.toString())
//        }
//    }
//
//    override suspend fun doWork(): Result {
//        return try {
//            val widgetId = inputData.getInt("widget_id", -1)
//            val width = inputData.getFloat("width", 100f)
//            val height = inputData.getFloat("height", 100f)
//            val sharedPreferences =
//                context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
//            val type = sharedPreferences.getString("flutter.widget_illust_type", "recom") ?: "recom"
//            if (widgetId == -1)
//                return Result.failure()
//            val glanceAppWidgetManager = GlanceAppWidgetManager(context)
//            val list = GlanceDBManager().fetch(context, type)
//            if (list.isEmpty())
//                return Result.failure()
//            val glanceIllust = list.random()
//            val uri = getPictureUrl(glanceIllust.pictureUrl, width, height)
//            updateImageWidget(glanceAppWidgetManager.getGlanceIdBy(widgetId), glanceIllust, uri)
//            Result.success()
//        } catch (e: Exception) {
//            Log.e(uniqueWorkName, "Error while loading image", e)
//            if (runAttemptCount < 10) {
//                Result.retry()
//            } else {
//                Result.failure()
//            }
//        }
//    }
//
//    private suspend fun updateImageWidget(
//        glanceId: GlanceId,
//        glanceIllust: GlanceIllust,
//        url: String
//    ) {
//        updateAppWidgetState(context, glanceId) { prefs ->
//            prefs[ImageGlanceWidget.sourceUrlKey] = url
//            prefs[ImageGlanceWidget.illustIdKey] =
//                "pixez://pixiv.net/artworks/${glanceIllust.illustId}"
//            prefs[ImageGlanceWidget.userLinkKey] = "pixez://pixiv.net/users/${glanceIllust.userId}"
//            prefs[ImageGlanceWidget.titleKey] = glanceIllust.title
//            prefs[ImageGlanceWidget.userNameKey] = glanceIllust.userName
//        }
////        ImageGlanceWidget().updateAll(context)
//    }
//
//    override suspend fun getForegroundInfo(): ForegroundInfo {
//        val CHANNEL_ID = "AppWidget"
//        val builder: NotificationCompat.Builder = NotificationCompat.Builder(context, CHANNEL_ID)
//        builder.setContentTitle("Fetching")
//        builder.setSmallIcon(R.drawable.ic_stat_name)
//        builder.setContentText("Fetching widget illust")
//        builder.setWhen(System.currentTimeMillis())
//        val notifyManager =
//            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            genNotificationChannel(CHANNEL_ID, "AppWidget")?.let {
//                notifyManager.createNotificationChannel(it)
//            }
//        }
//        return ForegroundInfo(
//            randomRange(0, 1000), builder.build()
//        )
//    }
//
//    private fun genNotificationChannel(id: String?, name: String?): NotificationChannel? {
//        var channel: NotificationChannel? = null
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            channel = NotificationChannel(id, name, NotificationManager.IMPORTANCE_HIGH)
//            channel.enableLights(true)
//            channel.setShowBadge(true)
//        }
//        return channel
//    }
//
//    private fun randomRange(start: Int, end: Int): Int {
//        val range = end - start
//        return (Math.random() * range).toInt() + start
//    }
//
//    @OptIn(ExperimentalCoilApi::class)
//    private suspend fun getPictureUrl(url: String, width: Float, height: Float): String {
//        val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"
//        val sharedPreferences =
//            context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
//        val host = sharedPreferences.getString("flutter.picture_source", null)
//        val request = ImageRequest.Builder(context)
//            .setHeader("referer", "https://app-api.pixiv.net/")
//            .setHeader("User-Agent", "PixivIOSApp/5.8.0")
//            .size(width.toInt(), height.toInt())
//            .data(url)
//            .build()
//
//        val trueUrl = if (host != null) {
//            url.replace("i.pximg.net", host)
//        } else {
//            url
//        }
//
//        with(context.imageLoader) {
//            if (true) {
////                diskCache?.remove(url)
//                memoryCache?.remove(MemoryCache.Key(trueUrl))
//            }
//            val result = execute(request)
//            if (result is ErrorResult) {
//                throw result.throwable
//            }
//        }
//
//        val path = context.imageLoader.diskCache?.get(trueUrl)?.use { snapshot ->
//            snapshot.data.toFile().path
//        }
//        return requireNotNull(path) {
//            "Couldn't find cached file"
//        }
//    }
//}