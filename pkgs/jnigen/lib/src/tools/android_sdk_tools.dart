// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart';

import '../logging/logging.dart';

class _AndroidToolsException implements Exception {
  _AndroidToolsException(this.message);
  String message;
  @override
  String toString() => message;
}

class SdkNotFoundException extends _AndroidToolsException {
  SdkNotFoundException(super.message);
}

class GradleException extends _AndroidToolsException {
  GradleException(super.message);
}

class AndroidSdkTools {
  static String getAndroidSdkRoot() {
    final envVar = Platform.environment['ANDROID_SDK_ROOT'];
    if (envVar == null) {
      throw SdkNotFoundException('Android SDK not found. Please set '
          'ANDROID_SDK_ROOT environment variable or specify through command '
          'line override.');
    }
    return envVar;
  }

  static Future<String?> _getVersionDir(
      String relative, String sdkRoot, List<int> versionOrder) async {
    final parent = join(sdkRoot, relative);
    for (var version in versionOrder) {
      final dir = Directory(join(parent, 'android-$version'));
      if (await dir.exists()) {
        return dir.path;
      }
    }
    return null;
  }

  static Future<String?> _getFile(String sdkRoot, String relative,
      List<int> versionOrder, String file) async {
    final platform = await _getVersionDir(relative, sdkRoot, versionOrder);
    if (platform == null) return null;
    final filePath = join(platform, file);
    if (await File(filePath).exists()) {
      log.info('Found $filePath');
      return filePath;
    }
    return null;
  }

  static const _gradleCannotFindJars = 'Gradle stub cannot find JAR libraries. '
      'This might be because no APK build has happened yet.';

  static const _leftOverStubWarning = 'If you are seeing this error in '
      '`flutter build` output, it is likely that JNIgen left some stubs in '
      'the build.gradle file. Please restore that file from your version '
      'control system or manually remove the stub functions named '
      '$_gradleGetClasspathTaskName and / or $_gradleGetSourcesTaskName.';

  static Future<String?> getAndroidJarPath(
          {required String sdkRoot, required List<int> versionOrder}) async =>
      await _getFile(sdkRoot, 'platforms', versionOrder, 'android.jar');

  static const _gradleGetClasspathTaskName = 'getReleaseCompileClasspath';

  static const _gradleGetClasspathStub = '''
// Gradle stub for listing dependencies in JNIgen. If found in
// android/build.gradle, please delete the following task.
tasks.register("$_gradleGetClasspathTaskName") {
  allprojects { project ->
    if (project != rootProject) {
      evaluationDependsOn(project.path)
    }
  }
  allprojects { project ->
    project.configurations.all { config ->
      if (config.name == "releaseCompileClasspath") {
        try {
          def jarView = config.incoming.artifactView {
            attributes {
              attribute(org.gradle.api.attributes.Attribute.of("artifactType", String.class), "jar")
            }
            lenient = true
          }
          inputs.files(jarView.files)
          def aarView = config.incoming.artifactView {
            attributes {
              attribute(org.gradle.api.attributes.Attribute.of("artifactType", String.class), "android-classes-jar")
            }
            lenient = true
          }
          inputs.files(aarView.files)
        } catch (Exception e) {}
      }
    }
  }
  doLast {
    try {
      def cp = []

      def addConfig = { config ->
        if (config != null) {
          try {
            config.incoming.artifactView {
              attributes {
                attribute(org.gradle.api.attributes.Attribute.of("artifactType", String.class), "jar")
              }
              lenient = true
            }.files.each {
              cp << it.absolutePath
            }
            config.incoming.artifactView {
              attributes {
                attribute(org.gradle.api.attributes.Attribute.of("artifactType", String.class), "android-classes-jar")
              }
              lenient = true
            }.files.each {
              cp << it.absolutePath
            }
          } catch (Exception e) {}
        }
      }

      def mainProject = allprojects.find {
        it.plugins.hasPlugin("com.android.application")
      } ?: project

      // JNIgen
      // 1. Boot classpath (android.jar) FIRST, matching old stub logic.
      def android = mainProject.extensions.findByName("android")
      if (android != null && android.hasProperty("bootClasspath")) {
        android.bootClasspath.each {
          cp << it.absolutePath
        }
      }

      // 2. Main project classpath
      addConfig(mainProject.configurations.findByName("releaseCompileClasspath"))

      // 3. ONLY add other projects if main project doesn't have an application plugin.
      // Or if we are in a Flutter environment where subprojects might have extra deps.
      if (!mainProject.plugins.hasPlugin("com.android.application")) {
        (allprojects - mainProject).each { p ->
          addConfig(p.configurations.findByName("releaseCompileClasspath"))
        }
      }

      cp.unique().each {
        println it
      }
    } catch (Exception e) {
      System.err.println("$_gradleCannotFindJars")
      throw e
    }
  }
  System.err.println("$_leftOverStubWarning")
}
''';

