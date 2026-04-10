plugins {
    id("com.android.library")
}

val agpVersion: String = com.android.Version.ANDROID_GRADLE_PLUGIN_VERSION
if (agpVersion.split(".")[0].toInt() < 9) {
    apply(plugin = "kotlin-android")
}

android {
    namespace = "io.scer.pdf_renderer"
    compileSdk = 35

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 16
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.8.1")
}
