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
  }) async =>
      _run(
        step: PipelineStep.build,
        linkModePreference: linkModePreference,
        target: target,
        workingDirectory: workingDirectory,
        buildMode: buildMode,
        cCompilerConfig: cCompilerConfig,
        targetIOSSdk: targetIOSSdk,
        targetAndroidNdkApi: targetAndroidNdkApi,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        runPackageName: runPackageName,
        supportedAssetTypes: supportedAssetTypes,
      );

  Future<BuildResult> link({
    required Target target,
    required Uri workingDirectory,
    required BuildModeImpl buildMode,
    CCompilerConfigImpl? cCompilerConfig,
    IOSSdkImpl? targetIOSSdk,
    int? targetAndroidNdkApi,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    Uri? resourceIdentifiers,
    String? runPackageName,
    Iterable<String>? supportedAssetTypes,
    required BuildResult buildResult,
  }) async =>
      _run(
        step: PipelineStep.link,
        linkModePreference: LinkModePreferenceImpl.dynamic,
        target: target,
        workingDirectory: workingDirectory,
        buildMode: buildMode,
        cCompilerConfig: cCompilerConfig,
        targetIOSSdk: targetIOSSdk,
        targetAndroidNdkApi: targetAndroidNdkApi,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        runPackageName: runPackageName,
        resourceIdentifiers: resourceIdentifiers,
        supportedAssetTypes: supportedAssetTypes,
        previousBuildResult: buildResult,
      );

  Future<BuildResult> _run({
    required PipelineStep step,
    required LinkModePreferenceImpl linkModePreference,
    required Target target,
    required Uri workingDirectory,
    required BuildModeImpl buildMode,
    CCompilerConfigImpl? cCompilerConfig,
    IOSSdkImpl? targetIOSSdk,
    int? targetAndroidNdkApi,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    Uri? resourceIdentifiers,
    String? runPackageName,
    Iterable<String>? supportedAssetTypes,
    BuildResult? previousBuildResult,
  }) async {
    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);
    final packagesWithBuild = await packageLayout.packagesWithAssets(step);
    final (buildPlan, packageGraph, planSuccess) = await _plannedPackages(
        packagesWithBuild, packageLayout, runPackageName);
    final buildResult = _BuildResultImpl._failure();
    if (!planSuccess) {
      return buildResult;
    }
    final metadata = <String, Metadata>{};
    var success = true;
    for (final package in buildPlan) {
      final dependencyMetadata = _metadataForPackage(
        packageGraph: packageGraph,
        packageName: package.name,
        targetMetadata: metadata,
      );
      final buildConfig = await _cliConfig(
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
      final PipelineConfigImpl config;
      if (step == PipelineStep.link) {
        config = LinkConfigArgs(
          resourceIdentifierUri: resourceIdentifiers,
          buildConfigUri: buildConfig.configFile,
          assetsForLinking:
              previousBuildResult!.assetsForLinking[buildConfig.packageName] ??
                  [],
        ).toLinkConfig();
      } else {
        config = buildConfig;
      }

      final (buildOutput, packageSuccess) = await _buildPackageCached(
        step,
        config,
        packageLayout.packageConfigUri,
        workingDirectory,
        includeParentEnvironment,
        resourceIdentifiers,
      );
      buildResult.add(buildOutput);
      success &= packageSuccess;

      metadata[config.packageName] = buildOutput.metadata;
    }

    return buildResult.withSuccess(success);
  }

  /// [workingDirectory] is expected to contain `.dart_tool`.
  ///
  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// If provided, only native assets of all transitive dependencies of
  /// [runPackageName] are built.
  Future<BuildResult> dryRun({
    required LinkModePreferenceImpl linkModePreference,
    required OSImpl targetOS,
    required Uri workingDirectory,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    String? runPackageName,
    Iterable<String>? supportedAssetTypes,
  }) async {
    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);
    final packagesWithBuild = await packageLayout.packagesWithNativeAssets;
    final (buildPlan, _, planSuccess) = await _plannedPackages(
      packagesWithBuild,
      packageLayout,
      runPackageName,
    );
    final buildResult = _BuildResultImpl._failure();
    if (!planSuccess) {
      return buildResult;
    }
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
      final (buildOutput, packageSuccess) = await _buildPackage(
        PipelineStep.build,
        config,
        packageLayout.packageConfigUri,
        workingDirectory,
        includeParentEnvironment,
        null,
      );
      for (final asset in buildOutput.assets) {
        switch (asset) {
          case NativeCodeAssetImpl _:
            if (asset.architecture != null) {
              // Backwards compatibility, if an architecture is provided use it.
              buildResult.assets.add(asset);
            } else {
              // Dry run does not report architecture. Dart VM branches on OS
              // and Target when looking up assets, so populate assets for all
              // architectures.
              for (final architecture in asset.os.architectures) {
                buildResult.assets
                    .add(asset.copyWith(architecture: architecture));
              }
            }
          case DataAssetImpl _:
            buildResult.assets.add(asset);
        }
      }
      success &= packageSuccess;
    }
    return buildResult.withSuccess(success);
  }

  Future<_PackageBuildRecord> _buildPackageCached(
    PipelineStep step,
    PipelineConfigImpl config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment,
    Uri? resources,
  ) async {
    final outDir = config.outputDirectory;
    if (!await Directory.fromUri(outDir).exists()) {
      await Directory.fromUri(outDir).create(recursive: true);
    }

    final buildOutput = BuildOutputImpl.readFromFile(file: config.outputFile);
    if (buildOutput != null) {
      final lastBuilt = buildOutput.timestamp.roundDownToSeconds();
      final lastChange = await buildOutput.dependenciesModel.lastModified();

      if (lastBuilt.isAfter(lastChange)) {
        logger.info('Skipping build for ${config.packageName} in $outDir. '
            'Last build on $lastBuilt, last input change on $lastChange.');
        // All build flags go into [outDir]. Therefore we do not have to check
        // here whether the config is equal.
        return (buildOutput, true);
      }
    }

    return await _buildPackage(
      step,
      config,
      packageConfigUri,
      workingDirectory,
      includeParentEnvironment,
      resources,
    );
  }

  Future<_PackageBuildRecord> _buildPackage(
    PipelineStep step,
    PipelineConfigImpl config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment,
    Uri? resources,
  ) async {
    final configFile = config.configFile;
    final configFileContents = config.toJsonString();
    logger.info('config.json contents: $configFileContents');
    await File.fromUri(configFile).writeAsString(configFileContents);
    final buildOutputFile = File.fromUri(config.outputFile);
    if (await buildOutputFile.exists()) {
      // Ensure we'll never read outdated build results.
      await buildOutputFile.delete();
    }

    final arguments = [
      '--packages=${packageConfigUri.toFilePath()}',
      config.script.toFilePath(),
      '--config=${configFile.toFilePath()}',
      if (resources != null) resources.toFilePath(),
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
${config.script} returned with exit code: ${result.exitCode}.
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
      final buildOutput =
          BuildOutputImpl.readFromFile(file: config.outputFile) ??
              BuildOutputImpl();
      success &= validateAssetsPackage(
        buildOutput.assets,
        config.packageName,
      );
      return (buildOutput, success);
    } on FormatException catch (e) {
      logger.severe('''
Building native assets for package:${config.packageName} failed.
${config.outputName} contained a format error.
${e.message}
        ''');
      success = false;
      return (BuildOutputImpl(), false);
      // TODO(https://github.com/dart-lang/native/issues/109): Stop throwing
      // type errors in native_assets_cli, release a new version of that package
      // and then remove this.
      // ignore: avoid_catching_errors
    } on TypeError {
      logger.severe('''
Building native assets for package:${config.packageName} failed.
${config.outputName} contained a format error.
        ''');
      success = false;
      return (BuildOutputImpl(), false);
    } finally {
      if (!success) {
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

  bool validateAssetsPackage(Iterable<Asset> assets, String packageName) {
    final invalidAssetIds = assets
        .map((a) => a.id)
        .where((n) => !n.startsWith('package:$packageName/'))
        .toSet()
        .toList()
      ..sort();
    if (invalidAssetIds.isNotEmpty) {
      logger.severe(
        '`package:$packageName` declares the following assets which do not '
        'start with `package:$packageName/`: ${invalidAssetIds.join(', ')}.',
      );
      return false;
    } else {
      return true;
    }
  }

  Future<(List<Package> plan, PackageGraph dependencyGraph, bool success)>
      _plannedPackages(
    List<Package> packagesWithNativeAssets,
    PackageLayout packageLayout,
    String? runPackageName,
  ) async {
    if (packagesWithNativeAssets.length <= 1 && runPackageName == null) {
      final dependencyGraph = PackageGraph({
        for (final p in packagesWithNativeAssets) p.name: [],
      });
      return (packagesWithNativeAssets, dependencyGraph, true);
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
      return (plan, planner.packageGraph, planSuccess);
    }
  }
}

typedef _PackageBuildRecord = (BuildOutputImpl, bool success);

/// The result from a [NativeAssetsBuildRunner.build] or
/// [NativeAssetsBuildRunner.link].
abstract class BuildResult {
  /// All the files used for building the native assets of all packages.
  ///
  /// This aggregated list can be used to determine whether the
  /// [NativeAssetsBuildRunner] needs to be invoked again. The
  /// [NativeAssetsBuildRunner] determines per package with native assets
  /// if it needs to run the build again.
  List<Uri> get dependencies;

  bool get success;

  List<AssetImpl> get assets;

  Map<String, List<AssetImpl>> get assetsForLinking;
}

final class _BuildResultImpl implements BuildResult {
  @override
  final List<AssetImpl> assets;

  @override
  final Map<String, List<AssetImpl>> assetsForLinking;

  @override
  final List<Uri> dependencies;

  @override
  final bool success;

  _BuildResultImpl._({
    required this.assets,
    required this.assetsForLinking,
    required this.dependencies,
    required this.success,
  });

  _BuildResultImpl._failure()
      : this._(
          assets: [],
          assetsForLinking: {},
          dependencies: [],
          success: false,
        );

  void add(BuildOutputImpl buildOutput) {
    assets.addAll(buildOutput.assets);
    assetsForLinking.addAll(buildOutput.assetsForLinking);
    dependencies.addAll(buildOutput.dependencies);
    dependencies.sort(_uriCompare);
  }

  BuildResult withSuccess(bool success) => _BuildResultImpl._(
        assets: assets,
        assetsForLinking: assetsForLinking,
        dependencies: dependencies,
        success: success,
      );
}

extension on DateTime {
  DateTime roundDownToSeconds() =>
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch -
          millisecondsSinceEpoch % const Duration(seconds: 1).inMilliseconds);
}

int _uriCompare(Uri u1, Uri u2) => u1.toString().compareTo(u2.toString());
