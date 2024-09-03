// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

/// Ordered by dependencies.
const packages = [
  'native_assets_cli',
  'native_toolchain_c',
  'native_assets_builder',
];

const pathDependencies = 'path-dependencies';

const publishedDependency = 'published-dependency';

const commands = [
  pathDependencies,
  publishedDependency,
];

// Print all command-line arguments that are Dart files.
void main(List<String> arguments) async {
  final command = arguments.firstOrNull;
  switch (command) {
    case pathDependencies:
      return await switchAllToPathDependencies();
    case publishedDependency:
      if (arguments.length != 3) {
        print('Usage: $publishedDependency <package-name> <new-version>');
        return;
      }
      final packageName = arguments[1];
      if (!packages.contains(packageName)) {
        print('Wrong package name.');
        return;
      }
      final newVersion = arguments[2];
      await switchAllToPublishedDependency(packageName, newVersion);
    default:
      print('The commands available are:');
      for (final command in commands) {
        print(' - $command');
      }
  }
}

/// Switches the pubspecs to path dependencies.
///
/// Does not add `publish_to: none` back in.
///
/// Does not bump the version number and add `-wip`.
Future<void> switchAllToPathDependencies() async {
  await Future.wait(allPubspecs.map(switchToPathDependencies2));
  print('Did not add `publish_to: none` back in.');
  print('Did not bump the version number and add `-wip`.');
}

Future<void> switchToPathDependencies2(File pubspecFile) async {
  final newPubspec = switchToPathDependencies(await pubspecFile.readAsString());
  await pubspecFile.writeAsString(newPubspec);
}

String switchToPathDependencies(String pubspec) {
  for (final packageName in packages) {
    pubspec = switchToPathDependency(pubspec, packageName);
  }
  return pubspec;
}

String switchToPathDependency(String pubspec, String packageName) {
  final regex = RegExp('''  $packageName: \\^([0-9.]+)
  # $packageName:
  #   path: ([./]*)$packageName/''');
  final match = regex.firstMatch(pubspec);
  if (match == null) {
    return pubspec;
  }

  final replacement = '''  # $packageName: ^${match.group(1)}
  $packageName:
    path: ${match.group(2)}$packageName/''';
  return pubspec.replaceFirst(match.group(0)!, replacement);
}

Future<void> switchAllToPublishedDependency(
  String packageName,
  String newVersion,
) async {
  await Future.wait(allPubspecs.map((e) => switchToPublishedDependency2(
        e,
        packageName,
        newVersion,
      )));
}

Future<void> switchToPublishedDependency2(
  File pubspecFile,
  String packageName,
  String newVersion,
) async {
  final newPubspec = switchToPublishedDependency(
    await pubspecFile.readAsString(),
    packageName,
    newVersion,
  );
  await pubspecFile.writeAsString(newPubspec);
}

String switchToPublishedDependency(
  String pubspec,
  String packageName,
  String newVersion,
) {
  final regex = RegExp('''  (# )?$packageName: \\^([0-9.]+)
  (# )?$packageName:
  (# )?  path: ([./]*)$packageName/''');
  final match = regex.firstMatch(pubspec);
  if (match == null) {
    return pubspec;
  }

  final replacement = '''  $packageName: ^$newVersion
  # $packageName:
  #   path: ${match.group(5)}$packageName/''';
  return pubspec.replaceFirst(match.group(0)!, replacement);
}

final pkgsUri = Platform.script.resolve('../../');

List<File> allPubspecs = [
  for (final package in packages)
    ...Glob('${pkgsUri.resolve('$package/').toFilePath()}**pubspec.yaml')
        .listSync()
        .whereType<File>()
];
