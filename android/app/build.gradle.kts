/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */
import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

var dartEnvironmentVariables = mutableMapOf(
    "IS_GOOGLEPLAY" to false
)

if (project.hasProperty("dart-defines")) {
    dartEnvironmentVariables.putAll(
        (project.property("dart-defines") as String)
            .split(',')
            .associate { entry ->
                val pair = String(Base64.getDecoder().decode(entry)).split('=')
                pair.first() to (pair.last() == "true")
            }
    )
}

//println("\n" +
//        "______ _______   __ _____ ______\n" +
//        "| ___ \\_   _\\ \\ / /|  ___|___  /\n" +
//        "| |_/ / | |  \\ V / | |__    / / \n" +
//        "|  __/  | |  /   \\ |  __|  / /  \n" +
//        "| |    _| |_/ /^\\ \\| |___./ /___\n" +
//        "\\_|    \\\___/\\/   \\\_/\\____/\\_____/\n" +
//        "                                \n" +
//        "                                \n")
println("hey, IS_GOOGLEPLAY=${dartEnvironmentVariables["IS_GOOGLEPLAY"]}")

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

val packageName = if (dartEnvironmentVariables["IS_GOOGLEPLAY"] as Boolean) {
    "com.perol.play.pixez"
} else {
    "com.perol.pixez"
}

android {
    namespace = "com.perol.pixez"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }


    defaultConfig {
        applicationId = packageName
        minSdk = 21
        targetSdk = 35
        versionCode = 10009616
        versionName = "0.9.62 X"
        ndk {
            abiFilters.addAll(arrayOf("armeabi-v7a", "arm64-v8a", "x86_64"))
        }
    }
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-remoteviews:1.1.0")
    implementation("androidx.annotation:annotation:1.9.1")
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.aar"))))
//    implementation project(":weiss")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.7")
    implementation("com.google.android.material:material:1.12.0")
    implementation("io.coil-kt.coil3:coil:3.1.0")
    implementation("io.coil-kt.coil3:coil-network-okhttp:3.1.0")
//    implementation("androidx.webkit:webkit:1.4.0")
    implementation("androidx.browser:browser:1.8.0")
    implementation("io.github.waynejo:androidndkgif:1.0.1")
    implementation("androidx.preference:preference-ktx:1.2.1")
    implementation("androidx.documentfile:documentfile:1.0.1")
}