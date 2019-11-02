//package com.perol.pixez.glance
//
//import android.appwidget.AppWidgetManager
//import android.content.Context
//import android.content.Intent
//import android.graphics.BitmapFactory
//import android.net.Uri
//import androidx.compose.runtime.Composable
//import androidx.compose.runtime.LaunchedEffect
//import androidx.compose.runtime.SideEffect
//import androidx.compose.ui.unit.dp
//import androidx.compose.ui.unit.sp
//import androidx.datastore.preferences.core.stringPreferencesKey
//import androidx.glance.*
//import androidx.glance.action.ActionParameters
//import androidx.glance.action.clickable
//import androidx.glance.appwidget.*
//import androidx.glance.appwidget.action.ActionCallback
//import androidx.glance.appwidget.action.actionRunCallback
//import androidx.glance.appwidget.action.actionStartActivity
//import androidx.glance.layout.*
//import androidx.glance.text.Text
//import androidx.glance.text.TextAlign
//import androidx.glance.text.TextStyle
//import com.perol.pixez.R
//import kotlinx.coroutines.GlobalScope
//import kotlinx.coroutines.launch
//
//class ImageGlanceWidget : GlanceAppWidget() {
//
//    companion object {
//        val sourceUrlKey = stringPreferencesKey("app_widget_image_source_url")
//        val illustIdKey = stringPreferencesKey("app_widget_illust_id")
//        val userLinkKey = stringPreferencesKey("app_widget_user_link")
//        val titleKey = stringPreferencesKey("app_widget_title")
//        val userNameKey = stringPreferencesKey("app_widget_user_name")
//    }
//
//    override val sizeMode: SizeMode = SizeMode.Exact
//
//    @Composable
//    override fun Content() {
//        val context = LocalContext.current
//        val size = LocalSize.current
//        val imagePath = currentState(sourceUrlKey)
//        GlanceTheme {
//            Box(
//                modifier = GlanceModifier
//                    .fillMaxSize()
//                    .appWidgetBackground()
//                    .background(GlanceTheme.colors.background)
//                    .appWidgetBackgroundCornerRadius(),
//                contentAlignment = if (imagePath == null) {
//                    Alignment.Center
//                } else {
//                    Alignment.BottomEnd
//                }
//            ) {
//                val illustLink = currentState(illustIdKey)
//                val userLink = currentState(userLinkKey)
//                if (imagePath != null && !illustLink.isNullOrBlank()) {
//                    Image(
//                        provider = getImageProvider(imagePath),
//                        contentDescription = null,
//                        contentScale = ContentScale.Crop,
//                        modifier = GlanceModifier
//                            .fillMaxSize()
//                            .clickable(
//                                actionStartActivity(
//                                    Intent(Intent.ACTION_VIEW, Uri.parse(illustLink))
//                                )
//                            )
//                    )
//
//                    Row(
//                        GlanceModifier.fillMaxWidth().padding(16.dp)
//                            .background(ImageProvider(R.drawable.widget_gradient)),
//                        verticalAlignment = Alignment.CenterVertically
//                    ) {
//                        Column(GlanceModifier.defaultWeight()) {
//                            Text(
//                                text = "${currentState(titleKey)}",
//                                maxLines = 1,
//                                style = TextStyle(
//                                    color = GlanceTheme.colors.textColorPrimary,
//                                    fontSize = 16.sp
//                                ),
//                                modifier = GlanceModifier.clickable(
//                                    actionStartActivity(
//                                        Intent(Intent.ACTION_VIEW, Uri.parse(illustLink))
//                                    )
//                                )
//                            )
//                            Text(
//                                text = "${currentState(userNameKey)}",
//                                maxLines = 1,
//                                style = TextStyle(
//                                    color = GlanceTheme.colors.textColorPrimary,
//                                    fontSize = 14.sp
//                                ),
//                                modifier = GlanceModifier.clickable(
//                                    actionStartActivity(
//                                        Intent(Intent.ACTION_VIEW, Uri.parse(userLink))
//                                    )
//                                )
//                            )
//                        }
//                        Image(
//                            provider = ImageProvider(R.drawable.ic_baseline_refresh),
//                            contentDescription = "refresh",
//                            modifier = GlanceModifier.size(21.dp)
//                                .clickable(actionRunCallback<RefreshAction>())
//                        )
//                    }
//                } else {
//                    Column(
//                        GlanceModifier.fillMaxWidth(),
//                        horizontalAlignment = Alignment.CenterHorizontally
//                    ) {
//                        CircularProgressIndicator()
//                        Text(
//                            text = "Please view more illusts in app",
//                            modifier = GlanceModifier.padding(16.dp),
//                            style = TextStyle(textAlign = TextAlign.Center)
//                        )
//                    }
//                    val glanceId = LocalGlanceId.current
//                    SideEffect {
//                        ImageWorker.enqueue(context, size, glanceId)
//                    }
//                }
//            }
//        }
//    }
//
//    override suspend fun onDelete(context: Context, glanceId: GlanceId) {
//        super.onDelete(context, glanceId)
//        ImageWorker.cancel(context, glanceId)
//    }
//
//    private fun getImageProvider(path: String): ImageProvider {
//        val bitmap = BitmapFactory.decodeFile(path)
//        return ImageProvider(bitmap)
//    }
//}
//
//class RefreshAction : ActionCallback {
//    override suspend fun onAction(
//        context: Context,
//        glanceId: GlanceId,
//        parameters: ActionParameters
//    ) {
////        updateAppWidgetState(context, glanceId) { prefs ->
////            prefs.clear()
////        }
////        ImageGlanceWidget().update(context, glanceId)
//        GlanceAppWidgetManager(context).getAppWidgetSizes(glanceId).forEach { size ->
//            ImageWorker.enqueue(context, size, glanceId, force = true)
//        }
//    }
//}
//
//class ImageGlanceWidgetReceiver : GlanceAppWidgetReceiver() {
//    override val glanceAppWidget: GlanceAppWidget = ImageGlanceWidget()
///*
//
//    override fun onUpdate(
//        context: Context,
//        appWidgetManager: AppWidgetManager,
//        appWidgetIds: IntArray
//    ) {
//        super.onUpdate(context, appWidgetManager, appWidgetIds)
//        for (i in appWidgetIds) {
//            val glanceAppWidgetManager = GlanceAppWidgetManager(context)
//            val glanceIdBy = glanceAppWidgetManager.getGlanceIdBy(i)
//            GlobalScope.launch {
//                glanceAppWidgetManager.getAppWidgetSizes(glanceIdBy).forEach { size ->
//                    ImageWorker.enqueue(context, size, glanceIdBy, force = false)
//                }
//            }
//        }
//    }
//*/
//}