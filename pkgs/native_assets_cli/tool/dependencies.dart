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

const publishedDependency = 'published-dependency';

const commands = [publishedDependency];

// Print all command-line arguments that are Dart files.
void main(List<String> arguments) async {
  final command = arguments.firstOrNull;
  switch (command) {
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

/// Switches the pubspecs to to published dependency for a specific package.
///
/// Does not remove `publish_to: none`.
///
/// Does not modify changelog or version in pubspec.
Future<void> switchAllToPublishedDependency(
  String packageName,
  String newVersion,
) async {
  await Future.wait(
    allPubspecs.map(
      (e) => switchToPublishedDependency2(e, packageName, newVersion),
    ),
  );
  print('Switched $packageName to published dependency on $newVersion.');
  print('Did not remove `publish_to: none`.');
  print('Did not modify changelog or version in pubspec.');
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
  final regex = RegExp('''  (# )?$packageName: \\^([0-9.]+)(-wip)?
  (# )?$packageName:
  (# )?  path: ([./]*)$packageName/''');
  final match = regex.firstMatch(pubspec);
  if (match == null) {
    return pubspec;
  }

  final replacement = '  $packageName: ^$newVersion';
  return pubspec.replaceFirst(match.group(0)!, replacement);
}

final pkgsUri = Platform.script.resolve('../../');

List<File> allPubspecs = [
  for (final package in packages)
    ...Glob(
      '${pkgsUri.resolve('$package/').toFilePath()}**pubspec.yaml',
    ).listSync().whereType<File>(),
];
