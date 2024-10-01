// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart' as api;
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:package_config/package_config.dart';

import '../locking/locking.dart';
import '../model/build_dry_run_result.dart';
import '../model/build_result.dart';
import '../model/hook_result.dart';
import '../model/link_result.dart';
import '../package_layout/package_layout.dart';
import '../utils/file.dart';
import '../utils/run_process.dart';
import '../utils/uri.dart';
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
  final Duration singleHookTimeout;

  NativeAssetsBuildRunner({
    required this.logger,
    required this.dartExecutable,
    Duration? singleHookTimeout,
  }) : singleHookTimeout = singleHookTimeout ?? const Duration(minutes: 5);

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
    required LinkModePreference linkModePreference,
    required Target target,
    required Uri workingDirectory,
    required BuildMode buildMode,
    CCompilerConfig? cCompilerConfig,
    IOSSdk? targetIOSSdk,
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
    required LinkModePreference linkModePreference,
    required Target target,
    required Uri workingDirectory,
    required BuildMode buildMode,
    CCompilerConfig? cCompilerConfig,
    IOSSdk? targetIOSSdk,
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
    required LinkModePreference linkModePreference,
    required Target target,
    required Uri workingDirectory,
    required BuildMode buildMode,
    CCompilerConfig? cCompilerConfig,
    IOSSdk? targetIOSSdk,
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

    // Specifically for running our tests on Dart CI with the test runner, we
    // recognize specific variables to setup the C Compiler configuration.
    if (cCompilerConfig == null) {
      final env = Platform.environment;
      final cc = env['DART_HOOK_TESTING_C_COMPILER__CC'];
      final ar = env['DART_HOOK_TESTING_C_COMPILER__AR'];
      final ld = env['DART_HOOK_TESTING_C_COMPILER__LD'];
      final envScript = env['DART_HOOK_TESTING_C_COMPILER__ENV_SCRIPT'];
      final envScriptArgs =
          env['DART_HOOK_TESTING_C_COMPILER__ENV_SCRIPT_ARGUMENTS']
              ?.split(' ')
              .map((arg) => arg.trim())
              .where((arg) => arg.isNotEmpty)
              .toList();
      final hasEnvScriptArgs =
          envScriptArgs != null && envScriptArgs.isNotEmpty;

      if (cc != null ||
          ar != null ||
          ld != null ||
          envScript != null ||
          hasEnvScriptArgs) {
        cCompilerConfig = CCompilerConfig(
          archiver: ar != null ? Uri.file(ar) : null,
          compiler: cc != null ? Uri.file(cc) : null,
          envScript: envScript != null ? Uri.file(envScript) : null,
          envScriptArgs: hasEnvScriptArgs ? envScriptArgs : null,
          linker: ld != null ? Uri.file(ld) : null,
        );
      }
    }

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
        packageLayout,
      );
      hookResult = hookResult.copyAdd(hookOutput, packageSuccess);
      metadata[config.packageName] = hookOutput.metadata;
    }

    // Note the caller will need to check whether there are no duplicates
    // between the build and link hook.
    final validateResult = validateNoDuplicateDylibs(hookResult.assets);
    if (validateResult.isNotEmpty) {
      for (final error in validateResult) {
        logger.severe(error);
      }
      hookResult = hookResult.copyAdd(HookOutputImpl(), false);
    }

    return hookResult;
  }

  static Future<HookConfigImpl> _cliConfig(
    Package package,
    PackageLayout packageLayout,
    Target target,
    BuildMode buildMode,
    LinkModePreference linkModePreference,
    DependencyMetadata? dependencyMetadata,
    bool? linkingEnabled,
    CCompilerConfig? cCompilerConfig,
    IOSSdk? targetIOSSdk,
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
    final outputDirectory = buildDirUri.resolve('out/');
    final outDir = Directory.fromUri(outputDirectory);
    if (!await outDir.exists()) {
      // TODO(https://dartbug.com/50565): Purge old or unused folders.
      await outDir.create(recursive: true);
    }

    final outputDirectoryShared = packageLayout.dartToolNativeAssetsBuilder
        .resolve('shared/${package.name}/$hook/');
    final outDirShared = Directory.fromUri(outputDirectoryShared);
    if (!await outDirShared.exists()) {
      // TODO(https://dartbug.com/50565): Purge old or unused folders.
      await outDirShared.create(recursive: true);
    }

    if (hook == Hook.link) {
      File? resourcesFile;
      if (resourceIdentifiers != null) {
        resourcesFile = File.fromUri(buildDirUri.resolve('resources.json'));
        await resourcesFile.create();
        await File.fromUri(resourceIdentifiers).copy(resourcesFile.path);
      }

      return LinkConfigImpl(
        outputDirectory: outputDirectory,
        outputDirectoryShared: outputDirectoryShared,
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
        recordedUsagesFile: resourcesFile?.uri,
        assets: buildResult!.assetsForLinking[package.name] ?? [],
        supportedAssetTypes: supportedAssetTypes,
        linkModePreference: linkModePreference,
      );
    } else {
      return BuildConfigImpl(
        outputDirectory: outputDirectory,
        outputDirectoryShared: outputDirectoryShared,
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
        supportedAssetTypes: supportedAssetTypes,
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
    required LinkModePreference linkModePreference,
    required OS targetOS,
    required Uri workingDirectory,
    required bool includeParentEnvironment,
    required bool linkingEnabled,
    PackageLayout? packageLayout,
    String? runPackageName,
    Iterable<String>? supportedAssetTypes,
  }) async {
    const hook = Hook.build;
    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);
    final (buildPlan, _, planSuccess) = await _makePlan(
      hook: hook,
      packageLayout: packageLayout,
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
      var (buildOutput, packageSuccess) = await runUnderDirectoriesLock(
        [
          Directory.fromUri(config.outputDirectoryShared.parent),
          Directory.fromUri(config.outputDirectory.parent),
        ],
        timeout: singleHookTimeout,
        logger: logger,
        () => _runHookForPackage(
          hook,
          config,
          packageConfigUri,
          workingDirectory,
          includeParentEnvironment,
          null,
          hookKernelFile,
          packageLayout!,
        ),
      );
      buildOutput = _expandArchsCodeAssets(buildOutput);
      hookResult = hookResult.copyAdd(buildOutput, packageSuccess);
    }
    return hookResult;
  }

  HookOutputImpl _expandArchsCodeAssets(HookOutputImpl buildOutput) {
    final assets = <Asset>[];
    for (final asset in buildOutput.assets) {
      switch (asset) {
        case CodeAsset _:
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
        case DataAsset _:
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
    PackageLayout packageLayout,
  ) async {
    final outDir = config.outputDirectory;
    return await runUnderDirectoriesLock(
      [
        Directory.fromUri(config.outputDirectoryShared.parent),
        Directory.fromUri(config.outputDirectory.parent),
      ],
      timeout: singleHookTimeout,
      logger: logger,
      () async {
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
          late final DateTime assetsLastChange;
          if (hook == Hook.link) {
            assetsLastChange = await (config as LinkConfigImpl)
                .assets
                .map((a) => a.file)
                .whereType<Uri>()
                .map((u) => u.fileSystemEntity)
                .lastModified();
          }
          if (lastBuilt.isAfter(dependenciesLastChange) &&
              lastBuilt.isAfter(hookLastSourceChange) &&
              (hook == Hook.build || lastBuilt.isAfter(assetsLastChange))) {
            logger.info(
              [
                'Skipping ${hook.name} for ${config.packageName} in $outDir.',
                'Last build on $lastBuilt.',
                'Last dependencies change on $dependenciesLastChange.',
                if (hook == Hook.link)
                  'Last assets for linking change on $assetsLastChange.',
                'Last hook change on $hookLastSourceChange.',
              ].join(' '),
            );
            // All build flags go into [outDir]. Therefore we do not have to
            // check here whether the config is equal.
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
          packageLayout,
        );
      },
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
    PackageLayout packageLayout,
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
      final output = HookOutputImpl.readFromFile(file: config.outputFile) ??
          HookOutputImpl();

      final validateResult = await validate(
        config,
        output,
        packageLayout,
      );
      success &= validateResult.success;
      if (!validateResult.success) {
        logger.severe('package:${config.packageName}` has invalid output.');
      }
      for (final error in validateResult.errors) {
        logger.severe('- $error');
      }
      return (output, success);
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

  /// Compiles the hook to kernel and caches the kernel.
  ///
  /// If any of the Dart source files, or the package config changed after
  /// the last time the kernel file is compiled, the kernel file is
  /// recompiled. Otherwise a cached version is used.
  ///
  /// Due to some OSes only providing last-modified timestamps with second
  /// precision. The kernel compilation cache might be considered stale if
  /// the last modification and the kernel compilation happened within one
  /// second of each other. We error on the side of caution, rather recompile
  /// one time too many, then not recompiling when recompilation should have
  /// happened.
  ///
  /// It does not reuse the cached kernel for different [config]s, due to
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
      // Format: `path/to/my.dill: path/to/my.dart, path/to/more.dart`
      final depFileContents = await depFile.readAsString();
      final dartSourceFiles = depFileContents
          .trim()
          .split(' ')
          .skip(1) // '<kernel file>:'
          .map((u) => Uri.file(u).fileSystemEntity)
          .toList();
      final dartFilesLastChange = await dartSourceFiles.lastModified();
      final packageConfigLastChange =
          await packageConfigUri.fileSystemEntity.lastModified();
      sourceLastChange = packageConfigLastChange.isAfter(dartFilesLastChange)
          ? packageConfigLastChange
          : dartFilesLastChange;
      final kernelLastChange = await kernelFile.lastModified();
      mustCompile = sourceLastChange == kernelLastChange ||
          sourceLastChange.isAfter(kernelLastChange);
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
    required OS targetOS,
    required LinkModePreference linkMode,
    required Uri buildParentDir,
    Iterable<String>? supportedAssetTypes,
    required bool? linkingEnabled,
  }) async {
    const hook = Hook.build;
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

    // Shared between dry run and wet run.
    final outputDirectoryShared =
        buildParentDir.resolve('shared/${package.name}/$hook/out/');
    final outDirShared = Directory.fromUri(outputDirectoryShared);
    if (!await outDirShared.exists()) {
      // TODO(https://dartbug.com/50565): Purge old or unused folders.
      await outDirShared.create(recursive: true);
    }

    return BuildConfigImpl.dryRun(
      outputDirectory: outDirUri,
      outputDirectoryShared: outputDirectoryShared,
      packageName: packageName,
      packageRoot: packageRoot,
      targetOS: targetOS,
      linkModePreference: linkMode,
      supportedAssetTypes: supportedAssetTypes,
      linkingEnabled: linkingEnabled,
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

  Future<ValidateResult> validate(
    HookConfigImpl config,
    HookOutputImpl output,
    PackageLayout packageLayout,
  ) async {
    var (errors: errors, success: success) = config is BuildConfigImpl
        ? await validateBuild(config, output)
        : await validateLink(config as LinkConfigImpl, output);

    if (config is BuildConfigImpl) {
      final packagesWithLink =
          (await packageLayout.packagesWithAssets(Hook.link))
              .map((p) => p.name);
      for (final targetPackage in output.assetsForLinking.keys) {
        if (!packagesWithLink.contains(targetPackage)) {
          for (final asset in output.assetsForLinking[targetPackage]!) {
            success &= false;
            errors.add(
              'Asset "${asset.id}" is sent to package "$targetPackage" for'
              ' linking, but that package does not have a link hook.',
            );
          }
        }
      }
    }
    return (errors: errors, success: success);
  }

  Future<(List<Package> plan, PackageGraph? dependencyGraph, bool success)>
      _makePlan({
    required PackageLayout packageLayout,
    String? runPackageName,
    required Hook hook,
    // TODO(dacoharkes): How to share these two? Make them extend each other?
    BuildResult? buildResult,
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
        final assetsForLinking = buildResult?.assetsForLinking;
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

extension on Uri {
  Uri get parent => File(toFilePath()).parent.uri;
}

extension OSArchitectures on OS {
  Set<Architecture> get architectures => _osTargets[this]!;
}

const _osTargets = {
  OS.android: {
    Architecture.arm,
    Architecture.arm64,
    Architecture.ia32,
    Architecture.x64,
    Architecture.riscv64,
  },
  OS.fuchsia: {
    Architecture.arm64,
    Architecture.x64,
  },
  OS.iOS: {
    Architecture.arm,
    Architecture.arm64,
    Architecture.x64,
  },
  OS.linux: {
    Architecture.arm,
    Architecture.arm64,
    Architecture.ia32,
    Architecture.riscv32,
    Architecture.riscv64,
    Architecture.x64,
  },
  OS.macOS: {
    Architecture.arm64,
    Architecture.x64,
  },
  OS.windows: {
    Architecture.arm64,
    Architecture.ia32,
    Architecture.x64,
  },
};