  static const _gradleGetClasspathStubKt = '''
// Gradle stub for listing dependencies in JNIgen. If found in
// android/build.gradle.kts, please delete the following task.
tasks.register<DefaultTask>("$_gradleGetClasspathTaskName") {
  allprojects {
    if (this != rootProject) {
      evaluationDependsOn(path)
    }
  }
  allprojects {
    configurations.forEach { config ->
      if (config.name == "releaseCompileClasspath") {
        try {
          val jarView = config.incoming.artifactView {
            attributes {
              attribute(org.gradle.api.attributes.Attribute.of("artifactType", String::class.java), "jar")
            }
            lenient(true)
          }
          inputs.files(jarView.files)
          val aarView = config.incoming.artifactView {
            attributes {
              attribute(org.gradle.api.attributes.Attribute.of("artifactType", String::class.java), "android-classes-jar")
            }
            lenient(true)
          }
          inputs.files(aarView.files)
        } catch (e: Exception) {}
      }
    }
  }
  doLast {
    try {
      val cp = mutableListOf<String>()

      fun addConfig(config: org.gradle.api.artifacts.Configuration?) {
        if (config != null) {
          try {
            config.incoming.artifactView {
              attributes {
                attribute(org.gradle.api.attributes.Attribute.of("artifactType", String::class.java), "jar")
              }
              lenient(true)
            }.files.forEach {
              cp.add(it.absolutePath)
            }
            config.incoming.artifactView {
              attributes {
                attribute(org.gradle.api.attributes.Attribute.of("artifactType", String::class.java), "android-classes-jar")
              }
              lenient(true)
            }.files.forEach {
              cp.add(it.absolutePath)
            }
          } catch (e: Exception) {}
        }
      }

      val mainProject = allprojects.find {
        it.plugins.hasPlugin("com.android.application")
      } ?: project

      val android = mainProject.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
      android?.bootClasspath?.forEach {
        cp.add(it.absolutePath)
      }

      addConfig(mainProject.configurations.findByName("releaseCompileClasspath"))

      if (!mainProject.plugins.hasPlugin("com.android.application")) {
        allprojects.filter { it != mainProject }.forEach { p ->
          addConfig(p.configurations.findByName("releaseCompileClasspath"))
        }
      }

      cp.distinct().forEach { println(it) }
    } catch (e: Exception) {
      System.err.println("$_gradleCannotFindJars")
      throw e
    }
  }
  System.err.println("$_leftOverStubWarning")
}
''';

  static const _gradleGetSourcesTaskName = 'getSources';
  static const _gradleGetSourcesStub = '''
// Gradle stub for fetching source dependencies in JNIgen. If found in
// android/build.gradle, please delete the following task.
tasks.register("$_gradleGetSourcesTaskName") {
  allprojects { project ->
    if (project != rootProject) {
      evaluationDependsOn(project.path)
    }
  }
  allprojects { project ->
    project.configurations.all { config ->
      if (config.name == "releaseCompileClasspath") {
        try {
          def jarView = config.incoming.artifactView {
            attributes {
              attribute(org.gradle.api.attributes.Attribute.of("artifactType", String.class), "jar")
            }
            lenient = true
          }
          inputs.files(jarView.files)
        } catch (Exception e) {}
      }
    }
  }
  doLast {
    def mainProject = allprojects.find {
      it.plugins.hasPlugin("com.android.application")
    } ?: project
    def projects = [mainProject]
    if (!mainProject.plugins.hasPlugin("com.android.application")) {
      projects += (allprojects - mainProject)
    }
    projects.each { p ->
      def config = p.configurations.findByName("releaseCompileClasspath")
      if (config == null) return

      def componentIds = config.incoming.resolutionResult.allDependencies.collect {
        it.selected.id
      }

      ArtifactResolutionResult result = dependencies.createArtifactResolutionQuery()
        .forComponents(componentIds)
        .withArtifacts(JvmLibrary, SourcesArtifact)
        .execute()

      def sourceArtifacts = []

      result.resolvedComponents.each { ComponentArtifactsResult component ->
        Set<ArtifactResult> sources = component.getArtifacts(SourcesArtifact)
        sources.each { ArtifactResult ar ->
          if (ar instanceof ResolvedArtifactResult) {
            sourceArtifacts << ar.file
          }
        }
      }
      sourceArtifacts.forEach { println it.absolutePath }
    }
  }
  System.err.println("$_leftOverStubWarning")
}
''';

