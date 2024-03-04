// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'asset.dart';

/// A code [Asset] which respects the C application binary interface (ABI).
///
/// Typical other languages which produce code assets that respect the C ABI
/// include C++ and Rust.
///
/// C code assets can be accessed at runtime through native external functions
/// via their asset [id]:
///
/// ```dart
/// import 'dart:ffi';
///
/// void main() {
///   final result = add(14, 28);
///   print(result);
/// }
///
/// @Native<Int Function(Int, Int)>(assetId: 'package:my_package/add.dart')
/// external int add(int a, int b);
/// ```
///
/// There are several types of C code assets:
/// * Assets which designate symbols present in the target system
///   ([SystemDylib]), process ([LookupInProcess]), or executable
///   ([LookupInExecutable]). These assets do not have a [file].
/// * Dynamic libraries bundled into the application ([BundledDylib]). These
///   assets must provide a [file] to be bundled.
///
/// An application is compiled to run on a specific target [os] and
/// [architecture]. Different targets require different assets, so the package
/// developer must specify which asset to bundle for which target.
///
/// An asset has different ways of being accessible in the final application. It
/// is either brought in "manually" by having the package developer specify a
/// [file] path of the asset on the current system, it can be part of the Dart
/// or Flutter SDK ([LookupInProcess]), or it can be already present in the
/// target system ([SystemDylib]). If the asset is bundled "manually", the Dart
/// or Flutter SDK will take care of copying the asset [file] from its specified
/// location on the current system into the application bundle.
abstract final class CCodeAsset implements Asset {
  /// The operating system this asset can run on.
  OS get os;

  /// The architecture this asset can run on.
  ///
  /// Not available during a [BuildConfig.dryRun].
  Architecture? get architecture;

  /// The link mode for this native code.
  ///
  /// Either dynamic loading or static linking.
  LinkMode get linkMode;

  /// The dynamic loading method when the [linkMode] is [LinkMode.dynamic].
  ///
  /// Throws a [StateError] when accessed with [linkMode] is [LinkMode.static].
  DynamicLoading get dynamicLoading;

  /// Consructs a c code asset.
  ///
  /// The [id] of this asset is a uri `package:<package>/<name>` from [package]
  /// and [name].
  ///
  /// If [linkMode] is [LinkMode.dynamic], a non-null [dynamicLoading] must be
  /// provided. If [linkMode] is [LinkMode.static], [dynamicLoading] must not be
  /// provided.
  ///
  /// If [linkMode] is [LinkMode.dynamic] and [dynamicLoading] is not
  /// [BundledDylib], a [file] must not be provided. If [dynamicLoading] is
  /// [BundledDylib], a [file] must be provided in non-[BuildConfig.dryRun]s.
  factory CCodeAsset({
    required String package,
    required String name,
    required LinkMode linkMode,
    required OS os,
    DynamicLoading? dynamicLoading,
    Uri? file,
    Architecture? architecture,
  }) =>
      CCodeAssetImpl(
        id: 'package:$package/$name',
        linkMode: linkMode as LinkModeImpl,
        os: os as OSImpl,
        architecture: architecture as ArchitectureImpl?,
        dynamicLoading: dynamicLoading as DynamicLoadingImpl?,
        file: file,
      );

  static const String type = 'c_code';
}

/// The dynamic loading method when the [CCodeAsset.linkMode] is
/// [LinkMode.dynamic].
abstract final class DynamicLoading {}

/// The asset file should be bundled by Dart/Flutter.
///
/// An asset with this dynamic loading method must provide a [Asset.file]. The
/// Dart and Flutter SDK will bundle this code in the final application.
abstract final class BundledDylib implements DynamicLoading {
  factory BundledDylib() = BundledDylibImpl;
}

/// Asset is avaliable on the target system `PATH`.
abstract final class SystemDylib implements DynamicLoading {
  Uri get uri;

  factory SystemDylib(Uri uri) = SystemDylibImpl;
}

/// Asset is loaded in the process and symbols are available through
/// `DynamicLibrary.process()`.
abstract final class LookupInProcess implements DynamicLoading {
  factory LookupInProcess() = LookupInProcessImpl;
}

/// Asset is embedded in executable and symbols are available through
/// `DynamicLibrary.executable()`.
abstract final class LookupInExecutable implements DynamicLoading {
  factory LookupInExecutable() = LookupInExecutableImpl;
}
