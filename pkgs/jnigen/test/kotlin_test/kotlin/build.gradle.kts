plugins {
    kotlin("jvm") version "1.7.10"
    id("io.ktor.plugin") version "3.0.3"
}

repositories {
    mavenCentral()
    google()
}

dependencies {
    // include jni.jar from root .dart_tool as a dependency
    implementation(files("../../../.dart_tool/jni/jni.jar"))
    implementation(libs.org.jetbrains.kotlinx.kotlinx.coroutines.core)
    implementation(libs.org.jetbrains.kotlin.kotlin.stdlib.jdk8)
    testImplementation(libs.org.jetbrains.kotlin.kotlin.test.junit5)
    testImplementation(libs.org.junit.jupiter.junit.jupiter.engine)
}

group = "com.github.dart_lang.jnigen"
version = ""
description = "consoleApp"

application {
    mainClass.set("com.github.dart_lang.jnigen.SuspendFun")
}

java {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}

ktor {
    fatJar {
        archiveFileName.set("kotlin_test-all.jar")
    }
}