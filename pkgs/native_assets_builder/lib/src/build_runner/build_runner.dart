// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:package_config/package_config.dart';

import '../model/build_dry_run_result.dart';
import '../model/build_result.dart';
import '../model/hook_result.dart';
import '../model/link_dry_run_result.dart';
import '../model/link_result.dart';
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
  /// If provided, only assets of all transitive dependencies of
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
        hook: Hook.build,
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

  /// [workingDirectory] is expected to contain `.dart_tool`.
  ///
  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// If provided, only assets of all transitive dependencies of
  /// [runPackageName] are linked.
  Future<LinkResult> link({
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
    required BuildResult buildResult,
  }) async =>
      _run(
        hook: Hook.link,
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
        resourceIdentifiers: resourceIdentifiers,
        supportedAssetTypes: supportedAssetTypes,
        buildResult: buildResult,
      );

  /// The common method for running building or linking of assets.
  Future<HookResult> _run({
    required Hook hook,
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
    BuildResult? buildResult,
  }) async {
    assert(hook == Hook.link || buildResult == null);

    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);
    final (buildPlan, packageGraph, planSuccess) = await _makePlan(
      hook: hook,
      packageLayout: packageLayout,
      buildResult: buildResult,
      runPackageName: runPackageName,
    );
    if (!planSuccess) {
      return HookResult.failure();
    }

    var hookResult = HookResult();
    final metadata = <String, Metadata>{};
    for (final package in buildPlan) {
      final DependencyMetadata? dependencyMetadata;
      switch (hook) {
        case Hook.build:
          dependencyMetadata = _metadataForPackage(
            packageGraph: packageGraph!,
            packageName: package.name,
            targetMetadata: metadata,
          );
        case Hook.link:
          dependencyMetadata = null;
      }
      final config = await _cliConfig(
        package,
        packageLayout,
        target,
        buildMode,
        linkModePreference,
        dependencyMetadata,
        cCompilerConfig,
        targetIOSSdk,
        targetAndroidNdkApi,
        supportedAssetTypes,
        hook,
        resourceIdentifiers,
        buildResult,
      );

      final (hookOutput, packageSuccess) = await _runHookForPackageCached(
        hook,
        config,
        packageLayout.packageConfigUri,
        workingDirectory,
        includeParentEnvironment,
        resourceIdentifiers,
      );
      hookResult = hookResult.copyAdd(hookOutput, packageSuccess);
      metadata[config.packageName] = hookOutput.metadata;
    }

    return hookResult;
  }

  static Future<HookConfigImpl> _cliConfig(
    Package package,
    PackageLayout packageLayout,
    Target target,
    BuildModeImpl buildMode,
    LinkModePreferenceImpl linkModePreference,
    DependencyMetadata? dependencyMetadata,
    CCompilerConfigImpl? cCompilerConfig,
    IOSSdkImpl? targetIOSSdk,
    int? targetAndroidNdkApi,
    Iterable<String>? supportedAssetTypes,
    Hook hook,
    Uri? resourceIdentifiers,
    BuildResult? buildResult,
  ) async {
    final buildDirName = HookConfigImpl.checksum(
      packageName: package.name,
      packageRoot: package.root,
      targetOS: target.os,
      targetArchitecture: target.architecture,
      buildMode: buildMode,
      linkModePreference: linkModePreference,
      targetIOSSdk: targetIOSSdk,
      cCompiler: cCompilerConfig,
      dependencyMetadata: dependencyMetadata,
      targetAndroidNdkApi: targetAndroidNdkApi,
      supportedAssetTypes: supportedAssetTypes,
      hook: hook,
    );
    final outDirUri =
        packageLayout.dartToolNativeAssetsBuilder.resolve('$buildDirName/out/');
    final outDir = Directory.fromUri(outDirUri);
    if (!await outDir.exists()) {
      // TODO(https://dartbug.com/50565): Purge old or unused folders.
      await outDir.create(recursive: true);
    }

    if (hook == Hook.link) {
      File? resourcesFile;
      if (resourceIdentifiers != null) {
        resourcesFile = File.fromUri(outDirUri.resolve('resources.json'));
        await resourcesFile.create();
        await File.fromUri(resourceIdentifiers).copy(resourcesFile.path);
      }

      return LinkConfigImpl(
        outputDirectory: outDirUri,
        packageName: package.name,
        packageRoot: package.root,
        targetOS: target.os,
        targetArchitecture: target.architecture,
        buildMode: buildMode,
        targetIOSSdk: targetIOSSdk,
        cCompiler: cCompilerConfig,
        targetAndroidNdkApi: targetAndroidNdkApi,
        resourceIdentifierUri: resourcesFile?.uri,
        assets: buildResult!.assetsForLinking[package.name] ?? [],
        supportedAssetTypes: supportedAssetTypes,
        linkModePreference: linkModePreference,
      );
    } else {
      return BuildConfigImpl(
        outputDirectory: outDirUri,
        packageName: package.name,
        packageRoot: package.root,
        targetOS: target.os,
        targetArchitecture: target.architecture,
        buildMode: buildMode,
        linkModePreference: linkModePreference,
        targetIOSSdk: targetIOSSdk,
        cCompiler: cCompilerConfig,
        dependencyMetadata: dependencyMetadata,
        targetAndroidNdkApi: targetAndroidNdkApi,
      );
    }
  }

  /// [workingDirectory] is expected to contain `.dart_tool`.
  ///
  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// If provided, only native assets of all transitive dependencies of
  /// [runPackageName] are built.
  Future<BuildDryRunResult> buildDryRun({
    required LinkModePreferenceImpl linkModePreference,
    required OSImpl targetOS,
    required Uri workingDirectory,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    String? runPackageName,
    Iterable<String>? supportedAssetTypes,
  }) =>
      _runDryRun(
        hook: Hook.build,
        linkModePreference: linkModePreference,
        targetOS: targetOS,
        workingDirectory: workingDirectory,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        runPackageName: runPackageName,
        supportedAssetTypes: supportedAssetTypes,
      );

  /// [workingDirectory] is expected to contain `.dart_tool`.
  ///
  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// If provided, only native assets of all transitive dependencies of
  /// [runPackageName] are built.
  Future<LinkDryRunResult> linkDryRun({
    required LinkModePreferenceImpl linkModePreference,
    required OSImpl targetOS,
    required Uri workingDirectory,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    String? runPackageName,
    Iterable<String>? supportedAssetTypes,
    required BuildDryRunResult buildDryRunResult,
  }) =>
      _runDryRun(
        hook: Hook.link,
        linkModePreference: linkModePreference,
        targetOS: targetOS,
        workingDirectory: workingDirectory,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        runPackageName: runPackageName,
        supportedAssetTypes: supportedAssetTypes,
        buildDryRunResult: buildDryRunResult,
      );

  Future<HookResult> _runDryRun({
    required LinkModePreferenceImpl linkModePreference,
    required OSImpl targetOS,
    required Uri workingDirectory,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    String? runPackageName,
    Iterable<String>? supportedAssetTypes,
    required Hook hook,
    BuildDryRunResult? buildDryRunResult,
  }) async {
    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);
    final (buildPlan, _, planSuccess) = await _makePlan(
      hook: hook,
      packageLayout: packageLayout,
      buildDryRunResult: buildDryRunResult,
      runPackageName: runPackageName,
    );
    if (!planSuccess) {
      return HookResult.failure();
    }

    var hookResult = HookResult();
    for (final package in buildPlan) {
      final config = await _cliConfigDryRun(
        packageName: package.name,
        packageRoot: packageLayout.packageRoot(package.name),
        targetOS: targetOS,
        linkMode: linkModePreference,
        buildParentDir: packageLayout.dartToolNativeAssetsBuilder,
        supportedAssetTypes: supportedAssetTypes,
        hook: hook,
        buildDryRunResult: buildDryRunResult,
      );
      var (buildOutput, packageSuccess) = await _runHookForPackage(
        hook,
        config,
        packageLayout.packageConfigUri,
        workingDirectory,
        includeParentEnvironment,
        null,
      );
      buildOutput = _expandArchsNativeCodeAssets(buildOutput);
      hookResult = hookResult.copyAdd(buildOutput, packageSuccess);
    }
    return hookResult;
  }

  HookOutputImpl _expandArchsNativeCodeAssets(HookOutputImpl buildOutput) {
    final assets = <AssetImpl>[];
    for (final asset in buildOutput.assets) {
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
              assets.add(asset.copyWith(architecture: architecture));
            }
          }
        case DataAssetImpl _:
          assets.add(asset);
      }
    }
    return buildOutput.copyWith(assets: assets);
  }

  Future<_PackageBuildRecord> _runHookForPackageCached(
    Hook hook,
    HookConfigImpl config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment,
    Uri? resources,
  ) async {
    final outDir = config.outputDirectory;

    final hookOutput = HookOutputImpl.readFromFile(file: config.outputFile);
    if (hookOutput != null) {
      final lastBuilt = hookOutput.timestamp.roundDownToSeconds();
      final lastChange = await hookOutput.dependenciesModel.lastModified();

      if (lastBuilt.isAfter(lastChange)) {
        logger
            .info('Skipping ${hook.name} for ${config.packageName} in $outDir. '
                'Last build on $lastBuilt, last input change on $lastChange.');
        // All build flags go into [outDir]. Therefore we do not have to check
        // here whether the config is equal.
        return (hookOutput, true);
      }
    }

    return await _runHookForPackage(
      hook,
      config,
      packageConfigUri,
      workingDirectory,
      includeParentEnvironment,
      resources,
    );
  }

  Future<_PackageBuildRecord> _runHookForPackage(
    Hook hook,
    HookConfigImpl config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment,
    Uri? resources,
  ) async {
    final configFile = config.outputDirectory.resolve('../config.json');
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
      final buildOutput = HookOutputImpl.readFromFile(
              file: config.outputFile) ??
          (config.outputFileV1_1_0 == null
              ? null
              : HookOutputImpl.readFromFile(file: config.outputFileV1_1_0!)) ??
          HookOutputImpl();
      // The link.dart can pipe through assets from other packages.
      if (hook == Hook.build) {
        success &= validateAssetsPackage(
          buildOutput.assets,
          config.packageName,
        );
      }
      return (buildOutput, success);
    } on FormatException catch (e) {
      logger.severe('''
Building native assets for package:${config.packageName} failed.
${config.outputName} contained a format error.

Contents: ${File.fromUri(config.outputFile).readAsStringSync()}.
${e.message}
        ''');
      success = false;
      return (HookOutputImpl(), false);
    } finally {
      if (!success) {
        if (await buildOutputFile.exists()) {
          await buildOutputFile.delete();
        }
      }
    }
  }

  static Future<HookConfigImpl> _cliConfigDryRun({
    required String packageName,
    required Uri packageRoot,
    required OSImpl targetOS,
    required LinkModePreferenceImpl linkMode,
    required Uri buildParentDir,
    required Hook hook,
    BuildDryRunResult? buildDryRunResult,
    Iterable<String>? supportedAssetTypes,
  }) async {
    final hookDirName = 'dry_run_${hook.name}_${targetOS}_$linkMode';
    final outDirUri = buildParentDir.resolve('$hookDirName/out/');
    final outDir = Directory.fromUri(outDirUri);
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }
    switch (hook) {
      case Hook.build:
        return BuildConfigImpl.dryRun(
          outputDirectory: outDirUri,
          packageName: packageName,
          packageRoot: packageRoot,
          targetOS: targetOS,
          linkModePreference: linkMode,
          supportedAssetTypes: supportedAssetTypes,
        );
      case Hook.link:
        return LinkConfigImpl.dryRun(
          outputDirectory: outDirUri,
          packageName: packageName,
          packageRoot: packageRoot,
          targetOS: targetOS,
          assets: buildDryRunResult!.assetsForLinking[packageName] ?? [],
          supportedAssetTypes: supportedAssetTypes,
          linkModePreference: linkMode,
        );
    }
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
        .where((id) => !id.startsWith('package:$packageName/'))
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

  Future<(List<Package> plan, PackageGraph? dependencyGraph, bool success)>
      _makePlan({
    required PackageLayout packageLayout,
    String? runPackageName,
    required Hook hook,
    // TODO(dacoharkes): How to share these two? Make them extend each other?
    BuildResult? buildResult,
    BuildDryRunResult? buildDryRunResult,
  }) async {
    final packagesWithHook = await packageLayout.packagesWithAssets(hook);
    final List<Package> buildPlan;
    final PackageGraph? packageGraph;
    switch (hook) {
      case Hook.build:
        // Build hooks are run in toplogical order.
        if (packagesWithHook.length <= 1 && runPackageName == null) {
          final dependencyGraph = PackageGraph({
            for (final p in packagesWithHook) p.name: [],
          });
          return (packagesWithHook, dependencyGraph, true);
        } else {
          final planner = await NativeAssetsBuildPlanner.fromRootPackageRoot(
            rootPackageRoot: packageLayout.rootPackageRoot,
            packagesWithNativeAssets: packagesWithHook,
            dartExecutable: Uri.file(Platform.resolvedExecutable),
            logger: logger,
          );
          final (plan, planSuccess) = planner.plan(
            runPackageName: runPackageName,
          );
          return (plan, planner.packageGraph, planSuccess);
        }
      case Hook.link:
        // Link hooks are not run in any particular order.
        // Link hooks are skipped if no assets for linking are provided.
        buildPlan = [];
        final skipped = <String>[];
        final assetsForLinking = buildResult?.assetsForLinking ??
            buildDryRunResult?.assetsForLinking;
        for (final package in packagesWithHook) {
          if (assetsForLinking![package.name]?.isNotEmpty ?? false) {
            buildPlan.add(package);
          } else {
            skipped.add(package.name);
          }
        }
        if (skipped.isNotEmpty) {
          logger.info(
            'Skipping link hooks from ${skipped.join(', ')}'
            ' due to no assets provided to link for these link hooks.',
          );
        }
        packageGraph = null;
    }
    return (buildPlan, packageGraph, true);
  }
}

typedef _PackageBuildRecord = (HookOutputImpl, bool success);

extension on DateTime {
  DateTime roundDownToSeconds() =>
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch -
          millisecondsSinceEpoch % const Duration(seconds: 1).inMilliseconds);
}
