// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model/asset.dart' as model;
import '../model/link_mode.dart' as model;
import '../model/target.dart' as model;
import 'link_mode.dart';
import 'target.dart';

abstract class AssetPath {}

/// Asset at absolute path [uri].
abstract class AssetAbsolutePath implements AssetPath {
  Uri get uri;

  factory AssetAbsolutePath(Uri uri) = model.AssetAbsolutePath;
}

/// Asset is avaliable on the system `PATH`.
///
/// [uri] only contains a file name.
abstract class AssetSystemPath implements AssetPath {
  Uri get uri;

  factory AssetSystemPath(Uri uri) = model.AssetSystemPath;
}

/// Asset is loaded in the process and symbols are available through
/// `DynamicLibrary.process()`.
abstract class AssetInProcess implements AssetPath {
  factory AssetInProcess() = model.AssetInProcess;
}

/// Asset is embedded in executable and symbols are available through
/// `DynamicLibrary.executable()`.
abstract class AssetInExecutable implements AssetPath {
  factory AssetInExecutable() = model.AssetInExecutable;
}

abstract class Asset {
  LinkMode get linkMode;
  String get id;
  Target get target;
  AssetPath get path;
  String get linkInPackage;

  factory Asset({
    required String id,
    required LinkMode linkMode,
    required Target target,
    required AssetPath path,
    String linkInPackage = '',
  }) =>
      model.Asset(
        id: id,
        linkMode: linkMode as model.LinkMode,
        target: target as model.Target,
        path: path as model.AssetPath,
        linkInPackage: linkInPackage,
      );
}
