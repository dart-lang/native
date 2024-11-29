// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:package_config/package_config.dart';

import '../dependencies_hash_file/dependencies_hash_file.dart';
import '../locking/locking.dart';
import '../model/build_dry_run_result.dart';
import '../model/build_result.dart';
import '../model/hook_result.dart';
import '../model/link_result.dart';
import '../package_layout/package_layout.dart';
import '../utils/run_process.dart';
import 'build_planner.dart';

typedef DependencyMetadata = Map<String, Metadata>;

typedef ConfigCreator = HookConfigBuilder Function();

typedef BuildConfigCreator = BuildConfigBuilder Function();

typedef LinkConfigCreator = LinkConfigBuilder Function();

typedef _HookValidator = Future<ValidationErrors> Function(
    HookConfig config, HookOutput output);

// A callback that validates the invariants of the [BuildConfig].
typedef BuildConfigValidator = Future<ValidationErrors> Function(
    BuildConfig config);

// A callback that validates the invariants of the [LinkConfig].
typedef LinkConfigValidator = Future<ValidationErrors> Function(
    LinkConfig config);

// A callback that validates the output of a `hook/link.dart` invocation is
// valid (it may valid asset-type specific information).
typedef BuildValidator = Future<ValidationErrors> Function(
    BuildConfig config, BuildOutput outup);

// A callback that validates the output of a `hook/link.dart` invocation is
// valid (it may valid asset-type specific information).
typedef LinkValidator = Future<ValidationErrors> Function(
    LinkConfig config, LinkOutput output);

// A callback that validates assets emitted across all packages are valid / can
// be used together (it may valid asset-type specific information - e.g. that
// there are no classes in shared library filenames).
typedef ApplicationAssetValidator = Future<ValidationErrors> Function(
    List<EncodedAsset> assets);

