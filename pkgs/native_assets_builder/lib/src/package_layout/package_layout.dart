// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:package_config/package_config.dart';

/// Directory layout for dealing with native assets.
///
/// Build hooks for native assets will be run from the context of another root
/// package.
///
/// The directory layout follows pub's convention for caching:
/// https://dart.dev/tools/pub/package-layout#project-specific-caching-for-tools
class PackageLayout {
  /// The root folder of the current dart invocation root package.
  ///
  /// `$rootPackageRoot`.
  final Uri rootPackageRoot;

  /// Package config containing the information of where to foot the root [Uri]s
  /// of other packages.
  ///
  /// Can be `null` to enable quick construction of a
  /// [PackageLayout].
  final PackageConfig packageConfig;

  final Uri packageConfigUri;

  PackageLayout._(
      this.rootPackageRoot, this.packageConfig, this.packageConfigUri);

  factory PackageLayout.fromPackageConfig(
    PackageConfig packageConfig,
    Uri packageConfigUri,
  ) {
    assert(File.fromUri(packageConfigUri).existsSync());
    packageConfigUri = packageConfigUri.normalizePath();
    final rootPackageRoot = packageConfigUri.resolve('../');
    return PackageLayout._(rootPackageRoot, packageConfig, packageConfigUri);
  }

  static Future<PackageLayout> fromRootPackageRoot(Uri rootPackageRoot) async {
    rootPackageRoot = rootPackageRoot.normalizePath();
    final packageConfigUri =
        rootPackageRoot.resolve('.dart_tool/package_config.json');
    assert(await File.fromUri(packageConfigUri).exists());
    final packageConfig = await loadPackageConfigUri(packageConfigUri);
    return PackageLayout._(rootPackageRoot, packageConfig, packageConfigUri);
  }

  /// The .dart_tool directory is used to store built artifacts and caches.
  ///
  /// `$rootPackageRoot/.dart_tool/`.
  ///
  /// Each package should only modify the subfolder of `.dart_tool/` with its
  /// own name.
  /// https://dart.dev/tools/pub/package-layout#project-specific-caching-for-tools
  late final Uri dartTool = rootPackageRoot.resolve('.dart_tool/');

  /// The directory where `package:native_assets_builder` stores all persistent
  /// information.
  ///
  /// This folder is owned by `package:native_assets_builder`, no other package
  /// should read or modify it.
  /// https://dart.dev/tools/pub/package-layout#project-specific-caching-for-tools
  ///
  /// `$rootPackageRoot/.dart_tool/native_assets_builder/`.
  late final Uri dartToolNativeAssetsBuilder =
      dartTool.resolve('native_assets_builder/');

  /// The root of `package:$packageName`.
  ///
  /// `$packageName/`.
  ///
  /// This folder is owned by pub, and should _never_ be written to.
  Uri packageRoot(String packageName) {
    final package = packageConfig[packageName];
    if (package == null) {
      throw StateError('Package $packageName not found in packageConfig.');
    }
    return package.root;
  }

  /// All packages in [packageConfig] with native assets.
  ///
  /// Whether a package has native assets is defined by whether it contains
  /// a `hook/build.dart` or `hook/link.dart`.
  ///
  /// For backwards compatibility, a toplevel `build.dart` is also supported.
  // TODO(https://github.com/dart-lang/native/issues/823): Remove fallback when
  // everyone has migrated. (Probably once we stop backwards compatibility of
  // the protocol version pre 1.2.0 on some future version.)
  Future<List<Package>> packagesWithAssets(Hook hook) async => switch (hook) {
        Hook.build => _packagesWithBuildAssets ??=
            await _packagesWithHook(hook),
        Hook.link => _packagesWithLinkAssets ??= await _packagesWithHook(hook),
      };

  List<Package>? _packagesWithBuildAssets;
  List<Package>? _packagesWithLinkAssets;

  Future<List<Package>> _packagesWithHook(Hook hook) async {
    final result = <Package>[];
    for (final package in packageConfig.packages) {
      final packageRoot = package.root;
      if (packageRoot.scheme == 'file') {
        if (await File.fromUri(
              packageRoot.resolve('hook/').resolve(hook.scriptName),
            ).exists() ||
            await File.fromUri(
              packageRoot.resolve(hook.scriptName),
            ).exists()) {
          result.add(package);
        }
      }
    }
    return result;
  }
}
