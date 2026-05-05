    plugins {
        java
        id("de.undercouch.download") version "5.7.0"
    }
    
    repositories {
        mavenCentral()
        google()
    }
    
    java {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    
    tasks.register<Copy>("copyJars") {
      from(configurations.runtimeClasspath)
      into("/usr/local/google/home/liama/dev/native3/pkgs/jnigen/example/pdfbox_plugin/mvn_jar")
    }

    tasks.register<Copy>("extractSourceJars") {
      duplicatesStrategy = DuplicatesStrategy.INCLUDE
      val sourcesDir = fileTree("/usr/local/google/home/liama/dev/native3/pkgs/jnigen/example/pdfbox_plugin/mvn_jar")
      sourcesDir.forEach {
        if (it.name.endsWith(".jar")) {
          from(zipTree(it))
          into("/usr/local/google/home/liama/dev/native3/pkgs/jnigen/example/pdfbox_plugin/mvn_jar")
        }
      }      
      from(configurations.runtimeClasspath)
      into("/usr/local/google/home/liama/dev/native3/pkgs/jnigen/example/pdfbox_plugin/mvn_jar")
    }
    
    tasks.register<de.undercouch.gradle.tasks.download.Download>("downloadSources") {
      src(listOf(
          "https://repo1.maven.org/maven2/org/apache/pdfbox/pdfbox/2.0.26/pdfbox-2.0.26-sources.jar","https://repo1.maven.org/maven2/org/bouncycastle/bcmail-jdk15on/1.70/bcmail-jdk15on-1.70-sources.jar","https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk15on/1.70/bcprov-jdk15on-1.70-sources.jar"
      ))
      dest("/usr/local/google/home/liama/dev/native3/pkgs/jnigen/example/pdfbox_plugin/mvn_jar")
      overwrite(true)
    }
    
    dependencies {
        implementation("org.apache.pdfbox:pdfbox:2.0.26")
    implementation("org.bouncycastle:bcmail-jdk15on:1.70")
    implementation("org.bouncycastle:bcprov-jdk15on:1.70")
    }