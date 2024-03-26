// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'asset.dart';

/// A code [Asset] which respects the native application binary interface (ABI).
///
/// Typical languages which produce code assets that respect the native ABI
/// include C, C++ (with `extern "C"`), Rust (with `extern "C"`), and a subset
/// of language features of Objective-C.
///
/// Native code assets can be accessed at runtime through native external
/// functions via their asset [id]:
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
/// There are several types of native code assets:
/// * Assets which designate symbols present in the target system
///   ([DynamicLoadingSystem]), process ([LookupInProcess]), or executable
///   ([LookupInExecutable]). These assets do not have a [file].
/// * Dynamic libraries bundled into the application
///   ([DynamicLoadingBundled]). These assets must provide a [file] to be
///   bundled.
///
/// An application is compiled to run on a specific target [os] and
/// [architecture]. Different targets require different assets, so the package
/// developer must specify which asset to bundle for which target.
///
/// An asset has different ways of being accessible in the final application. It
/// is either brought in "manually" by having the package developer specify a
/// [file] path of the asset on the current system, it can be part of the Dart
/// or Flutter SDK ([LookupInProcess]), or it can be already present in the
/// target system ([DynamicLoadingSystem]). If the asset is bundled
/// "manually", the Dart or Flutter SDK will take care of copying the asset
/// [file] from its specified location on the current system into the
/// application bundle.
abstract final class NativeCodeAsset implements Asset {
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

  /// The file to be bundled with the Dart or Flutter application.
  ///
  /// How this file is bundled depends on the kind of asset, represented by a
  /// concrete subtype of [Asset], and the SDK (Dart or Flutter).
  ///
  /// If the [linkMode] is [DynamicLoadingBundled], the file name must be
  /// provided in the [BuildOutput] for [BuildConfig.dryRun]. Supplying a file
  /// name instead of an absolute path is enough for [BuildConfig.dryRun]. The
  /// file does not have to exist on disk during a dry run.
  ///
  /// If the [linkMode] is [DynamicLoadingSystem], [LookupInProcess], or
  /// [LookupInExecutable] the file must be omitted in the [BuildOutput] for
  /// [BuildConfig.dryRun].
  @override
  Uri? get file;

  /// Constructs a native code asset.
  ///
  /// The [id] of this asset is a uri `package:<package>/<name>` from [package]
  /// and [name].
  factory NativeCodeAsset({
    required String package,
    required String name,
    required LinkMode linkMode,
    required OS os,
    Uri? file,
    Architecture? architecture,
  }) =>
      NativeCodeAssetImpl(
        id: 'package:$package/$name',
        linkMode: linkMode as LinkModeImpl,
        os: os as OSImpl,
        architecture: architecture as ArchitectureImpl?,
        file: file,
      );

  static const String type = 'native_code';
}

/// The link mode for a [NativeCodeAsset].
///
/// Known linking modes:
///
/// * [DynamicLoading]
///   * [DynamicLoadingBundled]
///   * [DynamicLoadingSystem]
///   * [LookupInProcess]
///   * [LookupInExecutable]
/// * [StaticLinking]
///
/// See the documentation on the above classes.
abstract final class LinkMode {}

/// The [NativeCodeAsset] will be loaded at runtime.
///
/// Nothing happens at native code linking time.
///
/// Supported in the Dart and Flutter SDK.
///
/// Note: Dynamic loading is not equal to dynamic linking. Dynamic linking
/// would have to run the linker at compile-time, which is currently not
/// supported in the Dart and Flutter SDK.
abstract final class DynamicLoading implements LinkMode {}

/// The dynamic library is bundled by Dart/Flutter at build time.
///
/// At runtime, the dynamic library will be loaded and the symbols will be
/// looked up in this dynamic library.
///
/// An asset with this dynamic loading method must provide a
/// [NativeCodeAsset.file]. The Dart and Flutter SDK will bundle this code in
/// the final application.
///
/// During a [BuildConfig.dryRun], the [NativeCodeAsset.file] can be a file name
/// instead of a the full path. The file does not have to exist during a dry
/// run.
abstract final class DynamicLoadingBundled implements DynamicLoading {
  factory DynamicLoadingBundled() = DynamicLoadingBundledImpl;
}

/// The dynamic library is avaliable on the target system `PATH`.
///
/// At buildtime, nothing happens.
///
/// At runtime, the dynamic library will be loaded and the symbols will be
/// looked up in this dynamic library.
abstract final class DynamicLoadingSystem implements DynamicLoading {
  Uri get uri;

  factory DynamicLoadingSystem(Uri uri) = DynamicLoadingSystemImpl;
}

/// The native code is loaded in the process and symbols are available through
/// `DynamicLibrary.process()`.
abstract final class LookupInProcess implements DynamicLoading {
  factory LookupInProcess() = LookupInProcessImpl;
}

/// The native code is embedded in executable and symbols are available through
/// `DynamicLibrary.executable()`.
abstract final class LookupInExecutable implements DynamicLoading {
  factory LookupInExecutable() = LookupInExecutableImpl;
}

/// Static linking.
///
/// At native linking time, native function names will be resolved to static
/// libraries.
///
/// Not yet supported in the Dart and Flutter SDK.
// TODO(https://github.com/dart-lang/sdk/issues/49418): Support static linking.
abstract final class StaticLinking implements LinkMode {
  factory StaticLinking() = StaticLinkingImpl;
}
