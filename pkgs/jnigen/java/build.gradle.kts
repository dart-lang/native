plugins {
    java
    application
    id("io.ktor.plugin") version "3.0.3"
}

repositories {
    mavenLocal()
    maven {
        url = uri("https://repo.maven.apache.org/maven2/")
    }
}

dependencies {
    implementation(libs.com.fasterxml.jackson.core.jackson.databind)
    implementation(libs.commons.cli.commons.cli)
    implementation(libs.org.ow2.asm.asm.tree)
    implementation(libs.org.jetbrains.kotlinx.kotlinx.metadata.jvm)
    testImplementation(libs.junit.junit)
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

/*publishing {
    publications.create<MavenPublication>("maven") {
        from(components["java"])
    }
}*/

tasks.withType<JavaCompile>() {
    options.encoding = "UTF-8"
}

tasks.withType<Javadoc>() {
    options.encoding = "UTF-8"
}
