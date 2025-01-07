// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

void main() {
  const packages = [
    'native_assets_cli',
    'native_assets_builder',
    'native_toolchain_c',
  ];
  final pkgsDir = Platform.script.resolve('../../');
  final skipFiles = [
    Platform.script,
    pkgsDir.resolve(
        'native_assets_builder/test_data/native_add_version_skew/hook/build.dart'),
  ];
  print(skipFiles);
  final allDartFiles = [
    for (final package in packages)
      ...Directory.fromUri(Platform.script.resolve('../../$package/'))
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && !skipFiles.contains(f.uri))
  ];
  print('Migrating ${allDartFiles.length} files.');
  Future.wait([
    for (final file in allDartFiles) migrateInPlace(file),
  ]);
  print('Done.');
}

const replacements = [
  ('config', 'input'),
  ('Config', 'Input'),
];

const skips = [
  // imports and file names
  'package_config',
  'config.dart',
  // cli arguments
  '--config',
  // external types.
  'PackageConfig',
  'Package config',
  // Things which should remain Config.
  'AndroidConfig',
  'CodeConfig',
  'CompilerConfig',
  'DataConfig',
  'IOSConfig',
  'MacOSConfig',
  'arConfig',
  'ccConfig',
  'ldConfig',
  'envScriptConfig',
  'envScriptArgsConfig',
  'targetOSConfig',
  'dryRunConfig',
  "configKey = 'target_os'",
  // Mangled names.
  'Configuration',
  'Configured',
  'Configurable',
];

const replacements2ndRound = [
  // ldConfig reverts this
  ('BuildConfig', 'BuildInput'),
  ('buildConfig', 'buildInput'),
];

const checkReplaced = [
  'BuildConfig',
];

final allSkips = {
  for (final skip in skips) ...[
    skip,
    skip.lcFirst(),
  ],
};

Future<void> migrateInPlace(File file) async {
  var contents = await file.readAsString();
  for (final replacement in replacements) {
    contents = contents.replaceAll(replacement.$1, replacement.$2);
  }

  for (final skip in allSkips) {
    var wrongReplace = skip;
    for (final replacement in replacements) {
      wrongReplace = wrongReplace.replaceAll(replacement.$1, replacement.$2);
    }
    contents = contents.replaceAll(wrongReplace, skip);
  }

  for (final replacement in replacements2ndRound) {
    contents = contents.replaceAll(replacement.$1, replacement.$2);
  }

  ensureReplaced(contents, file);

  await file.writeAsString(contents);
}

void ensureReplaced(String contents, File file) {
  for (final needle in checkReplaced) {
    if (contents.contains(needle)) {
      print('Warning: $file contains $needle.');
    }
  }
}

extension StringExtensions on String {
  String lcFirst() {
    if (isEmpty) {
      return this;
    }
    return this[0].toLowerCase() + substring(1);
  }
}
