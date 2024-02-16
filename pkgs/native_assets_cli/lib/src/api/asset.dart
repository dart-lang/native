// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:yaml/yaml.dart';

import '../utils/yaml.dart';
import 'link_mode.dart';
import 'target.dart';

part '../model/asset.dart';

abstract final class AssetPath {}

/// Asset at absolute path [uri].
abstract final class AssetAbsolutePath implements AssetPath {
  Uri get uri;

  factory AssetAbsolutePath(Uri uri) = AssetAbsolutePathImpl;
}

/// Asset is avaliable on the system `PATH`.
///
/// [uri] only contains a file name.
abstract final class AssetSystemPath implements AssetPath {
  Uri get uri;

  factory AssetSystemPath(Uri uri) = AssetSystemPathImpl;
}

/// Asset is loaded in the process and symbols are available through
/// `DynamicLibrary.process()`.
abstract final class AssetInProcess implements AssetPath {
  factory AssetInProcess() = AssetInProcessImpl;
}

/// Asset is embedded in executable and symbols are available through
/// `DynamicLibrary.executable()`.
abstract final class AssetInExecutable implements AssetPath {
  factory AssetInExecutable() = AssetInExecutableImpl;
}

/// A code asset which respects the C application binary interface (ABI).
///
/// Typical other languages which produce code assets that respect the C ABI
/// include C++ and Rust.
abstract final class CCodeAsset {
  LinkMode get linkMode;
  String get id;
  Target get target;
  AssetPath get path;

  factory CCodeAsset({
    required String id,
    required LinkMode linkMode,
    required Target target,
    required AssetPath path,
  }) =>
      CCodeAssetImpl(
        id: id,
        linkMode: linkMode as LinkModeImpl,
        target: target as TargetImpl,
        path: path as AssetPathImpl,
      );
}
