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

// Print all command-line arguments that are Dart files.
void main(List<String> arguments) async {
  if (arguments.length == 1 && arguments.single == pathDependencies) {
    await switchAllToPathDependencies();
  } else {
    print('The only command available is "$pathDependencies".');
  }
}

/// Switches the pubspecs to path dependencies.
///
/// Does not add `publish_to: none` back in.
///
/// Does not bump the version number and add `-wip`.
Future<void> switchAllToPathDependencies() async {
  await Future.wait(allPubspecs.map(switchToPathDependencies2));
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

final pkgsUri = Platform.script.resolve('../../');

List<File> allPubspecs = [
  for (final package in packages)
    ...Glob('${pkgsUri.resolve('$package/').toFilePath()}**pubspec.yaml')
        .listSync()
        .whereType<File>()
];
