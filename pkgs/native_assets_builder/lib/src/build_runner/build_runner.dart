// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:package_config/package_config.dart';

import '../package_layout/package_layout.dart';
import '../utils/run_process.dart';
import 'build_planner.dart';

typedef DependencyMetadata = Map<String, Metadata>;

/// The programmatic API to be used by Dart launchers to invoke native builds.
///
/// These methods are invoked by launchers such as dartdev (for `dart run`)
/// and flutter_tools (for `flutter run` and `flutter build`).
class NativeAssetsBuildRunner {
  final Logger logger;
  final Uri dartExecutable;

  NativeAssetsBuildRunner({
    required this.logger,
    required this.dartExecutable,
  });

  /// [workingDirectory] is expected to contain `.dart_tool`.
  ///
  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// If provided, only native assets of all transitive dependencies of
  /// [runPackageName] are built.
  Future<BuildResult> build({
    required LinkModePreferenceImpl linkModePreference,
    required Target target,
    required Uri workingDirectory,
    required BuildModeImpl buildMode,
    CCompilerConfigImpl? cCompilerConfig,
    IOSSdkImpl? targetIOSSdk,
    int? targetAndroidNdkApi,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    String? runPackageName,
    Iterable<String>? supportedAssetTypes,
  }) async {
    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);
    final packagesWithNativeAssets =
        await packageLayout.packagesWithNativeAssets;
    final List<Package> buildPlan;
    final PackageGraph packageGraph;
    if (packagesWithNativeAssets.length <= 1 && runPackageName == null) {
      buildPlan = packagesWithNativeAssets;
      packageGraph = PackageGraph({
        for (final p in packagesWithNativeAssets) p.name: [],
      });
    } else {
      final planner = await NativeAssetsBuildPlanner.fromRootPackageRoot(
        rootPackageRoot: packageLayout.rootPackageRoot,
        packagesWithNativeAssets: packagesWithNativeAssets,
        dartExecutable: Uri.file(Platform.resolvedExecutable),
        logger: logger,
      );
      final (plan, planSuccess) = planner.plan(
        runPackageName: runPackageName,
      );
      if (!planSuccess) {
        return _BuildResultImpl(
          assets: [],
          dependencies: [],
          success: false,
        );
      }
      buildPlan = plan;
      packageGraph = planner.packageGraph;
    }
    final assets = <AssetImpl>[];
    final dependencies = <Uri>[];
    final metadata = <String, Metadata>{};
    var success = true;
    for (final package in buildPlan) {
      final dependencyMetadata = _metadataForPackage(
        packageGraph: packageGraph,
        packageName: package.name,
        targetMetadata: metadata,
      );
      final config = await _cliConfig(
        packageName: package.name,
        packageRoot: packageLayout.packageRoot(package.name),
        target: target,
        buildMode: buildMode,
        linkMode: linkModePreference,
        buildParentDir: packageLayout.dartToolNativeAssetsBuilder,
        dependencyMetadata: dependencyMetadata,
        cCompilerConfig: cCompilerConfig,
        targetIOSSdk: targetIOSSdk,
        targetAndroidNdkApi: targetAndroidNdkApi,
        supportedAssetTypes: supportedAssetTypes,
      );
      final (
        packageAssets,
        packageDependencies,
        packageMetadata,
        packageSuccess,
      ) = await _buildPackageCached(
        config,
        packageLayout.packageConfigUri,
        workingDirectory,
        includeParentEnvironment,
      );
      assets.addAll(packageAssets);
      dependencies.addAll(packageDependencies);
      success &= packageSuccess;
      if (packageMetadata != null) {
        metadata[config.packageName] = packageMetadata;
      }
    }
    return _BuildResultImpl(
      assets: assets,
      dependencies: dependencies..sort(_uriCompare),
      success: success,
    );
  }

  /// [workingDirectory] is expected to contain `.dart_tool`.
  ///
  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// If provided, only native assets of all transitive dependencies of
  /// [runPackageName] are built.
  Future<DryRunResult> dryRun({
    required LinkModePreferenceImpl linkModePreference,
    required OSImpl targetOS,
    required Uri workingDirectory,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    String? runPackageName,
    Iterable<String>? supportedAssetTypes,
  }) async {
    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);
    final packagesWithNativeAssets =
        await packageLayout.packagesWithNativeAssets;
    final List<Package> buildPlan;
    if (packagesWithNativeAssets.length <= 1 && runPackageName == null) {
      buildPlan = packagesWithNativeAssets;
    } else {
      final planner = await NativeAssetsBuildPlanner.fromRootPackageRoot(
        rootPackageRoot: packageLayout.rootPackageRoot,
        packagesWithNativeAssets: packagesWithNativeAssets,
        dartExecutable: Uri.file(Platform.resolvedExecutable),
        logger: logger,
      );
      final (plan, planSuccess) = planner.plan(
        runPackageName: runPackageName,
      );
      if (!planSuccess) {
        return _DryRunResultImpl(
          assets: [],
          success: false,
        );
      }
      buildPlan = plan;
    }
    final assets = <AssetImpl>[];
    var success = true;
    for (final package in buildPlan) {
      final config = await _cliConfigDryRun(
        packageName: package.name,
        packageRoot: packageLayout.packageRoot(package.name),
        targetOS: targetOS,
        linkMode: linkModePreference,
        buildParentDir: packageLayout.dartToolNativeAssetsBuilder,
        supportedAssetTypes: supportedAssetTypes,
      );
      final (packageAssets, _, _, packageSuccess) = await _buildPackage(
        config,
        packageLayout.packageConfigUri,
        workingDirectory,
        includeParentEnvironment,
        dryRun: true,
      );
      for (final asset in packageAssets) {
        switch (asset) {
          case NativeCodeAssetImpl _:
            if (asset.architecture != null) {
              // Backwards compatibility, if an architecture is provided use it.
              assets.add(asset);
            } else {
              // Dry run does not report architecture. Dart VM branches on OS
              // and Target when looking up assets, so populate assets for all
              // architectures.
              for (final architecture in asset.os.architectures) {
                assets.add(asset.copyWith(
                  architecture: architecture,
                ));
              }
            }
          case DataAssetImpl _:
            assets.add(asset);
        }
      }
      success &= packageSuccess;
    }
    return _DryRunResultImpl(
      assets: assets,
      success: success,
    );
  }

  Future<_PackageBuildRecord> _buildPackageCached(
    BuildConfigImpl config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment,
  ) async {
    final packageName = config.packageName;
    final outDir = config.outputDirectory;
    if (!await Directory.fromUri(outDir).exists()) {
      await Directory.fromUri(outDir).create(recursive: true);
    }

    final buildOutput = await BuildOutputImpl.readFromFile(outDir: outDir);
    final lastBuilt = buildOutput?.timestamp.roundDownToSeconds() ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final dependencies = buildOutput?.dependenciesModel;
    final lastChange = await dependencies?.lastModified() ?? DateTime.now();

    if (lastBuilt.isAfter(lastChange)) {
      logger.info('Skipping build for $packageName in $outDir. '
          'Last build on $lastBuilt, last input change on $lastChange.');
      // All build flags go into [outDir]. Therefore we do not have to check
      // here whether the config is equal.
      final assets = buildOutput!.assets;
      final dependencies = buildOutput.dependencies;
      final metadata = buildOutput.metadataModel;
      return (assets, dependencies, metadata, true);
    }

    return await _buildPackage(
      config,
      packageConfigUri,
      workingDirectory,
      includeParentEnvironment,
      dryRun: false,
    );
  }

  Future<_PackageBuildRecord> _buildPackage(
    BuildConfigImpl config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment, {
    required bool dryRun,
  }) async {
    final outDir = config.outputDirectory;
    final configFile = outDir.resolve('../config.json');
    final buildHook = config.packageRoot.resolve('hook/').resolve('build.dart');
    final buildHookLegacy = config.packageRoot.resolve('build.dart');
    final configFileContents = config.toJsonString();
    logger.info('config.json contents: $configFileContents');
    await File.fromUri(configFile).writeAsString(configFileContents);
    final buildOutputFile =
        File.fromUri(outDir.resolve(BuildOutputImpl.fileNameV1_1_0));
    if (await buildOutputFile.exists()) {
      // Ensure we'll never read outdated build results.
      await buildOutputFile.delete();
    }

    final arguments = [
      '--packages=${packageConfigUri.toFilePath()}',
      if (await File.fromUri(buildHook).exists())
        buildHook.toFilePath()
      else
        buildHookLegacy.toFilePath(),
      '--config=${configFile.toFilePath()}',
    ];
    final result = await runProcess(
      workingDirectory: workingDirectory,
      executable: dartExecutable,
      arguments: arguments,
      logger: logger,
      includeParentEnvironment: includeParentEnvironment,
    );
    var success = true;
    if (result.exitCode != 0) {
      final printWorkingDir = workingDirectory != Directory.current.uri;
      final commandString = [
        if (printWorkingDir) '(cd ${workingDirectory.toFilePath()};',
        dartExecutable.toFilePath(),
        ...arguments.map((a) => a.contains(' ') ? "'$a'" : a),
        if (printWorkingDir) ')',
      ].join(' ');
      logger.severe(
        '''
Building native assets for package:${config.packageName} failed.
build.dart returned with exit code: ${result.exitCode}.
To reproduce run:
$commandString
stderr:
${result.stderr}
stdout:
${result.stdout}
        ''',
      );
      success = false;
    }

    try {
      final buildOutput = await BuildOutputImpl.readFromFile(outDir: outDir);
      final assets = buildOutput?.assets ?? [];
      success &= validateAssetsPackage(assets, config.packageName);
      final dependencies = buildOutput?.dependencies ?? [];
      final metadata = dryRun ? null : buildOutput?.metadataModel;
      return (assets, dependencies, metadata, success);
    } on FormatException catch (e) {
      logger.severe('''
Building native assets for package:${config.packageName} failed.
build_output.json contained a format error.
${e.message}
        ''');
      success = false;
      return (<NativeCodeAssetImpl>[], <Uri>[], const Metadata({}), false);
      // TODO(https://github.com/dart-lang/native/issues/109): Stop throwing
      // type errors in native_assets_cli, release a new version of that package
      // and then remove this.
      // ignore: avoid_catching_errors
    } on TypeError {
      logger.severe('''
Building native assets for package:${config.packageName} failed.
build_output.json contained a format error.
        ''');
      success = false;
      return (<NativeCodeAssetImpl>[], <Uri>[], const Metadata({}), false);
    } finally {
      if (!success) {
        final buildOutputFile =
            File.fromUri(outDir.resolve(BuildOutputImpl.fileNameV1_1_0));
        if (await buildOutputFile.exists()) {
          await buildOutputFile.delete();
        }
      }
    }
  }

  static Future<BuildConfigImpl> _cliConfig({
    required String packageName,
    required Uri packageRoot,
    required Target target,
    IOSSdkImpl? targetIOSSdk,
    int? targetAndroidNdkApi,
    required BuildModeImpl buildMode,
    required LinkModePreferenceImpl linkMode,
    required Uri buildParentDir,
    CCompilerConfigImpl? cCompilerConfig,
    DependencyMetadata? dependencyMetadata,
    Iterable<String>? supportedAssetTypes,
  }) async {
    final buildDirName = BuildConfigImpl.checksum(
      packageName: packageName,
      packageRoot: packageRoot,
      targetOS: target.os,
      targetArchitecture: target.architecture,
      buildMode: buildMode,
      linkModePreference: linkMode,
      targetIOSSdk: targetIOSSdk,
      cCompiler: cCompilerConfig,
      dependencyMetadata: dependencyMetadata,
      targetAndroidNdkApi: targetAndroidNdkApi,
      supportedAssetTypes: supportedAssetTypes,
    );
    final outDirUri = buildParentDir.resolve('$buildDirName/out/');
    final outDir = Directory.fromUri(outDirUri);
    if (!await outDir.exists()) {
      // TODO(https://dartbug.com/50565): Purge old or unused folders.
      await outDir.create(recursive: true);
    }
    return BuildConfigImpl(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: packageRoot,
      targetOS: target.os,
      targetArchitecture: target.architecture,
      buildMode: buildMode,
      linkModePreference: linkMode,
      targetIOSSdk: targetIOSSdk,
      cCompiler: cCompilerConfig,
      dependencyMetadata: dependencyMetadata,
      targetAndroidNdkApi: targetAndroidNdkApi,
    );
  }

  static Future<BuildConfigImpl> _cliConfigDryRun({
    required String packageName,
    required Uri packageRoot,
    required OSImpl targetOS,
    required LinkModePreferenceImpl linkMode,
    required Uri buildParentDir,
    Iterable<String>? supportedAssetTypes,
  }) async {
    final buildDirName = 'dry_run_${targetOS}_$linkMode';
    final outDirUri = buildParentDir.resolve('$buildDirName/out/');
    final outDir = Directory.fromUri(outDirUri);
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }
    return BuildConfigImpl.dryRun(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: packageRoot,
      targetOS: targetOS,
      linkModePreference: linkMode,
      supportedAssetTypes: supportedAssetTypes,
    );
  }

  DependencyMetadata? _metadataForPackage({
    required PackageGraph packageGraph,
    required String packageName,
    DependencyMetadata? targetMetadata,
  }) {
    if (targetMetadata == null) {
      return null;
    }
    final dependencies = packageGraph.neighborsOf(packageName).toSet();
    return {
      for (final entry in targetMetadata.entries)
        if (dependencies.contains(entry.key)) entry.key: entry.value,
    };
  }

  bool validateAssetsPackage(Iterable<AssetImpl> assets, String packageName) {
    final invalidAssetIds = assets
        .map((a) => a.id)
        .where((n) => !n.startsWith('package:$packageName/'))
        .toSet()
        .toList()
      ..sort();
    final success = invalidAssetIds.isEmpty;
    if (!success) {
      logger.severe(
        '`package:$packageName` declares the following assets which do not '
        'start with `package:$packageName/`: ${invalidAssetIds.join(', ')}.',
      );
    }
    return success;
  }
}

