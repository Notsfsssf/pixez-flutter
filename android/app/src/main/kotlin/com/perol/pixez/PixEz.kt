package com.perol.pixez

import com.google.android.play.core.missingsplits.MissingSplitsManagerFactory
import io.flutter.app.FlutterApplication

class PixEz : FlutterApplication() {
    override fun onCreate() {
        if (MissingSplitsManagerFactory.create(this).disableAppIfMissingRequiredSplits()) {
            // Skip app initialization.
            return
        }
        super.onCreate()

    }
}