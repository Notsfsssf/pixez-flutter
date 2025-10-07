plugins {
    id("com.android.library")
}

android {
    namespace = "com.waynejo.androidndkgif"
    compileSdk = 36

    defaultConfig {
        minSdk = 21
        ndk {
            abiFilters += listOf("arm64-v8a", "x86_64", "armeabi-v7a", "x86")
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

}

dependencies {
}