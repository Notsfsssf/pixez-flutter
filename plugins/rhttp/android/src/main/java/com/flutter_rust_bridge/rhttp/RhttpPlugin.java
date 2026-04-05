package com.flutter_rust_bridge.rhttp;

import android.content.Context;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

public final class RhttpPlugin implements FlutterPlugin {
    static {
        System.loadLibrary("rhttp");
    }

    private static native boolean nativeInitPlatformVerifier(Context context);

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        if (!nativeInitPlatformVerifier(binding.getApplicationContext())) {
            throw new IllegalStateException(
                "Failed to initialize rustls-platform-verifier for Android"
            );
        }
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {}
}
