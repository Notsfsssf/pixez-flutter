package com.perol.pixez.glance

import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.glance.unit.ColorProvider
import com.perol.pixez.R

object GlanceTheme {
    val colors: ColorProviders
        @Composable
        @ReadOnlyComposable
        get() = LocalColorProviders.current
}

internal val LocalColorProviders = staticCompositionLocalOf { dynamicThemeColorProviders() }

@Composable
fun GlanceTheme(colors: ColorProviders = GlanceTheme.colors, content: @Composable () -> Unit) {
    CompositionLocalProvider(LocalColorProviders provides colors) {
        content()
    }
}

data class ColorProviders(
    val primary: ColorProvider,
    val onPrimary: ColorProvider,
    val primaryContainer: ColorProvider,
    val onPrimaryContainer: ColorProvider,
    val secondary: ColorProvider,
    val onSecondary: ColorProvider,
    val secondaryContainer: ColorProvider,
    val onSecondaryContainer: ColorProvider,
    val tertiary: ColorProvider,
    val onTertiary: ColorProvider,
    val tertiaryContainer: ColorProvider,
    val onTertiaryContainer: ColorProvider,
    val error: ColorProvider,
    val errorContainer: ColorProvider,
    val onError: ColorProvider,
    val onErrorContainer: ColorProvider,
    val background: ColorProvider,
    val onBackground: ColorProvider,
    val surface: ColorProvider,
    val onSurface: ColorProvider,
    val surfaceVariant: ColorProvider,
    val onSurfaceVariant: ColorProvider,
    val outline: ColorProvider,
    val textColorPrimary: ColorProvider,
    val textColorSecondary: ColorProvider,
    val inverseOnSurface: ColorProvider,
    val inverseSurface: ColorProvider,
    val inversePrimary: ColorProvider,
    val inverseTextColorPrimary: ColorProvider,
    val inverseTextColorSecondary: ColorProvider,
)

fun dynamicThemeColorProviders(): ColorProviders {
    return ColorProviders(
        primary = ColorProvider(R.color.colorPrimary),
        onPrimary = ColorProvider(R.color.colorOnPrimary),
        primaryContainer = ColorProvider(R.color.colorPrimaryContainer),
        onPrimaryContainer = ColorProvider(R.color.colorOnPrimaryContainer),
        secondary = ColorProvider(R.color.colorSecondary),
        onSecondary = ColorProvider(R.color.colorOnSecondary),
        secondaryContainer = ColorProvider(R.color.colorSecondaryContainer),
        onSecondaryContainer = ColorProvider(R.color.colorOnSecondaryContainer),
        tertiary = ColorProvider(R.color.colorTertiary),
        onTertiary = ColorProvider(R.color.colorOnTertiary),
        tertiaryContainer = ColorProvider(R.color.colorTertiaryContainer),
        onTertiaryContainer = ColorProvider(R.color.colorOnTertiaryContainer),
        error = ColorProvider(R.color.colorError),
        errorContainer = ColorProvider(R.color.colorErrorContainer),
        onError = ColorProvider(R.color.colorOnError),
        onErrorContainer = ColorProvider(R.color.colorOnErrorContainer),
        background = ColorProvider(R.color.colorBackground),
        onBackground = ColorProvider(R.color.colorOnBackground),
        surface = ColorProvider(R.color.colorSurface),
        onSurface = ColorProvider(R.color.colorOnSurface),
        surfaceVariant = ColorProvider(R.color.colorSurfaceVariant),
        onSurfaceVariant = ColorProvider(R.color.colorOnSurfaceVariant),
        outline = ColorProvider(R.color.colorOutline),
        textColorPrimary = ColorProvider(R.color.textColorPrimary),
        textColorSecondary = ColorProvider(R.color.textColorSecondary),
        inverseOnSurface = ColorProvider(R.color.colorOnSurfaceInverse),
        inverseSurface = ColorProvider(R.color.colorSurfaceInverse),
        inversePrimary = ColorProvider(R.color.colorPrimaryInverse),
        inverseTextColorPrimary = ColorProvider(R.color.textColorPrimaryInverse),
        inverseTextColorSecondary = ColorProvider(R.color.textColorSecondaryInverse),
    )
}