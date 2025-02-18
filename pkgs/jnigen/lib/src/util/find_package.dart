// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:package_config/package_config.dart';

Future<Package?> findPackage(String packageName) async {
  final packageConfig = await findPackageConfig(Directory.current);
  if (packageConfig == null) {
    return null;
  }
  return packageConfig[packageName];
}

Future<Uri?> findPackageRoot(String packageName) async {
  return (await findPackage(packageName))?.root;
}

Future<bool> isPackageModifiedAfter(String packageName, DateTime time,
    [String? subDir]) async {
  final root = await findPackageRoot(packageName);
  if (root == null) {
    throw UnsupportedError('package $packageName does not exist');
  }
  var checkRoot = root;
  if (subDir != null) {
    checkRoot = root.resolve(subDir);
  }
  final dir = Directory.fromUri(checkRoot);
  if (!await dir.exists()) {
    throw UnsupportedError('can not resolve $subDir in $packageName');
  }
  // A directory's modification time is not helpful because one of
  // internal files may be modified later.
  // In case of git / pub package we might be able to check pubspec, but no
  // such technique applies for path packages.
  await for (final entry in dir.list(recursive: true)) {
    if (!isExcludedBuildPath(entry)) {
      final stat = await entry.stat();
      if (stat.modified.isAfter(time)) {
        print(stat);
        print(entry);
        return true;
      }
    }
  }
  return false;
}

bool isExcludedBuildPath(FileSystemEntity entry) {
  return entry.path.contains('pom.xml') ||
      entry.path.endsWith('.md') ||
      entry.path.contains('.gradle') ||
      entry.path.contains('.idea') ||
      entry.path.contains('build');
}