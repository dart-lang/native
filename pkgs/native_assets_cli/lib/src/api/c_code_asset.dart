// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'asset.dart';

/// A code [Asset] which respects the C application binary interface (ABI).
///
/// Typical other languages which produce code assets that respect the C ABI
/// include C++ and Rust.
///
/// There are several example types of assets:
/// * Assets which designate symbols present in the target system, process, or
///   executable. They are identified by their name.
/// * Dynamic libraries bundled into the application.
///
/// An application is compiled to run on a certain target OS and architecture.
/// If different targets require different assets, the package developer must
/// specify which asset to bundle for which target.
///
/// An asset has different ways of being accessible in the final application. It
/// is either brought in "manually" by having the package developer specify a
/// path of the asset on the current system, it can be part of the Dart or
/// Flutter SDK, or it can be already present in the target system. If the asset
/// is bundled "manually", the Dart or Flutter SDK will take care of copying the
/// asset from its specified location on the current system into the application
/// bundle.
///
/// Assets are also called "native assets" to differentiate them from the Dart
/// code also bundled with an application.
abstract final class CCodeAsset implements Asset {
  LinkMode get linkMode;

  /// The operating system this asset can run on.
  OS get os;

  /// The architecture this asset can run on.
  ///
  /// Not available during a [BuildConfig.dryRun].
  Architecture? get architecture;

  AssetPath get path;

  factory CCodeAsset({
    required String id,
    required LinkMode linkMode,
    required OS os,
    required AssetPath path,
    Uri? file,
    Architecture? architecture,
  }) =>
      CCodeAssetImpl(
        id: id,
        linkMode: linkMode as LinkModeImpl,
        os: os as OSImpl,
        architecture: architecture as ArchitectureImpl?,
        path: path as AssetPathImpl,
        file: file,
      );
}

abstract final class AssetPath {}

/// Asset at absolute path.
abstract final class AssetAbsolutePath implements AssetPath {
  factory AssetAbsolutePath() = AssetAbsolutePathImpl;
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
