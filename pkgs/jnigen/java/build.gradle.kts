plugins {
    java
    application
    id("io.ktor.plugin") version "3.0.3"
}

repositories {
    mavenCentral()
    google()
}

dependencies {
    implementation("com.fasterxml.jackson.core:jackson-databind:2.17.0")
    implementation("commons-cli:commons-cli:1.5.0")
    implementation("org.ow2.asm:asm-tree:9.7")
    implementation("org.jetbrains.kotlinx:kotlinx-metadata-jvm:0.9.0")
    implementation(kotlin("stdlib-jdk8"))
    testImplementation("junit:junit:4.13.2")
}

group = "com.github.dart_lang.jnigen"
// Make it so the outer script doesn't have to track the version number
//version = "0.0.1-SNAPSHOT"
description = "ApiSummarizer"

java {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}
application {
    mainClass.set("com.github.dart_lang.jnigen.apisummarizer.Main")
}

ktor {
    fatJar {
        // default for fatjars is ____-all.jar
        archiveFileName.set("ApiSummarizer.jar")
    }
}

tasks.withType<JavaCompile>() {
    options.encoding = "UTF-8"
}

tasks.withType<Javadoc>() {
    options.encoding = "UTF-8"
}