/// The programmatic API to be used by Dart launchers to invoke native builds.
///
/// These methods are invoked by launchers such as dartdev (for `dart run`)
/// and flutter_tools (for `flutter run` and `flutter build`).
///
/// The native assets build runner does not support reentrancy for identical
/// [BuildConfig] and [LinkConfig]! For more info see:
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
  /// The given [applicationAssetValidator] is only used if the build is
  /// performed without linking (i.e. [linkingEnabled] is `false`).
  ///
  /// The native assets build runner does not support reentrancy for identical
  /// [BuildConfig] and [LinkConfig]! For more info see:
  /// https://github.com/dart-lang/native/issues/1319
  Future<BuildResult?> build({
    required BuildConfigCreator configCreator,
    required BuildConfigValidator configValidator,
    required BuildValidator buildValidator,
    required ApplicationAssetValidator applicationAssetValidator,
    required OS targetOS,
    required BuildMode buildMode,
    required Uri workingDirectory,
    PackageLayout? packageLayout,
    String? runPackageName,
    required List<String> supportedAssetTypes,
    required bool linkingEnabled,
  }) async {
    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);

    final (buildPlan, packageGraph) = await _makePlan(
      hook: Hook.build,
      packageLayout: packageLayout,
      buildResult: null,
      runPackageName: runPackageName,
    );
    if (buildPlan == null) return null;

    var hookResult = HookResult();
    final globalMetadata = <String, Metadata>{};
    for (final package in buildPlan) {
      final metadata = <String, Metadata>{};
      _metadataForPackage(
        packageGraph: packageGraph!,
        packageName: package.name,
        targetMetadata: globalMetadata,
      )?.forEach((key, value) => metadata[key] = value);

      final configBuilder = configCreator()
        ..setupHookConfig(
          targetOS: targetOS,
          supportedAssetTypes: supportedAssetTypes,
          buildMode: buildMode,
          packageName: package.name,
          packageRoot: packageLayout.packageRoot(package.name),
        )
        ..setupBuildConfig(
          dryRun: false,
          linkingEnabled: linkingEnabled,
          metadata: metadata,
        );

      final (buildDirUri, outDirUri, outDirSharedUri) = await _setupDirectories(
        Hook.build,
        packageLayout,
        configBuilder,
        package,
      );

      configBuilder.setupBuildRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
      );

      final config = BuildConfig(configBuilder.json);
      final errors = [
        ...await validateBuildConfig(config),
        ...await configValidator(config),
      ];
      if (errors.isNotEmpty) {
        return _printErrors(
            'Build configuration for ${package.name} contains errors', errors);
      }

      final hookOutput = await _runHookForPackageCached(
        Hook.build,
        config,
        (config, output) =>
            buildValidator(config as BuildConfig, output as BuildOutput),
        packageLayout.packageConfigUri,
        workingDirectory,
        null,
        packageLayout,
      );
      if (hookOutput == null) return null;
      hookResult = hookResult.copyAdd(hookOutput);
      globalMetadata[package.name] = (hookOutput as BuildOutput).metadata;
    }

    // We only perform application wide validation in the final result of
    // building all assets (i.e. in the build step if linking is not enabled or
    // in the link step if linking is enableD).
    if (linkingEnabled) return hookResult;

    final errors = await applicationAssetValidator(hookResult.encodedAssets);
    if (errors.isEmpty) return hookResult;

    _printErrors('Application asset verification failed', errors);
    return null;
  }

  /// [workingDirectory] is expected to contain `.dart_tool`.
  ///
  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// If provided, only assets of all transitive dependencies of
  /// [runPackageName] are linked.
  ///
  /// The native assets build runner does not support reentrancy for identical
  /// [BuildConfig] and [LinkConfig]! For more info see:
  /// https://github.com/dart-lang/native/issues/1319
  Future<LinkResult?> link({
    required LinkConfigCreator configCreator,
    required LinkConfigValidator configValidator,
    required LinkValidator linkValidator,
    required OS targetOS,
    required BuildMode buildMode,
    required Uri workingDirectory,
    required ApplicationAssetValidator applicationAssetValidator,
    PackageLayout? packageLayout,
    Uri? resourceIdentifiers,
    String? runPackageName,
    required List<String> supportedAssetTypes,
    required BuildResult buildResult,
  }) async {
    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);

    final (buildPlan, packageGraph) = await _makePlan(
      hook: Hook.link,
      packageLayout: packageLayout,
      buildResult: buildResult,
      runPackageName: runPackageName,
    );
    if (buildPlan == null) return null;

    var hookResult = HookResult(encodedAssets: buildResult.encodedAssets);
    for (final package in buildPlan) {
      final configBuilder = configCreator()
        ..setupHookConfig(
          targetOS: targetOS,
          supportedAssetTypes: supportedAssetTypes,
          buildMode: buildMode,
          packageName: package.name,
          packageRoot: packageLayout.packageRoot(package.name),
        );

      final (buildDirUri, outDirUri, outDirSharedUri) = await _setupDirectories(
          Hook.link, packageLayout, configBuilder, package);

      configBuilder.setupLinkConfig(
        assets: buildResult.encodedAssetsForLinking[package.name] ?? [],
      );

      File? resourcesFile;
      if (resourceIdentifiers != null) {
        resourcesFile = File.fromUri(buildDirUri.resolve('resources.json'));
        await resourcesFile.create();
        await File.fromUri(resourceIdentifiers).copy(resourcesFile.path);
      }
      configBuilder.setupLinkRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
        recordedUsesFile: resourcesFile?.uri,
      );

      final config = LinkConfig(configBuilder.json);
      final errors = [
        ...await validateLinkConfig(config),
        ...await configValidator(config),
      ];
      if (errors.isNotEmpty) {
        return _printErrors(
            'Link configuration for ${package.name} contains errors', errors);
      }

      final hookOutput = await _runHookForPackageCached(
        Hook.link,
        config,
        (config, output) =>
            linkValidator(config as LinkConfig, output as LinkOutput),
        packageLayout.packageConfigUri,
        workingDirectory,
        resourceIdentifiers,
        packageLayout,
      );
      if (hookOutput == null) return null;
      hookResult = hookResult.copyAdd(hookOutput);
    }

    final errors = await applicationAssetValidator(hookResult.encodedAssets);
    if (errors.isEmpty) return hookResult;

    _printErrors('Application asset verification failed', errors);
    return null;
  }

  Null _printErrors(String message, ValidationErrors errors) {
    assert(errors.isNotEmpty);
    logger.severe(message);
    for (final error in errors) {
      logger.severe('- $error');
    }
    return null;
  }

  Future<(Uri, Uri, Uri)> _setupDirectories(
      Hook hook,
      PackageLayout packageLayout,
      HookConfigBuilder configBuilder,
      Package package) async {
    final buildDirName = configBuilder.computeChecksum();
    final buildDirUri =
        packageLayout.dartToolNativeAssetsBuilder.resolve('$buildDirName/');
    final outDirUri = buildDirUri.resolve('out/');
    final outDir = Directory.fromUri(outDirUri);
    if (!await outDir.exists()) {
      // TODO(https://dartbug.com/50565): Purge old or unused folders.
      await outDir.create(recursive: true);
    }
    final outDirSharedUri = packageLayout.dartToolNativeAssetsBuilder
        .resolve('shared/${package.name}/$hook/');
    final outDirShared = Directory.fromUri(outDirSharedUri);
    if (!await outDirShared.exists()) {
      // TODO(https://dartbug.com/50565): Purge old or unused folders.
      await outDirShared.create(recursive: true);
    }
    return (buildDirUri, outDirUri, outDirSharedUri);
  }

  /// [workingDirectory] is expected to contain `.dart_tool`.
  ///
  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// If provided, only native assets of all transitive dependencies of
  /// [runPackageName] are built.
  Future<BuildDryRunResult?> buildDryRun({
    required BuildConfigCreator configCreator,
    required BuildValidator buildValidator,
    required OS targetOS,
    required Uri workingDirectory,
    required bool linkingEnabled,
    PackageLayout? packageLayout,
    String? runPackageName,
    required List<String> supportedAssetTypes,
  }) =>
      _runDryRun(
        targetOS: targetOS,
        configCreator: configCreator,
        validator: (HookConfig config, HookOutput output) =>
            buildValidator(config as BuildConfig, output as BuildOutput),
        workingDirectory: workingDirectory,
        packageLayout: packageLayout,
        runPackageName: runPackageName,
        supportedAssetTypes: supportedAssetTypes,
        linkingEnabled: linkingEnabled,
      );

  Future<HookResult?> _runDryRun({
    required BuildConfigCreator configCreator,
    required _HookValidator validator,
    required OS targetOS,
    required Uri workingDirectory,
    PackageLayout? packageLayout,
    String? runPackageName,
    required bool linkingEnabled,
    required List<String> supportedAssetTypes,
  }) async {
    const hook = Hook.build;

    packageLayout ??= await PackageLayout.fromRootPackageRoot(workingDirectory);
    final (buildPlan, _) = await _makePlan(
      hook: hook,
      packageLayout: packageLayout,
      runPackageName: runPackageName,
    );
    if (buildPlan == null) {
      return null;
    }

    var hookResult = HookResult();
    for (final package in buildPlan) {
      final configBuilder = configCreator();
      configBuilder.setupHookConfig(
        targetOS: targetOS,
        supportedAssetTypes: supportedAssetTypes,
        buildMode: null, // not set in dry-run mode
        packageName: package.name,
        packageRoot: packageLayout.packageRoot(package.name),
      );
      configBuilder.setupBuildConfig(
        dryRun: true,
        linkingEnabled: linkingEnabled,
        metadata: const {},
      );

      final buildDirName = configBuilder.computeChecksum();
      final buildDirUri =
          packageLayout.dartToolNativeAssetsBuilder.resolve('$buildDirName/');
      final outDirUri = buildDirUri.resolve('out/');
      final outDir = Directory.fromUri(outDirUri);
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
      configBuilder.setupBuildRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
      );

      final config = BuildConfig(configBuilder.json);
      final packageConfigUri = packageLayout.packageConfigUri;
      final (
        compileSuccess,
        hookKernelFile,
        _,
      ) = await _compileHookForPackageCached(
        config.packageName,
        config.outputDirectory,
        config.packageRoot.resolve('hook/${hook.scriptName}'),
        packageConfigUri,
        workingDirectory,
      );
      if (!compileSuccess) return null;

      // TODO(https://github.com/dart-lang/native/issues/1321): Should dry runs be cached?
      final buildOutput = await runUnderDirectoriesLock(
        [
          Directory.fromUri(config.outputDirectoryShared.parent),
          Directory.fromUri(config.outputDirectory.parent),
        ],
        timeout: singleHookTimeout,
        logger: logger,
        () => _runHookForPackage(
          hook,
          config,
          validator,
          packageConfigUri,
          workingDirectory,
          null,
          hookKernelFile,
          packageLayout!,
        ),
      );
      if (buildOutput == null) return null;
      hookResult = hookResult.copyAdd(buildOutput);
    }
    return hookResult;
  }

  // TODO(https://github.com/dart-lang/native/issues/32): Rerun hook if
  // environment variables change.
  Future<HookOutput?> _runHookForPackageCached(
    Hook hook,
    HookConfig config,
    _HookValidator validator,
    Uri packageConfigUri,
    Uri workingDirectory,
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
          hookHashesFile,
        ) = await _compileHookForPackageCached(
          config.packageName,
          config.outputDirectory,
          config.packageRoot.resolve('hook/${hook.scriptName}'),
          packageConfigUri,
          workingDirectory,
        );
        if (!compileSuccess) {
          return null;
        }

        final buildOutputFile =
            File.fromUri(config.outputDirectory.resolve(hook.outputName));
        final dependenciesHashFile = File.fromUri(
          config.outputDirectory
              .resolve('../dependencies.dependencies_hash_file.json'),
        );
        final dependenciesHashes =
            DependenciesHashFile(file: dependenciesHashFile);
        final lastModifiedCutoffTime = DateTime.now();
        final environmentFile = File.fromUri(
          config.outputDirectory.resolve('../environment.json'),
        );
        if (buildOutputFile.existsSync() &&
            dependenciesHashFile.existsSync() &&
            environmentFile.existsSync()) {
          late final HookOutput output;
          try {
            output = _readHookOutputFromUri(hook, buildOutputFile);
          } on FormatException catch (e) {
            logger.severe('''
Building assets for package:${config.packageName} failed.
${hook.outputName} contained a format error.

Contents: ${buildOutputFile.readAsStringSync()}.
${e.message}
        ''');
            return null;
          }

          final outdatedFile =
              await dependenciesHashes.findOutdatedFileSystemEntity();
          final environmentChanged = (!await environmentFile.exists()) ||
              !const MapEquality<String, String>().equals(
                  (json.decode(await environmentFile.readAsString()) as Map)
                      .cast<String, String>(),
                  Platform.environment);
          if (outdatedFile == null && !environmentChanged) {
            logger.info(
              'Skipping ${hook.name} for ${config.packageName}'
              ' in ${outDir.toFilePath()}.'
              ' Last build on ${output.timestamp}.',
            );
            // All build flags go into [outDir]. Therefore we do not have to
            // check here whether the config is equal.
            return output;
          }
          if (outdatedFile != null) {
            logger.info(
              'Rerunning ${hook.name} for ${config.packageName}'
              ' in ${outDir.toFilePath()}.'
              ' ${outdatedFile.toFilePath()} changed.',
            );
          } else {
            logger.info(
              'Rerunning ${hook.name} for ${config.packageName}'
              ' in ${outDir.toFilePath()}.'
              ' The environment variables changed.',
            );
          }
        }

        final result = await _runHookForPackage(
          hook,
          config,
          validator,
          packageConfigUri,
          workingDirectory,
          resources,
          hookKernelFile,
          packageLayout,
        );
        if (result == null) {
          if (await dependenciesHashFile.exists()) {
            await dependenciesHashFile.delete();
          }
        } else {
          await environmentFile.writeAsString(
            json.encode(Platform.environment),
          );
          final modifiedDuringBuild =
              await dependenciesHashes.hashFilesAndDirectories(
            [
              ...result.dependencies,
              // Also depend on the hook source code.
              hookHashesFile.uri,
            ],
            validBeforeLastModified: lastModifiedCutoffTime,
          );
          if (modifiedDuringBuild != null) {
            logger.severe('File modified during build. Build must be rerun.');
          }
        }
        return result;
      },
    );
  }

  Future<HookOutput?> _runHookForPackage(
    Hook hook,
    HookConfig config,
    _HookValidator validator,
    Uri packageConfigUri,
    Uri workingDirectory,
    Uri? resources,
    File hookKernelFile,
    PackageLayout packageLayout,
  ) async {
    final configFile = config.outputDirectory.resolve('../config.json');
    final configFileContents =
        const JsonEncoder.withIndent(' ').convert(config.json);
    logger.info('config.json contents: $configFileContents');
    await File.fromUri(configFile).writeAsString(configFileContents);
    final hookOutputUri = config.outputDirectory.resolve(hook.outputName);
    final hookOutputFile = File.fromUri(hookOutputUri);
    if (await hookOutputFile.exists()) {
      // Ensure we'll never read outdated build results.
      await hookOutputFile.delete();
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
    );

    var deleteOutputIfExists = false;
    try {
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
  Building assets for package:${config.packageName} failed.
  ${hook.scriptName} returned with exit code: ${result.exitCode}.
  To reproduce run:
  $commandString
  stderr:
  ${result.stderr}
  stdout:
  ${result.stdout}
          ''',
        );
        deleteOutputIfExists = true;
        return null;
      }

      final output = _readHookOutputFromUri(hook, hookOutputFile);
      final errors = await _validate(config, output, packageLayout, validator);
      if (errors.isNotEmpty) {
        _printErrors(
            '$hook hook of package:${config.packageName} has invalid output',
            errors);
        deleteOutputIfExists = true;
        return null;
      }
      return output;
    } on FormatException catch (e) {
      logger.severe('''
Building assets for package:${config.packageName} failed.
${hook.outputName} contained a format error.

Contents: ${hookOutputFile.readAsStringSync()}.
${e.message}
        ''');
      return null;
    } finally {
      if (deleteOutputIfExists) {
        if (await hookOutputFile.exists()) {
          await hookOutputFile.delete();
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
  /// It does not reuse the cached kernel for different configs due to
  /// reentrancy requirements. For more info see:
  /// https://github.com/dart-lang/native/issues/1319
  ///
  /// TODO(https://github.com/dart-lang/native/issues/1578): Compile only once
  /// instead of per config. This requires more locking.
  Future<(bool success, File kernelFile, File cacheFile)>
      _compileHookForPackageCached(
    String packageName,
    Uri outputDirectory,
    Uri scriptUri,
    Uri packageConfigUri,
    Uri workingDirectory,
  ) async {
    final kernelFile = File.fromUri(
      outputDirectory.resolve('../hook.dill'),
    );
    final depFile = File.fromUri(
      outputDirectory.resolve('../hook.dill.d'),
    );
    final dependenciesHashFile = File.fromUri(
      outputDirectory.resolve('../hook.dependencies_hash_file.json'),
    );
    final dependenciesHashes = DependenciesHashFile(file: dependenciesHashFile);
    final lastModifiedCutoffTime = DateTime.now();
    var mustCompile = false;
    if (!await dependenciesHashFile.exists()) {
      mustCompile = true;
    } else {
      final outdatedFile =
          await dependenciesHashes.findOutdatedFileSystemEntity();
      if (outdatedFile != null) {
        mustCompile = true;
        logger.info(
          'Recompiling ${scriptUri.toFilePath()}, '
          '${outdatedFile.toFilePath()} changed.',
        );
      }
    }

    if (!mustCompile) {
      return (true, kernelFile, dependenciesHashFile);
    }

    final success = await _compileHookForPackage(
      packageName,
      scriptUri,
      packageConfigUri,
      workingDirectory,
      kernelFile,
      depFile,
    );
    if (!success) {
      await dependenciesHashFile.delete();
      return (success, kernelFile, dependenciesHashFile);
    }

    final dartSources = await _readDepFile(depFile);
    final modifiedDuringBuild =
        await dependenciesHashes.hashFilesAndDirectories(
      [
        ...dartSources,
        // If the Dart version changed, recompile.
        dartExecutable.resolve('../version'),
      ],
      validBeforeLastModified: lastModifiedCutoffTime,
    );
    if (modifiedDuringBuild != null) {
      logger.severe('File modified during build. Build must be rerun.');
    }

    return (success, kernelFile, dependenciesHashFile);
  }

  Future<List<Uri>> _readDepFile(File depFile) async {
    // Format: `path/to/my.dill: path/to/my.dart, path/to/more.dart`
    final depFileContents = await depFile.readAsString();
    final dartSources = depFileContents
        .trim()
        .split(' ')
        .skip(1) // '<kernel file>:'
        .map(Uri.file)
        .toList();
    return dartSources;
  }

  Future<bool> _compileHookForPackage(
    String packageName,
    Uri scriptUri,
    Uri packageConfigUri,
    Uri workingDirectory,
    File kernelFile,
    File depFile,
  ) async {
    final compileArguments = [
      'compile',
      'kernel',
      '--packages=${packageConfigUri.toFilePath()}',
      '--output=${kernelFile.path}',
      '--depfile=${depFile.path}',
      scriptUri.toFilePath(),
    ];
    final compileResult = await runProcess(
      workingDirectory: workingDirectory,
      executable: dartExecutable,
      arguments: compileArguments,
      logger: logger,
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
Building native assets for package:$packageName failed.
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

  Future<ValidationErrors> _validate(
    HookConfig config,
    HookOutput output,
    PackageLayout packageLayout,
    _HookValidator validator,
  ) async {
    final errors = config is BuildConfig
        ? await validateBuildOutput(config, output as BuildOutput)
        : await validateLinkOutput(config as LinkConfig, output as LinkOutput);
    errors.addAll(await validator(config, output));

    if (config is BuildConfig) {
      final packagesWithLink =
          (await packageLayout.packagesWithAssets(Hook.link))
              .map((p) => p.name);
      for (final targetPackage
          in (output as BuildOutput).encodedAssetsForLinking.keys) {
        if (!packagesWithLink.contains(targetPackage)) {
          for (final asset in output.encodedAssetsForLinking[targetPackage]!) {
            errors.add(
              'Asset "$asset" is sent to package "$targetPackage" for'
              ' linking, but that package does not have a link hook.',
            );
          }
        }
      }
    }
    return errors;
  }

  Future<(List<Package>? plan, PackageGraph? dependencyGraph)> _makePlan({
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
          return (packagesWithHook, dependencyGraph);
        } else {
          final planner = await NativeAssetsBuildPlanner.fromRootPackageRoot(
            rootPackageRoot: packageLayout.rootPackageRoot,
            packagesWithNativeAssets: packagesWithHook,
            dartExecutable: Uri.file(Platform.resolvedExecutable),
            logger: logger,
          );
          final plan = planner.plan(
            runPackageName: runPackageName,
          );
          return (plan, planner.packageGraph);
        }
      case Hook.link:
        // Link hooks are not run in any particular order.
        // Link hooks are skipped if no assets for linking are provided.
        buildPlan = [];
        final skipped = <String>[];
        final encodedAssetsForLinking = buildResult!.encodedAssetsForLinking;
        for (final package in packagesWithHook) {
          if (encodedAssetsForLinking[package.name]?.isNotEmpty ?? false) {
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
    return (buildPlan, packageGraph);
  }

  HookOutput _readHookOutputFromUri(Hook hook, File hookOutputFile) {
    final decode = const Utf8Decoder().fuse(const JsonDecoder()).convert;
    final hookOutputJson =
        decode(hookOutputFile.readAsBytesSync()) as Map<String, Object?>;
    return hook == Hook.build
        ? BuildOutput(hookOutputJson)
        : LinkOutput(hookOutputJson);
  }
}

extension on Uri {
  Uri get parent => File(toFilePath()).parent.uri;
}
