import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.FileNotFoundException

group = "com.flutter_rust_bridge.rhttp"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.2.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.11.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        classpath("org.jetbrains.kotlinx:kotlinx-serialization-json:1.11.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}

apply(plugin = "org.jetbrains.kotlin.android")

android {
    namespace = "com.flutter_rust_bridge.rhttp"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }
}

project.extensions.configure(org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension::class.java) {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

apply(from = "../cargokit/gradle/plugin.gradle")

extensions.getByName("cargokit").withGroovyBuilder {
    setProperty("manifestDir", "../rust")
    setProperty("libname", "rhttp")
}

fun findCargo(): String {
    val isWindows = System.getProperty("os.name").lowercase().contains("win")
    val exe = if (isWindows) "cargo.exe" else "cargo"

    val home = System.getProperty("user.home")

    val candidates = mutableListOf<String>()

    // Check if cargo is resolvable from the PATH (normally this should work, but there are edge
    // cases, in which the fallbacks below may need to be used).
    if (isCargo("cargo")) {
        return "cargo"
    }

    // 1. CARGO_HOME
    val cargoHome = System.getenv("CARGO_HOME")
    if (cargoHome != null) {
        candidates += "$cargoHome/bin/$exe"
    }

    // 2. Default cargo home
    candidates += "$home/.cargo/bin/$exe"

    // 3. Common installation locations
    candidates += listOf(
        "/opt/homebrew/bin/cargo",   // macOS (Apple Silicon)
        "/usr/local/bin/cargo",      // macOS (Intel) / Linux
        "/usr/bin/cargo",            // Linux
    )

    // 4. Check candidates
    candidates.firstOrNull { File(it).exists() }?.let {
        if (File(it).canExecute() && isCargo(it)) {
            return it
        }
    }

    throw FileNotFoundException("Unable to find cargo executable")
}

fun findRustlsPlatformVerifierAar(): File {
    val dependencyJson = providers.exec {
        workingDir = project.file("../rust/")
        commandLine(findCargo(), "metadata", "--format-version", "1")
    }.standardOutput.asText

    val pkg = Json.decodeFromString<JsonObject>(dependencyJson.get())
        .getValue("packages")
        .jsonArray
        .first { element ->
            element.jsonObject.getValue("name").jsonPrimitive.content == "rustls-platform-verifier-android"
        }.jsonObject

    val manifestPath = pkg.getValue("manifest_path").jsonPrimitive.content
    val version = pkg.getValue("version").jsonPrimitive.content
    val crateRoot = File(manifestPath).parentFile
    return File(crateRoot, "maven/rustls/rustls-platform-verifier/$version/rustls-platform-verifier-$version.aar")
}

fun extractRustlsPlatformVerifierClasses(): File {
    val aar = findRustlsPlatformVerifierAar()
    val outDir = File(layout.buildDirectory.get().asFile, "rustls-platform-verifier")
    val out = File(outDir, "classes.jar")
    if (!out.exists() || aar.lastModified() > out.lastModified()) {
        outDir.mkdirs()
        copy {
            from(zipTree(aar)) { include("classes.jar") }
            into(outDir)
        }
    }
    return out
}

fun isCargo(executable: String): Boolean {
    return try {
        val result = providers.exec {
            commandLine(executable, "--version")
            isIgnoreExitValue = true
        }

        val exitOk = result.result.get().exitValue == 0
        val output = result.standardOutput.asText.get()

        exitOk && output.contains("cargo")
    } catch (e: Exception) {
        false
    }
}

dependencies {
    implementation(files(extractRustlsPlatformVerifierClasses()))
}