typedef _PackageBuildRecord = (
  Iterable<AssetImpl>,
  Iterable<Uri> dependencies,
  Metadata?,
  bool success,
);

/// The result from a [NativeAssetsBuildRunner.dryRun].
abstract interface class DryRunResult {
  /// The native assets for all [Target]s for the build or dry run.
  List<AssetImpl> get assets;

  /// Whether all builds completed without errors.
  ///
  /// All error messages are streamed to [NativeAssetsBuildRunner.logger].
  bool get success;
}

final class _DryRunResultImpl implements DryRunResult {
  @override
  final List<AssetImpl> assets;

  @override
  final bool success;

  _DryRunResultImpl({
    required this.assets,
    required this.success,
  });
}

/// The result from a [NativeAssetsBuildRunner.build].
abstract class BuildResult implements DryRunResult {
  /// All the files used for building the native assets of all packages.
  ///
  /// This aggregated list can be used to determine whether the
  /// [NativeAssetsBuildRunner] needs to be invoked again. The
  /// [NativeAssetsBuildRunner] determines per package with native assets
  /// if it needs to run the build again.
  List<Uri> get dependencies;
}

final class _BuildResultImpl implements BuildResult {
  @override
  final List<AssetImpl> assets;

  @override
  final List<Uri> dependencies;

  @override
  final bool success;

  _BuildResultImpl({
    required this.assets,
    required this.dependencies,
    required this.success,
  });
}

extension on DateTime {
  DateTime roundDownToSeconds() =>
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch -
          millisecondsSinceEpoch % const Duration(seconds: 1).inMilliseconds);
}

int _uriCompare(Uri u1, Uri u2) => u1.toString().compareTo(u2.toString());
