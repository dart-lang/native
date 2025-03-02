// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/file.dart';
import 'package:package_config/package_config.dart';

import '../../native_assets_builder.dart';

/// Directory layout for dealing with native assets.
///
/// For the [NativeAssetsBuildRunner] to correctly run hooks, multiple pieces of
/// information are required:
/// * [packageConfig] to know the list of all packages that may contain hooks.
/// * [packageConfigUri] to be able to get a dependency graph with `pub` and to
///   know where to cache/share asset builds.
/// * [runPackageName] to know which package build hooks to invoke and ignore.
///   Only dependencies of the "run package" are built.
///
/// The [NativeAssetsBuildRunner] builds assets in
/// `.dart_tool/native_assets_builder`. The directory layout follows pub's
/// convention for caching:
/// https://dart.dev/tools/pub/package-layout#project-specific-caching-for-tools
class PackageLayout {
  /// Package config containing the information of where to foot the root [Uri]s
  /// of other packages.
  ///
  /// Can be `null` to enable quick construction of a
  /// [PackageLayout].
  final PackageConfig packageConfig;

  final Uri packageConfigUri;

  /// Only assets of transitive dependencies of [runPackageName] are built.
  final String runPackageName;

  PackageLayout._(
    this.packageConfig,
    this.packageConfigUri,
    this.runPackageName,
  );

  factory PackageLayout.fromPackageConfig(
    FileSystem fileSystem,
    PackageConfig packageConfig,
    Uri packageConfigUri,
    String runPackageName,
  ) {
    assert(fileSystem.file(packageConfigUri).existsSync());
    packageConfigUri = packageConfigUri.normalizePath();
    return PackageLayout._(packageConfig, packageConfigUri, runPackageName);
  }

  static Future<PackageLayout> fromWorkingDirectory(
    FileSystem fileSystem,
    Uri workingDirectory,
    String runPackgeName,
  ) async {
    workingDirectory = workingDirectory.normalizePath();
    final packageConfigUri = await findPackageConfig(
      fileSystem,
      workingDirectory,
    );
    assert(await fileSystem.file(packageConfigUri).exists());
    final packageConfig = await loadPackageConfigUri(packageConfigUri!);
    return PackageLayout._(packageConfig, packageConfigUri, runPackgeName);
  }

  static Future<Uri?> findPackageConfig(
    FileSystem fileSystem,
    Uri rootPackageRoot,
  ) async {
    final packageConfigUri = rootPackageRoot.resolve(
      '.dart_tool/package_config.json',
    );
    final file = fileSystem.file(packageConfigUri);
    if (await file.exists()) {
      return file.uri;
    }
    final parentUri = rootPackageRoot.resolve('../');
    if (parentUri == rootPackageRoot) {
      return null;
    }
    return findPackageConfig(fileSystem, parentUri);
  }

  /// The .dart_tool directory is used to store built artifacts and caches.
  ///
  /// This is the `.dart_tool/` directory where the package config is.
  ///
  /// When pub workspaces are used, the hook results are shared across all
  /// packages in the workspace.
  ///
  /// Each package should only modify the subfolder of `.dart_tool/` with its
  /// own name.
  /// https://dart.dev/tools/pub/package-layout#project-specific-caching-for-tools
  late final Uri dartTool = packageConfigUri.resolve('./');

  /// The directory where `package:native_assets_builder` stores all persistent
  /// information.
  ///
  /// This folder is owned by `package:native_assets_builder`, no other package
  /// should read or modify it.
  /// https://dart.dev/tools/pub/package-layout#project-specific-caching-for-tools
  ///
  /// `$rootPackageRoot/.dart_tool/native_assets_builder/`.
  late final Uri dartToolNativeAssetsBuilder = dartTool.resolve(
    'native_assets_builder/',
  );

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
}
