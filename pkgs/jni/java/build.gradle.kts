plugins {
    java
    application
}

repositories {
    mavenCentral()
    google()
}

dependencies {
    implementation(libs.org.jetbrains.kotlin.kotlin.stdlib)
    implementation(libs.org.jetbrains.kotlinx.kotlinx.coroutines.core)
}

group = "com.github.dart_lang"
description = "jni"

java {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}

tasks.withType<Jar> {
    val targetDir: String? = project.findProperty("jni.targetDir") as String?
    if (targetDir != null) {
        destinationDirectory = file(targetDir)
    } else {
        destinationDirectory = file("build/jni_libs")
    }
}

tasks.withType<JavaCompile>() {
    options.encoding = "UTF-8"
}

tasks.withType<Javadoc>() {
    options.encoding = "UTF-8"
}