  static const _gradleGetSourcesStubKt = '''
// Gradle stub for fetching source dependencies in JNIgen. If found in
// android/build.gradle.kts, please delete the following task.
tasks.register<DefaultTask>("$_gradleGetSourcesTaskName") {
  allprojects {
    if (this != rootProject) {
      evaluationDependsOn(path)
    }
  }
  allprojects {
    configurations.forEach { config ->
      if (config.name == "releaseCompileClasspath") {
        try {
          val jarView = config.incoming.artifactView {
            attributes {
              attribute(org.gradle.api.attributes.Attribute.of("artifactType", String::class.java), "jar")
            }
            lenient(true)
          }
          inputs.files(jarView.files)
        } catch (e: Exception) {}
      }
    }
  }
  doLast {
    val mainProject = allprojects.find {
      it.plugins.hasPlugin("com.android.application")
    } ?: project
    val projects = mutableListOf(mainProject)
    if (!mainProject.plugins.hasPlugin("com.android.application")) {
      projects.addAll(allprojects.filter { it != mainProject })
    }

    projects.forEach { p ->
      val config = p.configurations.findByName("releaseCompileClasspath")
      if (config == null) return@forEach

      val componentIds =
        config.incoming.resolutionResult.allDependencies
          .filterIsInstance<org.gradle.api.artifacts.result.ResolvedDependencyResult>()
          .map { it.selected.id }

      val result = dependencies.createArtifactResolutionQuery()
        .forComponents(componentIds)
        .withArtifacts(org.gradle.api.artifacts.result.JvmLibrary::class, org.gradle.api.artifacts.result.SourcesArtifact::class)
        .execute()

      val sourceArtifacts = mutableListOf<File>()

      for (component in result.resolvedComponents) {
        val sourcesArtifactsResult = component.getArtifacts(org.gradle.api.artifacts.result.SourcesArtifact::class)
        for (artifactResult in sourcesArtifactsResult) {
          if (artifactResult is org.gradle.api.artifacts.result.ResolvedArtifactResult) {
            sourceArtifacts.add(artifactResult.file)
          }
        }
      }
      for (sourceArtifact in sourceArtifacts) {
        println(sourceArtifact.absolutePath)
      }
    }
  }
  System.err.println("$_leftOverStubWarning")
}
''';

  /// Get release compile classpath used by Gradle for android build.
  ///
  /// This function temporarily overwrites the build.gradle file by a stub with
  /// function to list all dependency paths for release variant.
  /// This function fails if no gradle build is attempted before.
  ///
  /// If current project is not directly buildable by gradle, eg: a plugin,
  /// a relative path to other project can be specified using [androidProject].
  static List<String> getGradleClasspaths(
          {Uri? configRoot, String androidProject = '.'}) =>
      _runGradleStub(
        isSource: false,
        androidProject: androidProject,
        configRoot: configRoot,
      );

  /// Get source paths for all gradle dependencies.
  ///
  /// This function temporarily overwrites the build.gradle file by a stub with
  /// function to list all dependency paths for release variant.
  /// This function fails if no gradle build is attempted before.
  static List<String> getGradleSources(
      {Uri? configRoot, String androidProject = '.'}) {
    return _runGradleStub(
      isSource: true,
      androidProject: androidProject,
      configRoot: configRoot,
    );
  }

