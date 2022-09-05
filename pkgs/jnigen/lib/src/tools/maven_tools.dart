// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// This class provides some utility methods to download a sources / jars
/// using maven along with transitive dependencies.
class MavenTools {
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
      List<MavenDependency> deps, List<String> mvnArgs) async {
    final pom = _getStubPom(deps);
    _verboseLog('using POM stub:\n$pom');
    await File(_tempPom).writeAsString(pom);
    await Directory(_tempTarget).create();
    await _runCmd('mvn', ['-f', _tempPom, ...mvnArgs]);
    await File(_tempPom).delete();
    await Directory(_tempTarget).delete(recursive: true);
  }

  /// Create a list of [MavenDependency] objects from maven coordinates in string form.
  static List<MavenDependency> deps(List<String> depNames) =>
      depNames.map(MavenDependency.fromString).toList();

  /// Downloads and unpacks source files of [deps] into [targetDir].
  static Future<void> downloadMavenSources(
      List<MavenDependency> deps, String targetDir) async {
    await _runMavenCommand(deps, [
      'dependency:unpack-dependencies',
      '-DexcludeTransitive=true',
      '-DoutputDirectory=$targetDir',
      '-Dclassifier=sources',
    ]);
  }

  /// Downloads JAR files of all [deps] transitively into [targetDir].
  static Future<void> downloadMavenJars(
      List<MavenDependency> deps, String targetDir) async {
    await _runMavenCommand(deps, [
      'dependency:copy-dependencies',
      '-DoutputDirectory=$targetDir',
    ]);
  }

  /// Get classpath string using JARs in maven's local repository.
  static Future<String> getMavenClassPath(List<MavenDependency> deps) async {
    await _runMavenCommand(deps, [
      'dependency:build-classpath',
      '-Dmdep.outputFile=$_tempClassPath',
    ]);
    final classPathFile = File(_tempClassPath);
    final classpath = await classPathFile.readAsString();
    await classPathFile.delete();
    return classpath;
  }

  static String _getStubPom(List<MavenDependency> deps,
      {String javaVersion = '11'}) {
    final depDecls = <String>[];
    for (var dep in deps) {
      final otherTags = StringBuffer();
      for (var entry in dep.otherTags.entries) {
        otherTags.write('''
      <${entry.key}>
        ${entry.value}
      </${entry.key}>
      ''');
      }
      depDecls.add('''
      <dependency>
        <groupId>${dep.groupID}</groupId>
        <artifactId>${dep.artifactID}</artifactId>
        <version>${dep.version}</version>
        ${otherTags.toString()}
      </dependency>''');
    }

    return '''
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
  http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.mycompany.app</groupId>
    <artifactId>jnigen_maven_stub</artifactId>
    <version>1.0-SNAPSHOT</version>
    <properties>
      <maven.compiler.source>$javaVersion</maven.compiler.source>
      <maven.compiler.target>$javaVersion</maven.compiler.target>
    </properties>
    <dependencies>
${depDecls.join("\n")}
    </dependencies>
    <build>
      <directory>$_tempTarget</directory>
    </build>
</project>''';
  }
}

/// Maven dependency with group ID, artifact ID, and version.
class MavenDependency {
  MavenDependency(this.groupID, this.artifactID, this.version,
      {this.otherTags = const {}});
  factory MavenDependency.fromString(String fullName) {
    final components = fullName.split(':');
    if (components.length != 3) {
      throw ArgumentError('invalid name for maven dependency: $fullName');
    }
    return MavenDependency(components[0], components[1], components[2]);
  }
  String groupID, artifactID, version;
  Map<String, String> otherTags;
}
