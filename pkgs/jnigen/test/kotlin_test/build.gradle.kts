plugins {
    kotlin("jvm") version "1.7.10"
}

repositories {
    mavenCentral()
    google()
}

dependencies {
    implementation(libs.org.jetbrains.kotlinx.kotlinx.coroutines.core)
    implementation(libs.org.jetbrains.kotlin.kotlin.stdlib.jdk8)
    testImplementation(libs.org.jetbrains.kotlin.kotlin.test.junit5)
    testImplementation(libs.org.junit.jupiter.junit.jupiter.engine)
}

group = "com.github.dart_lang.jnigen"
version = ""
description = "consoleApp"

java.sourceCompatibility = JavaVersion.VERSION_11