  static String _appendStub(String script, String stub) {
    return script.contains(stub) ? script : script + stub;
  }

  static List<String> _runGradleStub({
    required bool isSource,
    Uri? configRoot,
    String androidProject = '.',
  }) {
    final stubName =
        isSource ? _gradleGetSourcesTaskName : _gradleGetClasspathTaskName;
    log.info('trying to obtain gradle dependencies [$stubName]...');
    if (configRoot != null) {
      androidProject = configRoot.resolve(androidProject).toFilePath();
    }
    final android = join(androidProject, 'android');
    var buildGradle = join(android, 'build.gradle');
    final usesKotlinScript = !File.fromUri(Uri.file(buildGradle)).existsSync();
    if (usesKotlinScript) {
      // The Kotlin version of the script is injected to `app/build.gradle.kts`
      // instead of `build.gradle`.
      buildGradle = join(android, 'app', 'build.gradle.kts');
    }
    final String stubCode;
    if (isSource) {
      stubCode =
          usesKotlinScript ? _gradleGetSourcesStubKt : _gradleGetSourcesStub;
    } else {
      stubCode = usesKotlinScript
          ? _gradleGetClasspathStubKt
          : _gradleGetClasspathStub;
    }
    final buildGradleOld = '$buildGradle.old';
    final origBuild = File(buildGradle);
    final script = origBuild.readAsStringSync();
    origBuild.renameSync(buildGradleOld);
    origBuild.createSync();
    log.finer('Writing temporary gradle script with stub "$stubName"...');
    origBuild.writeAsStringSync(_appendStub(script, stubCode));
    log.finer('Running gradle wrapper...');
    final gradleCommand = Platform.isWindows ? '.\\gradlew.bat' : './gradlew';
    final taskPath = usesKotlinScript ? ':app:$stubName' : stubName;
    ProcessResult procRes;
    try {
      procRes = Process.runSync(gradleCommand, ['-q', taskPath],
          workingDirectory: android, runInShell: true);
    } finally {
      log.info('Restoring build scripts');
      origBuild.writeAsStringSync(
        script
            .replaceAll(_gradleGetClasspathStub, '')
            .replaceAll(_gradleGetSourcesStub, ''),
      );
      File(buildGradleOld).deleteSync();
    }
    if (procRes.exitCode != 0) {
      final inAndroidProject =
          (androidProject == '') ? '' : ' in $androidProject';
      throw GradleException('''\n\nGradle execution failed.

1. The most likely cause is that the Flutter metadata files are not yet cached.

Run `flutter pub get`$inAndroidProject and try again.

2. If the Gradle output says "./gradlew: not found", the Flutter Gradle wrapper
  script is missing.

Run `flutter build apk`$inAndroidProject and try again.

This is commonly seen in a fresh clone of a git repo. You can also consider
adjusting your .gitignore rules to check these files in to your git repo.

3. If the Gradle output includes text like this:

* What went wrong:
Execution failed for task ':gradle:compileGroovy'.
> BUG! exception in phase 'semantic analysis' ...  Unsupported class file major version

Then the JDK versions used by JNIgen and Flutter are not compatible. Try
changing the default JDK version e.g. with `export JAVA_VERSION=11` on macOS and
`sudo update-alternatives --config java` on Ubuntu.

GRADLE OUTPUT:
--------------------------------------------------------------------------------

${procRes.stderr}

--------------------------------------------------------------------------------
''');
    }
    // Record both stdout and stderr of gradle.
    log.writeSectionToFile('Gradle logs ($stubName)', procRes.stderr);
    log.writeSectionToFile('Gradle output ($stubName)', procRes.stdout);
    final output = procRes.stdout as String;
    if (output.isEmpty) {
      printError(procRes.stderr);
      throw Exception('Gradle stub exited without output.');
    }
    final paths = (procRes.stdout as String)
        .trim()
        .split(Platform.isWindows ? '\r\n' : '\n');
    log.fine('Found ${paths.length} entries');
    print("\n\nZCXVZXCVZXCV\n" + paths.join('\n') + "\n\n\n");
    return paths;
  }
}
