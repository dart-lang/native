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
      '`flutter build` output, it is likely that `jnigen` left some stubs in '
      'the build.gradle file. Please restore that file from your version '
      'control system or manually remove the stub functions named '
      '$_gradleGetClasspathTaskName and / or $_gradleGetSourcesTaskName.';

  static Future<String?> getAndroidJarPath(
          {required String sdkRoot, required List<int> versionOrder}) async =>
      await _getFile(sdkRoot, 'platforms', versionOrder, 'android.jar');

  static const _gradleGetClasspathTaskName = 'getReleaseCompileClasspath';

  static const _gradleGetClasspathStub = '''
// Gradle stub for listing dependencies in jnigen. If found in
// android/build.gradle, please delete the following function.
task $_gradleGetClasspathTaskName(type: Copy) {
  project.afterEvaluate {
    try {
      def app = project(':app')
      def android = app.android
      def cp = [android.getBootClasspath()[0]]
      android.applicationVariants.each { variant ->
        if (variant.name.equals('release')) {
          cp += variant.javaCompile.classpath.getFiles()
        }
      }
      cp.each { println it }
    } catch (Exception e) {
      System.err.println("$_gradleCannotFindJars")
      System.err.println("$_leftOverStubWarning")
      throw e
    }
  }
}
''';

  static const _gradleGetSourcesTaskName = 'getSources';
  // adapted from https://stackoverflow.com/questions/39975780/how-can-i-use-gradle-to-download-dependencies-and-their-source-files-and-place-t/39981143#39981143
  // Although it appears we can use this same code for getting JAR artifacts,
  // there is no JAR equivalent for `org.gradle.language.base.Artifact`.
  // So it appears different methods should be used for JAR artifacts.
  static const _gradleGetSourcesStub = '''
// Gradle stub for fetching source dependencies in jnigen. If found in
// android/build.gradle, please delete the following function.
task $_gradleGetSourcesTaskName(type: Copy) {
  project.afterEvaluate {
    def componentIds = project(':app').configurations.releaseCompileClasspath.incoming
      .resolutionResult.allDependencies.collect { it.selected.id }

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
    sourceArtifacts.forEach { println it }
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
        stubName: _gradleGetClasspathTaskName,
        stubCode: _gradleGetClasspathStub,
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
      stubName: _gradleGetSourcesTaskName,
      stubCode: _gradleGetSourcesStub,
      androidProject: androidProject,
      configRoot: configRoot,
    );
  }

  static String _appendStub(String script, String stub) {
    return script.contains(stub) ? script : script + stub;
  }

  // Attempts to locate a gradlew executable
  // First looking in immediate working director
  // Then android project subdirectory
  // And finally in local jnigen directory (for now)
  // When merged, gradlew will be in pub-cache
  // and use that as fallback lookup
  static File? locateGradleW() {
    final gradleCommandToLocate =
        Platform.isWindows ? 'gradlew.bat' : 'gradlew';
    if (File(gradleCommandToLocate).existsSync()) {
      return File(gradleCommandToLocate);
    }
    // Look in android directory
    final androidDirGradleWrapper =
        File(join(Directory.current.path, 'android', gradleCommandToLocate));
    if (androidDirGradleWrapper.existsSync()) {
      return androidDirGradleWrapper;
    }
    // TODO replace with pub-cache lookup after merge
    if (Directory.current.path.contains('jnigen')) {
      final parts = Directory.current.path.split(Platform.pathSeparator);
      final jnigenLocation = parts.indexOf('jnigen');
      final buffer = StringBuffer();
      for (var i = 0; i <= jnigenLocation; i++) {
        buffer.write(parts[i] + Platform.pathSeparator);
      }
      log.info(buffer);
      final jniGradle = File(join(buffer.toString(), gradleCommandToLocate));
      if (jniGradle.existsSync()) {
        return jniGradle;
      }
    }
    return null;
  }

  static List<String> _runGradleStub({
    required String stubName,
    required String stubCode,
    Uri? configRoot,
    String androidProject = '.',
  }) {
    log.info('trying to obtain gradle dependencies [$stubName]...');
    if (configRoot != null) {
      androidProject = configRoot.resolve(androidProject).toFilePath();
    }
    final android = join(androidProject, 'android');
    final buildGradle = join(android, 'build.gradle');
    final buildGradleOld = join(android, 'build.gradle.old');
    final origBuild = File(buildGradle);
    final script = origBuild.readAsStringSync();
    origBuild.renameSync(buildGradleOld);
    origBuild.createSync();
    log.finer('Writing temporary gradle script with stub "$stubName"...');
    origBuild.writeAsStringSync(_appendStub(script, stubCode));
    log.finer('Running gradle wrapper...');
    log.info('Current dir: ${Directory.current.path}');
    final gradleCommand = locateGradleW();
    log.info(gradleCommand);
    ProcessResult procRes;
    try {
      if (gradleCommand == null) {
        throw GradleException('''\n\nGradle execution failed.
        
Could not locate gradlew(.bat)
''');
      }

      procRes = Process.runSync(gradleCommand.path, ['-q', stubName],
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

1. The most likely cause is that the Android build is not yet cached.

Run `flutter build apk`$inAndroidProject and try again.

2. If the Gradle output includes text like this:

* What went wrong:
Execution failed for task ':gradle:compileGroovy'.
> BUG! exception in phase 'semantic analysis' ...  Unsupported class file major version

Then the JDK versions used by jnigen and flutter are not compatible. Try
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
    return paths;
  }
}
