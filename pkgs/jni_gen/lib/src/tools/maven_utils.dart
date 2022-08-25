// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// This class provides some utility methods to download a sources / jars
/// using maven along with transitive dependencies.
class MvnTools {
  static const _tempPom = '__temp_pom.xml';
  static const _tempClassPath = '__temp_classpath.xml';
  static const _tempTarget = '__mvn_target';

  static bool _verbose = false;
  static void setVerbose(bool enabled) => _verbose = enabled;

  static void _verboseLog(Object? value) {
    if (_verbose) {
      stderr.writeln(value);
    }
  }

  /// Helper method since we can't pass inheritStdio option to [Process.run].
  static Future<int> _runCmd(String exec, List<String> args,
      [String? workingDirectory]) async {
    _verboseLog('[exec] $exec ${args.join(" ")}');
    final proc = await Process.start(exec, args,
        workingDirectory: workingDirectory,
        mode: ProcessStartMode.inheritStdio);
    return proc.exitCode;
  }

  static Future<void> _runMavenCommand(
      List<MvnDep> deps, List<String> mvnArgs) async {
    final pom = _getStubPom(deps);
    _verboseLog('using POM stub:\n$pom');
    await File(_tempPom).writeAsString(pom);
    await Directory(_tempTarget).create();
    await _runCmd(
        'mvn', ['-f', _tempPom, '-DbuildDirectory=$_tempTarget', ...mvnArgs]);
    await File(_tempPom).delete();
    await Directory(_tempTarget).delete(recursive: true);
  }

  /// Create a list of [MvnDep] objects from maven coordinates in string form.
  static List<MvnDep> makeDependencyList(List<String> depNames) =>
      depNames.map(MvnDep.fromString).toList();

  /// Downloads and unpacks source files of [deps] into [targetDir].
  static Future<void> downloadMavenSources(
      List<MvnDep> deps, String targetDir) async {
    await _runMavenCommand(deps, [
      'dependency:unpack-dependencies',
      '-DoutputDirectory=$targetDir',
      '-Dclassifier=sources'
    ]);
  }

  /// Downloads JAR files of all [deps] transitively into [targetDir].
  static Future<void> downloadMavenJars(
      List<MvnDep> deps, String targetDir) async {
    await _runMavenCommand(deps, [
      'dependency:copy-dependencies',
      '-DoutputDirectory=$targetDir',
    ]);
  }

  /// Get classpath string using JARs in maven's local repository.
  static Future<String> getMavenClassPath(List<MvnDep> deps) async {
    await _runMavenCommand(deps, [
      'dependency:build-classpath',
      '-Dmdep.outputFile=$_tempClassPath',
    ]);
    final classPathFile = File(_tempClassPath);
    final classpath = await classPathFile.readAsString();
    await classPathFile.delete();
    return classpath;
  }

  static String _getStubPom(List<MvnDep> deps, {String javaVersion = '11'}) {
    final i2 = ' ' * 2;
    final i4 = ' ' * 4;
    final i6 = ' ' * 6;
    final i8 = ' ' * 8;
    final depDecls = <String>[];

    for (var dep in deps) {
      final otherTags = StringBuffer();
      for (var entry in dep.otherTags.entries) {
        otherTags.write('$i6<${entry.key}>\n'
            '$i8${entry.value}\n'
            '$i6</${entry.key}>\n');
      }
      depDecls.add('$i4<dependency>\n'
          '$i6<groupId>${dep.groupID}</groupId>\n'
          '$i6<artifactId>${dep.artifactID}</artifactId>\n'
          '$i6<version>${dep.version}</version>\n'
          '${otherTags.toString()}\n'
          '$i4</dependency>\n');
    }

    return '<project xmlns="http://maven.apache.org/POM/4.0.0" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n'
        'xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 '
        'http://maven.apache.org/xsd/maven-4.0.0.xsd">\n'
        '$i2<modelVersion>4.0.0</modelVersion>\n'
        '$i2<groupId>com.mycompany.app</groupId>\n'
        '$i2<artifactId>my-app</artifactId>\n'
        '$i2<version>1.0-SNAPSHOT</version>\n'
        '$i2<properties>\n'
        '$i4<maven.compiler.source>$javaVersion</maven.compiler.source>\n'
        '$i4<maven.compiler.target>$javaVersion</maven.compiler.target>\n'
        '$i2</properties>\n'
        '$i4<dependencies>\n'
        '${depDecls.join("\n")}'
        '$i2</dependencies>\n'
        '</project>';
  }
}

/// Maven dependency with group ID, artifact ID, and version.
class MvnDep {
  MvnDep(this.groupID, this.artifactID, this.version,
      {this.otherTags = const {}});
  factory MvnDep.fromString(String fullName) {
    final components = fullName.split(':');
    if (components.length != 3) {
      throw ArgumentError('invalid name for maven dependency: $fullName');
    }
    return MvnDep(components[0], components[1], components[2]);
  }
  String groupID, artifactID, version;
  Map<String, String> otherTags;
}
