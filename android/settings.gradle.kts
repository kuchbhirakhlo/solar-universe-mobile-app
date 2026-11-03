pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Pinned to a mature AGP 8.x release, not the newer 9.x line: AGP 9+
    // changed how Kotlin gets applied to library modules (implicit rather
    // than each module applying org.jetbrains.kotlin.android itself), and
    // file_picker (and likely other plugins) explicitly skip applying
    // Kotlin when they detect AGP>=9 — on this Flutter SDK version that
    // left file_picker's Kotlin sources uncompiled ("cannot find symbol:
    // FilePickerPlugin"). AGP 8.x is the well-tested, broadly-supported path.
    id("com.android.application") version "8.9.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
