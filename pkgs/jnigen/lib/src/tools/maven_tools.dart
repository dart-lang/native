// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart';

import '../logging/logging.dart';

/// This class provides some utility methods to download a sources / jars
/// using maven along with transitive dependencies.
class MavenTools {
  static final currentDir = Directory(".");

  /// Helper method since we can't pass inheritStdio option to [Process.run].
  static Future<int> _runCmd(String exec, List<String> args,
      [String? workingDirectory]) async {
    log.info('execute $exec ${args.join(" ")}');
    final proc = await Process.start(exec, args,
        workingDirectory: workingDirectory,
        runInShell: true,
        mode: ProcessStartMode.inheritStdio);
    return proc.exitCode;
  }

  static Future<void> _runMavenCommand(
    List<MavenDependency> deps,
    List<String> mvnArgs,
    Directory tempDir,
  ) async {
    final pom = _getStubPom(deps);
    final tempPom = join(tempDir.path, "temp_pom.xml");
    final tempTarget = join(tempDir.path, "target");
    log.finer('using POM stub:\n$pom');
    await File(tempPom).writeAsString(pom);
    await Directory(tempTarget).create();
    await _runCmd('mvn', ['-q', '-f', tempPom, ...mvnArgs]);
    await File(tempPom).delete();
    await Directory(tempTarget).delete(recursive: true);
  }

  /// Create a list of [MavenDependency] objects from maven coordinates in string form.
  static List<MavenDependency> deps(List<String> depNames) =>
      depNames.map(MavenDependency.fromString).toList();

  /// Downloads and unpacks source files of [deps] into [targetDir].
  static Future<void> downloadMavenSources(
      List<MavenDependency> deps, String targetDir) async {
    final tempDir = await currentDir.createTemp("maven_temp_");
    await _runMavenCommand(
      deps,
      [
        'dependency:unpack-dependencies',
        '-DexcludeTransitive=true',
        '-DoutputDirectory=../$targetDir',
        '-Dclassifier=sources',
      ],
      tempDir,
    );
    await tempDir.delete(recursive: true);
  }

  /// Downloads JAR files of all [deps] transitively into [targetDir].
  static Future<void> downloadMavenJars(
      List<MavenDependency> deps, String targetDir) async {
    final tempDir = await currentDir.createTemp("maven_temp_");
    await _runMavenCommand(
      deps,
      [
        'dependency:copy-dependencies',
        '-DoutputDirectory=../$targetDir',
      ],
      tempDir,
    );
    await tempDir.delete(recursive: true);
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
    <repositories>
      <repository>
        <id>google-maven-repo</id>
        <name>Google Maven Repository</name>
        <url>https://maven.google.com</url>
      </repository>
    </repositories>
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
      <directory>\${project.basedir}/target</directory>
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
