//package com.perol.pixez.glance
//
//import android.content.res.Resources
//import android.os.Build
//import androidx.annotation.StringRes
//import androidx.compose.runtime.Composable
//import androidx.compose.ui.unit.dp
//import androidx.glance.GlanceModifier
//import androidx.glance.LocalContext
//import androidx.glance.appwidget.cornerRadius
//
//fun GlanceModifier.appWidgetBackgroundCornerRadius(): GlanceModifier {
//    if (Build.VERSION.SDK_INT >= 31) {
//        cornerRadius(android.R.dimen.system_app_widget_background_radius)
//    } else {
//        cornerRadius(16.dp)
//    }
//    return this
//}
//
//fun GlanceModifier.appWidgetInnerCornerRadius(): GlanceModifier {
//    if (Build.VERSION.SDK_INT >= 31) {
//        cornerRadius(android.R.dimen.system_app_widget_inner_radius)
//    } else {
//        cornerRadius(8.dp)
//    }
//    return this
//}
//
//@Composable
//fun stringResource(@StringRes id: Int, vararg args: Any): String {
//    return LocalContext.current.getString(id, args)
//}
//
//val Float.toPx get() = this * Resources.getSystem().displayMetrics.density