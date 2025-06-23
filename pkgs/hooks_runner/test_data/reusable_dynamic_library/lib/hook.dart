// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library is meant to be used in hooks of packages depending on this
/// package.
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

/// Helper class for populating a [CBuilder.library] call with the fields of
/// this class to link against the `add` dynamic library.
class AddLibrary {
  final BuildInput input;

  /// Librarie names for [CBuilder].
  final List<String> libraries = ['add'];

  /// Library directories for [CBuilder].
  late final List<String> libraryDirectories;

  /// Include directories for [CBuilder].
  late final List<String> includes;

  AddLibrary(this.input) {
    const packageName = 'reusable_dynamic_library';
    final buildAssetsFromPackage = input.assets[packageName];
    final codeAssetsFromPackage = buildAssetsFromPackage
        .where((a) => a.isCodeAsset)
        .map((a) => a.asCodeAsset)
        .toList();
    if (codeAssetsFromPackage.length != 1) {
      throw Exception(
        'Did not find a build asset from $packageName:'
        ' $codeAssetsFromPackage',
      );
    }
    final codeAsset = codeAssetsFromPackage.first;
    final dylibFile = File.fromUri(codeAsset.file!);
    if (!dylibFile.existsSync()) {
      throw Exception('Dylib file does not exist: $dylibFile');
    }
    final libraryDirectory = Directory.fromUri(dylibFile.uri.resolve('.'));
    libraryDirectories = [libraryDirectory.path];
    final includeDirectory = input.metadata[packageName]['include'];
    if (includeDirectory is! String) {
      throw Exception('Include directory is not a string: $includeDirectory');
    }
    includes = [includeDirectory];
  }
}
