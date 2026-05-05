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
      into("/usr/local/google/home/liama/dev/native3/pkgs/jnigen/test/jackson_core_test/third_party/java")
    }

    tasks.register<Copy>("extractSourceJars") {
      duplicatesStrategy = DuplicatesStrategy.INCLUDE
      val sourcesDir = fileTree("/usr/local/google/home/liama/dev/native3/pkgs/jnigen/test/jackson_core_test/third_party/java")
      sourcesDir.forEach {
        if (it.name.endsWith(".jar")) {
          from(zipTree(it))
          into("/usr/local/google/home/liama/dev/native3/pkgs/jnigen/test/jackson_core_test/third_party/java")
        }
      }      
      from(configurations.runtimeClasspath)
      into("/usr/local/google/home/liama/dev/native3/pkgs/jnigen/test/jackson_core_test/third_party/java")
    }
    
    tasks.register<de.undercouch.gradle.tasks.download.Download>("downloadSources") {
      src(listOf(
          "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.13.4/jackson-core-2.13.4-sources.jar"
      ))
      dest("/usr/local/google/home/liama/dev/native3/pkgs/jnigen/test/jackson_core_test/third_party/java")
      overwrite(true)
    }
    
    dependencies {
        implementation("com.fasterxml.jackson.core:jackson-core:2.13.4")
    }