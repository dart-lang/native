// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_builder/src/utils/file.dart';
import 'package:native_assets_builder/src/utils/uri.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:native_assets_cli/native_assets_cli.dart' as api;
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
///
/// The native assets build runner does not support reentrancy for identical
/// [api.BuildConfig] and [api.LinkConfig]! For more info see:
/// https://github.com/dart-lang/native/issues/1319
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
  ///
  /// The native assets build runner does not support reentrancy for identical
  /// [api.BuildConfig] and [api.LinkConfig]! For more info see:
  /// https://github.com/dart-lang/native/issues/1319
  Future<BuildResult> build({
    required LinkModePreferenceImpl linkModePreference,
    required Target target,
    required Uri workingDirectory,
    required BuildModeImpl buildMode,
    CCompilerConfigImpl? cCompilerConfig,
    IOSSdkImpl? targetIOSSdk,
    int? targetIOSVersion,
    int? targetMacOSVersion,
    int? targetAndroidNdkApi,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    String? runPackageName,
    Iterable<String>? supportedAssetTypes,
    required bool linkingEnabled,
  }) async =>
      _run(
        hook: Hook.build,
        linkModePreference: linkModePreference,
        target: target,
        workingDirectory: workingDirectory,
        buildMode: buildMode,
        cCompilerConfig: cCompilerConfig,
        targetIOSSdk: targetIOSSdk,
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
        targetAndroidNdkApi: targetAndroidNdkApi,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        runPackageName: runPackageName,
        supportedAssetTypes: supportedAssetTypes,
        linkingEnabled: linkingEnabled,
      );

  /// [workingDirectory] is expected to contain `.dart_tool`.
  ///
  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// If provided, only assets of all transitive dependencies of
  /// [runPackageName] are linked.
  ///
  /// The native assets build runner does not support reentrancy for identical
  /// [api.BuildConfig] and [api.LinkConfig]! For more info see:
  /// https://github.com/dart-lang/native/issues/1319
  Future<LinkResult> link({
    required LinkModePreferenceImpl linkModePreference,
    required Target target,
    required Uri workingDirectory,
    required BuildModeImpl buildMode,
    CCompilerConfigImpl? cCompilerConfig,
    IOSSdkImpl? targetIOSSdk,
    int? targetIOSVersion,
    int? targetMacOSVersion,
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
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
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
    int? targetIOSVersion,
    int? targetMacOSVersion,
    int? targetAndroidNdkApi,
    required bool includeParentEnvironment,
    PackageLayout? packageLayout,
    Uri? resourceIdentifiers,
    String? runPackageName,
    Iterable<String>? supportedAssetTypes,
    BuildResult? buildResult,
    bool? linkingEnabled,
  }) async {
    assert(hook == Hook.link || buildResult == null);
    assert(hook == Hook.build || linkingEnabled == null);

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
        linkingEnabled,
        cCompilerConfig,
        targetIOSSdk,
        targetAndroidNdkApi,
        targetIOSVersion,
        targetMacOSVersion,
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
    bool? linkingEnabled,
    CCompilerConfigImpl? cCompilerConfig,
    IOSSdkImpl? targetIOSSdk,
    int? targetAndroidNdkApi,
    int? targetIOSVersion,
    int? targetMacOSVersion,
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
      linkingEnabled: linkingEnabled,
    );
    final buildDirUri =
        packageLayout.dartToolNativeAssetsBuilder.resolve('$buildDirName/');
    final outDirUri = buildDirUri.resolve('out/');
    final outDir = Directory.fromUri(outDirUri);
    if (!await outDir.exists()) {
      // TODO(https://dartbug.com/50565): Purge old or unused folders.
      await outDir.create(recursive: true);
    }

    if (hook == Hook.link) {
      File? resourcesFile;
      if (resourceIdentifiers != null) {
        resourcesFile = File.fromUri(buildDirUri.resolve('resources.json'));
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
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
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
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
        cCompiler: cCompilerConfig,
        dependencyMetadata: dependencyMetadata,
        linkingEnabled: linkingEnabled,
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
    required bool linkingEnabled,
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
        linkingEnabled: linkingEnabled,
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
        linkingEnabled: null,
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
    required bool? linkingEnabled,
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
        package: package,
        packageName: package.name,
        packageRoot: packageLayout.packageRoot(package.name),
        targetOS: targetOS,
        linkMode: linkModePreference,
        buildParentDir: packageLayout.dartToolNativeAssetsBuilder,
        supportedAssetTypes: supportedAssetTypes,
        hook: hook,
        buildDryRunResult: buildDryRunResult,
        linkingEnabled: linkingEnabled,
      );
      final packageConfigUri = packageLayout.packageConfigUri;
      final (
        compileSuccess,
        hookKernelFile,
        _,
      ) = await _compileHookForPackageCached(
        config,
        packageConfigUri,
        workingDirectory,
        includeParentEnvironment,
      );
      if (!compileSuccess) {
        hookResult.copyAdd(HookOutputImpl(), false);
        continue;
      }
      // TODO(https://github.com/dart-lang/native/issues/1321): Should dry runs be cached?
      var (buildOutput, packageSuccess) = await _runHookForPackage(
        hook,
        config,
        packageConfigUri,
        workingDirectory,
        includeParentEnvironment,
        null,
        hookKernelFile,
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
    final (
      compileSuccess,
      hookKernelFile,
      hookLastSourceChange,
    ) = await _compileHookForPackageCached(
      config,
      packageConfigUri,
      workingDirectory,
      includeParentEnvironment,
    );
    if (!compileSuccess) {
      return (HookOutputImpl(), false);
    }

    final hookOutput = HookOutputImpl.readFromFile(file: config.outputFile);
    if (hookOutput != null) {
      final lastBuilt = hookOutput.timestamp.roundDownToSeconds();
      final dependenciesLastChange =
          await hookOutput.dependenciesModel.lastModified();
      if (lastBuilt.isAfter(dependenciesLastChange) &&
          lastBuilt.isAfter(hookLastSourceChange)) {
        logger.info(
          'Skipping ${hook.name} for ${config.packageName} in $outDir. '
          'Last build on $lastBuilt. '
          'Last dependencies change on $dependenciesLastChange. '
          'Last hook change on $hookLastSourceChange.',
        );
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
      hookKernelFile,
    );
  }

  Future<_PackageBuildRecord> _runHookForPackage(
    Hook hook,
    HookConfigImpl config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment,
    Uri? resources,
    File hookKernelFile,
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
      hookKernelFile.path,
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

  /// Compiles the hook to dill and caches the dill.
  ///
  /// It does not reuse the cached dill for different [config]s, due to
  /// reentrancy requirements. For more info see:
  /// https://github.com/dart-lang/native/issues/1319
  Future<(bool success, File kernelFile, DateTime lastSourceChange)>
      _compileHookForPackageCached(
    HookConfigImpl config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment,
  ) async {
    final kernelFile = File.fromUri(
      config.outputDirectory.resolve('../hook.dill'),
    );
    final depFile = File.fromUri(
      config.outputDirectory.resolve('../hook.dill.d'),
    );
    final bool mustCompile;
    final DateTime sourceLastChange;
    if (!await depFile.exists()) {
      mustCompile = true;
      sourceLastChange = DateTime.now();
    } else {
      final depFileContents = await depFile.readAsString();
      final dartSourceFiles = depFileContents
          .trim()
          .split(' ')
          .skip(1) // '<dill>:'
          .map((u) => Uri.file(u).fileSystemEntity)
          .toList();
      final dartFilesLastChange = await dartSourceFiles.lastModified();
      final packageConfigLastChange =
          await packageConfigUri.fileSystemEntity.lastModified();
      sourceLastChange = packageConfigLastChange.isAfter(dartFilesLastChange)
          ? packageConfigLastChange
          : dartFilesLastChange;
      final dillLastChange = await kernelFile.lastModified();
      mustCompile = sourceLastChange.isAfter(dillLastChange);
    }
    final bool success;
    if (!mustCompile) {
      success = true;
    } else {
      success = await _compileHookForPackage(
        config,
        packageConfigUri,
        workingDirectory,
        includeParentEnvironment,
        kernelFile,
        depFile,
      );
    }
    return (success, kernelFile, sourceLastChange);
  }

  Future<bool> _compileHookForPackage(
    HookConfigImpl config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment,
    File kernelFile,
    File depFile,
  ) async {
    final compileArguments = [
      'compile',
      'kernel',
      '--packages=${packageConfigUri.toFilePath()}',
      '--output=${kernelFile.path}',
      '--depfile=${depFile.path}',
      config.script.toFilePath(),
    ];
    final compileResult = await runProcess(
      workingDirectory: workingDirectory,
      executable: dartExecutable,
      arguments: compileArguments,
      logger: logger,
      includeParentEnvironment: includeParentEnvironment,
    );
    var success = true;
    if (compileResult.exitCode != 0) {
      final printWorkingDir = workingDirectory != Directory.current.uri;
      final commandString = [
        if (printWorkingDir) '(cd ${workingDirectory.toFilePath()};',
        dartExecutable.toFilePath(),
        ...compileArguments.map((a) => a.contains(' ') ? "'$a'" : a),
        if (printWorkingDir) ')',
      ].join(' ');
      logger.severe(
        '''
Building native assets for package:${config.packageName} failed.
Compilation of hook returned with exit code: ${compileResult.exitCode}.
To reproduce run:
$commandString
stderr:
${compileResult.stderr}
stdout:
${compileResult.stdout}
        ''',
      );
      success = false;
    }
    return success;
  }

  static Future<HookConfigImpl> _cliConfigDryRun({
    required Package package,
    required String packageName,
    required Uri packageRoot,
    required OSImpl targetOS,
    required LinkModePreferenceImpl linkMode,
    required Uri buildParentDir,
    required Hook hook,
    BuildDryRunResult? buildDryRunResult,
    Iterable<String>? supportedAssetTypes,
    required bool? linkingEnabled,
  }) async {
    final buildDirName = HookConfigImpl.checksumDryRun(
      packageName: package.name,
      packageRoot: package.root,
      targetOS: targetOS,
      linkModePreference: linkMode,
      supportedAssetTypes: supportedAssetTypes,
      hook: hook,
      linkingEnabled: linkingEnabled,
    );
    final outDirUri = buildParentDir.resolve('$buildDirName/out/');
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
          linkingEnabled: linkingEnabled,
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
