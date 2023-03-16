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
  SdkNotFoundException(String message) : super(message);
}

class GradleException extends _AndroidToolsException {
  GradleException(String message) : super(message);
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

  static Future<String?> getAndroidJarPath(
          {required String sdkRoot, required List<int> versionOrder}) async =>
      await _getFile(sdkRoot, 'platforms', versionOrder, 'android.jar');

  static const _gradleListDepsFunction = '''
task listDependencies(type: Copy) {
  project.afterEvaluate {
  	def app = project(':app')
	def android = app.android
	def cp = [android.getBootClasspath()[0]]
	android.applicationVariants.each { variant ->
		if (variant.name.equals('release')) {
			cp += variant.javaCompile.classpath.getFiles()
		}
	}
 	cp.each { println it }
  }
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
      {Uri? configRoot, String androidProject = '.'}) {
    log.info('trying to obtain gradle classpaths...');
    if (configRoot != null) {
      androidProject = join(configRoot.toFilePath(), androidProject);
    }
    final android = join(androidProject, 'android');
    final buildGradle = join(android, 'build.gradle');
    final buildGradleOld = join(android, 'build.gradle.old');
    final origBuild = File(buildGradle);
    final script = origBuild.readAsStringSync();
    origBuild.renameSync(buildGradleOld);
    origBuild.createSync();
    log.finer('Writing temporary gradle script with stub function...');
    origBuild.writeAsStringSync('$script\n$_gradleListDepsFunction\n');
    log.finer('Running gradle wrapper...');
    final gradleCommand = Platform.isWindows ? '.\\gradlew.bat' : './gradlew';
    ProcessResult procRes;
    try {
      procRes = Process.runSync(gradleCommand, ['-q', 'listDependencies'],
          workingDirectory: android, runInShell: true);
    } finally {
      log.finer('Restoring build scripts');
      origBuild.writeAsStringSync(script);
      File(buildGradleOld).deleteSync();
    }
    if (procRes.exitCode != 0) {
      final inAndroidProject =
          (androidProject == '.') ? '' : ' in $androidProject';
      throw GradleException('\n\ngradle exited with exit code '
          '${procRes.exitCode}\n. This can be related to a known issue with '
          'gradle. Please run `flutter build apk`$inAndroidProject and try '
          'again\n');
    }
    final classpaths = (procRes.stdout as String)
        .trim()
        .split(Platform.isWindows ? '\r\n' : '\n');
    log.info('Found release build classpath with ${classpaths.length} entries');
    return classpaths;
  }
}
