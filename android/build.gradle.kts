allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    // Plugin build.gradle files expect a `flutter` extra (compileSdk, etc.) before
    // evaluation; the loader supplies this on newer Flutter SDKs — set it here too
    // so release APK builds work across toolchain versions.
    beforeEvaluate {
        if (name == "app") return@beforeEvaluate
        val flutterSdk = hashMapOf<String, Any>(
            "compileSdkVersion" to 36,
            "minSdkVersion" to 24,
            "targetSdkVersion" to 35,
            "ndkVersion" to "27.0.12077973",
        )
        extensions.extraProperties.set("flutter", flutterSdk)
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
