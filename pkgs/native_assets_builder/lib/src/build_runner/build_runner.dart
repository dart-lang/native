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
    required LinkModePreference linkModePreference,
    required Target target,
    required Uri workingDirectory,
    required BuildMode buildMode,
    CCompilerConfig? cCompilerConfig,
    IOSSdk? targetIOSSdk,
    int? targetAndroidNdkApi,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    String? runPackageName,
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
      );

  Future<BuildResult> link({
    required Target target,
    required Uri workingDirectory,
    required BuildMode buildMode,
    CCompilerConfig? cCompilerConfig,
    IOSSdk? targetIOSSdk,
    int? targetAndroidNdkApi,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    Uri? resourceIdentifiers,
    String? runPackageName,
  }) async =>
      _run(
        step: PipelineStep.link,
        linkModePreference: LinkModePreference.dynamic,
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
      );

  Future<BuildResult> _run({
    required PipelineStep step,
    required LinkModePreference linkModePreference,
    required Target target,
    required Uri workingDirectory,
    required BuildMode buildMode,
    CCompilerConfig? cCompilerConfig,
    IOSSdk? targetIOSSdk,
    int? targetAndroidNdkApi,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    Uri? resourceIdentifiers,
    String? runPackageName,
  }) async {
    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);
    final packagesWithBuild =
        await packageLayout.packagesWithNativeAssets(step);
    final packagesWithLink = await packageLayout.packagesWithLink(step);
    final (buildPlan, packageGraph, planSuccess) = await _plannedPackages(
        packagesWithBuild, packageLayout, runPackageName);
    final buildResult = BuildResult._failure();
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
      );
      final PipelineConfig config;
      if (step == PipelineStep.link) {
        config = await LinkConfigArgs(
          resourceIdentifierUri: resourceIdentifiers,
          buildConfigUri: buildConfig.configFile,
        ).fromArgs();
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
      buildResult.add(buildOutput, !packagesWithLink.contains(package));
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
  Future<BuildResult> dryBuild({
    required LinkModePreference linkModePreference,
    required OS targetOs,
    required Uri workingDirectory,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    String? runPackageName,
  }) async {
    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);
    final packagesWithBuild = await packageLayout.packagesWithNativeBuild;
    final (buildPlan, _, planSuccess) = await _plannedPackages(
      packagesWithBuild,
      packageLayout,
      runPackageName,
    );
    final buildResult = BuildResult._failure();
    if (!planSuccess) {
      return buildResult;
    }
    var success = true;
    for (final package in buildPlan) {
      final config = await _cliConfigDryRun(
        packageName: package.name,
        packageRoot: packageLayout.packageRoot(package.name),
        targetOs: targetOs,
        linkMode: linkModePreference,
        buildParentDir: packageLayout.dartToolNativeAssetsBuilder,
      );
      final (buildOutput, packageSuccess) = await _buildPackage(
        PipelineStep.build,
        config,
        packageLayout.packageConfigUri,
        workingDirectory,
        includeParentEnvironment,
        null,
      );
      buildResult.add(buildOutput, true);
      success &= packageSuccess;
    }
    return buildResult.withSuccess(success);
  }

  Future<_PackageBuildRecord> _buildPackageCached(
    PipelineStep step,
    PipelineConfig config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment,
    Uri? resources,
  ) async {
    final outDir = config.outDir;
    if (!await Directory.fromUri(outDir).exists()) {
      await Directory.fromUri(outDir).create(recursive: true);
    }

    final buildOutput =
        await BuildOutput.readFromFile(outputUri: config.output);
    if (buildOutput != null) {
      final lastBuilt = buildOutput.timestamp.roundDownToSeconds();
      final lastChange = await buildOutput.dependencies.lastModified();

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
    PipelineConfig config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment,
    Uri? resources,
  ) async {
    final configFile = config.configFile;
    final configFileContents = config.toYamlString();
    logger.info('config.yaml contents: $configFileContents');
    await File.fromUri(configFile).writeAsString(configFileContents);
    final buildOutputFile = File.fromUri(config.output);
    if (await buildOutputFile.exists()) {
      // Ensure we'll never read outdated build results.
      await buildOutputFile.delete();
    }

    final arguments = [
      '--packages=${packageConfigUri.toFilePath()}',
      config.script.toFilePath(),
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
          await BuildOutput.readFromFile(outputUri: config.output) ??
              BuildOutput();
      success &= validateAssetsPackage(
        buildOutput.assets,
        config.packageName,
      );
      return (buildOutput, success);
    } on FormatException catch (e) {
      logger.severe('''
Building native assets for package:${config.packageName} failed.
build_output.yaml contained a format error.
${e.message}
        ''');
      success = false;
      return (BuildOutput(), false);
      // TODO(https://github.com/dart-lang/native/issues/109): Stop throwing
      // type errors in native_assets_cli, release a new version of that package
      // and then remove this.
      // ignore: avoid_catching_errors
    } on TypeError {
      logger.severe('''
Building native assets for package:${config.packageName} failed.
build_output.yaml contained a format error.
        ''');
      success = false;
      return (BuildOutput(), false);
    } finally {
      if (!success) {
        if (await buildOutputFile.exists()) {
          await buildOutputFile.delete();
        }
      }
    }
  }

  static Future<BuildConfig> _cliConfig({
    required String packageName,
    required Uri packageRoot,
    required Target target,
    IOSSdk? targetIOSSdk,
    int? targetAndroidNdkApi,
    required BuildMode buildMode,
    required LinkModePreference linkMode,
    required Uri buildParentDir,
    CCompilerConfig? cCompilerConfig,
    DependencyMetadata? dependencyMetadata,
  }) async {
    final buildDirName = BuildConfig.checksum(
      packageName: packageName,
      packageRoot: packageRoot,
      targetOs: target.os,
      targetArchitecture: target.architecture,
      buildMode: buildMode,
      linkModePreference: linkMode,
      targetIOSSdk: targetIOSSdk,
      cCompiler: cCompilerConfig,
      dependencyMetadata: dependencyMetadata,
      targetAndroidNdkApi: targetAndroidNdkApi,
    );
    final outDirUri = buildParentDir.resolve('$buildDirName/out/');
    final outDir = Directory.fromUri(outDirUri);
    if (!await outDir.exists()) {
      // TODO(https://dartbug.com/50565): Purge old or unused folders.
      await outDir.create(recursive: true);
    }
    return BuildConfig(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: packageRoot,
      targetOs: target.os,
      targetArchitecture: target.architecture,
      buildMode: buildMode,
      linkModePreference: linkMode,
      targetIOSSdk: targetIOSSdk,
      cCompiler: cCompilerConfig,
      dependencyMetadata: dependencyMetadata,
      targetAndroidNdkApi: targetAndroidNdkApi,
    );
  }

  static Future<BuildConfig> _cliConfigDryRun({
    required String packageName,
    required Uri packageRoot,
    required OS targetOs,
    required LinkModePreference linkMode,
    required Uri buildParentDir,
  }) async {
    final buildDirName = 'dry_run_${targetOs}_$linkMode';
    final outDirUri = buildParentDir.resolve('$buildDirName/out/');
    final outDir = Directory.fromUri(outDirUri);
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }
    return BuildConfig.dryRun(
      outDir: outDirUri,
      packageName: packageName,
      packageRoot: packageRoot,
      targetOs: targetOs,
      linkModePreference: linkMode,
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

  bool validateAssetsPackage(List<Asset> assets, String packageName) {
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

typedef _PackageBuildRecord = (BuildOutput, bool success);

/// The result from a [NativeAssetsBuildRunner.build] or
/// [NativeAssetsBuildRunner.link].
final class BuildResult {
  /// All the files used for building the native assets of all packages.
  ///
  /// This aggregated list can be used to determine whether the
  /// [NativeAssetsBuildRunner] needs to be invoked again. The
  /// [NativeAssetsBuildRunner] determines per package with native assets
  /// if it needs to run the build again.
  final List<Uri> dependencies;

  final List<Asset> assets;

  final bool success;

  BuildResult._({
    required this.assets,
    required this.dependencies,
    required this.success,
  });

  BuildResult._failure()
      : this._(
          assets: [],
          dependencies: [],
          success: false,
        );

  void add(BuildOutput buildOutput, bool shouldCopy) {
    assets.addAll(buildOutput.assets.map((e) => e.copyWith(copy: shouldCopy)));
    dependencies.addAll(buildOutput.dependencies.dependencies);
    dependencies.sort(_uriCompare);
  }

  BuildResult withSuccess(bool success) => BuildResult._(
        assets: assets,
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
