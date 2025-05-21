// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:file/file.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart';
import 'package:yaml/yaml.dart';

import '../dependencies_hash_file/dependencies_hash_file.dart';
import '../locking/locking.dart';
import '../model/build_result.dart';
import '../model/hook_result.dart';
import '../model/link_result.dart';
import '../package_layout/package_layout.dart';
import '../utils/run_process.dart';
import 'build_planner.dart';
import 'failure.dart';
import 'result.dart';
import 'tracing_file_system.dart';

typedef InputCreator = HookInputBuilder Function();

typedef BuildInputCreator = BuildInputBuilder Function();

typedef LinkInputCreator = LinkInputBuilder Function();

typedef _HookValidator =
    Future<ValidationErrors> Function(HookInput input, HookOutput output);

/// The programmatic API to be used by Dart launchers to invoke native builds.
///
/// These methods are invoked by launchers such as dartdev (for `dart run`)
/// and flutter_tools (for `flutter run` and `flutter build`).
///
/// The native assets build runner does not support reentrancy for identical
/// [BuildInput] and [LinkInput]! For more info see:
/// https://github.com/dart-lang/native/issues/1319
class NativeAssetsBuildRunner {
  /// The sequential parts of a build are reported on a single task.
  ///
  /// If we ever start doing concurrent hook invocations, we'll need to split
  /// it up in multiple tasks.
  final _task = TimelineTask();

  /// Traced by [_task], cannot be used for concurrent actions.
  late final TracingFileSystem _fileSystem;

  /// Not traced by [_task], can be used for concurrent actions.
  final FileSystem _fileSystemUntraced;

  final Logger logger;
  final Uri dartExecutable;
  final Duration singleHookTimeout;
  final Map<String, String> hookEnvironment;
  final UserDefines? userDefines;
  final PackageLayout packageLayout;

  NativeAssetsBuildRunner({
    required this.logger,
    required this.dartExecutable,
    required FileSystem fileSystem,
    required this.packageLayout,
    Duration? singleHookTimeout,
    Map<String, String>? hookEnvironment,
    this.userDefines,
  }) : _fileSystemUntraced = fileSystem,
       singleHookTimeout = singleHookTimeout ?? const Duration(minutes: 5),
       hookEnvironment =
           hookEnvironment ??
           filteredEnvironment(hookEnvironmentVariablesFilter) {
    _fileSystem = TracingFileSystem(fileSystem, _task);
  }

  /// Checks whether any hooks need to be run.
  ///
  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  Future<List<String>> packagesWithBuildHooks() async {
    final planner = await _planner;
    final packagesWithHook = await planner.packagesWithHook(Hook.build);
    return packagesWithHook.map((e) => e.name).toList();
  }

  Future<Result<HookResult, HooksRunnerFailure>> _checkUserDefines(
    LoadedUserDefines? loadedUserDefines,
  ) async => _timeAsync('_checkUserDefines', () async {
    if (loadedUserDefines?.pubspecErrors.isNotEmpty ?? false) {
      logger.severe('pubspec.yaml contains errors');
      for (final error in loadedUserDefines!.pubspecErrors) {
        logger.severe(error);
      }
      return const Failure(HooksRunnerFailure.projectConfig);
    }
    return Success(
      HookResult(
        dependencies: switch (userDefines?.workspacePubspec) {
          null => [],
          final pubspec => [pubspec],
        },
      ),
    );
  });

  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// The native assets build runner does not support reentrancy for identical
  /// [BuildInput] and [LinkInput]! For more info see:
  /// https://github.com/dart-lang/native/issues/1319
  ///
  /// The base protocol can be extended with [extensions]. See
  /// [ProtocolExtension] for more documentation.
  ///
  /// Returns a [Future] that completes with a [Result]. On success, the
  /// [Result] is a [Success] containing the [BuildResult], which encapsulates
  /// the outputs of all successful build hook executions. On failure, the
  /// [Result] is a [Failure] containing a [HooksRunnerFailure] indicating the
  /// reason for the build failure.
  Future<Result<BuildResult, HooksRunnerFailure>> build({
    required List<ProtocolExtension> extensions,
    required bool linkingEnabled,
  }) async => _timeAsync('BuildRunner.build', () async {
    final planResult = await _makePlan(hook: Hook.build, buildResult: null);
    if (planResult.isFailure) {
      return planResult.asFailure;
    }
    final (buildPlan, packageGraph) = planResult.success;
    if (buildPlan.isEmpty) {
      // Return eagerly if there are no build hooks at all.
      return Success(HookResult());
    }

    final loadedUserDefines = await _loadedUserDefines;
    final hookResultUserDefines = await _checkUserDefines(loadedUserDefines);
    if (hookResultUserDefines.isFailure) {
      return hookResultUserDefines;
    }
    var hookResult = hookResultUserDefines.success;

    /// Key is packageName.
    final globalAssetsForBuild = <String, List<EncodedAsset>>{};
    for (final package in buildPlan) {
      final assetsForBuild = _assetsForBuildForPackage(
        packageGraph: packageGraph!,
        packageName: package.name,
        globalAssetsForBuild: globalAssetsForBuild,
      );

      final inputBuilder = BuildInputBuilder();

      for (final e in extensions) {
        e.setupBuildInput(inputBuilder);
      }
      inputBuilder.config.setupBuild(linkingEnabled: linkingEnabled);
      inputBuilder.setupBuildInput(assets: assetsForBuild);

      final (buildDirUri, outDirUri, outDirSharedUri) = await _setupDirectories(
        Hook.build,
        inputBuilder,
        package,
      );

      inputBuilder.setupShared(
        packageName: package.name,
        packageRoot: packageLayout.packageRoot(package.name),
        outputFile: buildDirUri.resolve('output.json'),
        outputDirectoryShared: outDirSharedUri,
        userDefines: loadedUserDefines?[package.name],
      );

      final input = inputBuilder.build();
      final errors = [
        ...await ProtocolBase.validateBuildInput(input),
        for (final e in extensions) ...await e.validateBuildInput(input),
      ];
      if (errors.isNotEmpty) {
        _printErrors('Build input for ${package.name} contains errors', errors);
        return const Failure(HooksRunnerFailure.internal);
      }

      final result = await _runHookForPackageCached(
        Hook.build,
        input,
        (input, output) async => [
          for (final e in extensions)
            ...await e.validateBuildOutput(
              input as BuildInput,
              output as BuildOutput,
            ),
        ],
        null,
        buildDirUri,
        outDirUri,
      );
      if (result.isFailure) {
        return result.asFailure;
      }
      final (hookOutput, hookDeps) = result.success;
      hookResult = hookResult.copyAdd(hookOutput, hookDeps);
      globalAssetsForBuild[package.name] =
          (hookOutput as BuildOutput).assets.encodedAssetsForBuild;
    }

    // We only perform application wide validation in the final result of
    // building all assets (i.e. in the build step if linking is not enabled or
    // in the link step if linking is enableD).
    if (linkingEnabled) return Success(hookResult);

    final errors = [
      for (final e in extensions)
        ...await e.validateApplicationAssets(hookResult.encodedAssets),
    ];
    if (errors.isEmpty) return Success(hookResult);

    _printErrors('Application asset verification failed', errors);
    return const Failure(HooksRunnerFailure.hookRun);
  });

  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// The native assets build runner does not support reentrancy for identical
  /// [BuildInput] and [LinkInput]! For more info see:
  /// https://github.com/dart-lang/native/issues/1319
  ///
  /// The base protocol can be extended with [extensions]. See
  /// [ProtocolExtension] for more documentation.
  ///
  /// Returns a [Future] that completes with a [Result]. On success, the
  /// [Result] is a [Success] containing the [LinkResult], which encapsulates
  /// the outputs of all successful link hook executions. On failure, the
  /// [Result] is a [Failure] containing a [HooksRunnerFailure] indicating the
  /// reason for the failure.
  Future<Result<LinkResult, HooksRunnerFailure>> link({
    required List<ProtocolExtension> extensions,
    Uri? resourceIdentifiers,
    required BuildResult buildResult,
  }) async => _timeAsync('BuildRunner.link', () async {
    final loadedUserDefines = await _loadedUserDefines;
    final hookResultUserDefines = await _checkUserDefines(loadedUserDefines);
    if (hookResultUserDefines.isFailure) {
      return hookResultUserDefines;
    }
    var linkResult = hookResultUserDefines.success;

    final planResult = await _makePlan(
      hook: Hook.link,
      buildResult: buildResult,
    );
    if (planResult.isFailure) return planResult.asFailure;
    final (buildPlan, packageGraph) = planResult.success;

    for (final package in buildPlan) {
      final inputBuilder = LinkInputBuilder();
      for (final e in extensions) {
        e.setupLinkInput(inputBuilder);
      }

      final (buildDirUri, outDirUri, outDirSharedUri) = await _setupDirectories(
        Hook.link,
        inputBuilder,
        package,
      );

      File? resourcesFile;
      if (resourceIdentifiers != null) {
        resourcesFile = _fileSystem.file(buildDirUri.resolve('resources.json'));
        await resourcesFile.create();
        await _fileSystem.file(resourceIdentifiers).copy(resourcesFile.path);
      }

      inputBuilder.setupShared(
        packageName: package.name,
        packageRoot: packageLayout.packageRoot(package.name),
        outputFile: buildDirUri.resolve('output.json'),
        outputDirectoryShared: outDirSharedUri,
        userDefines: loadedUserDefines?[package.name],
      );
      inputBuilder.setupLink(
        assets: buildResult.encodedAssetsForLinking[package.name] ?? [],
        recordedUsesFile: resourcesFile?.uri,
      );

      final input = inputBuilder.build();
      final errors = [
        ...await ProtocolBase.validateLinkInput(input),
        for (final e in extensions) ...await e.validateLinkInput(input),
      ];
      if (errors.isNotEmpty) {
        print(input.assets.encodedAssets);
        _printErrors('Link input for ${package.name} contains errors', errors);
        return const Failure(HooksRunnerFailure.internal);
      }

      final result = await _runHookForPackageCached(
        Hook.link,
        input,
        (input, output) async => [
          for (final e in extensions)
            ...await e.validateLinkOutput(
              input as LinkInput,
              output as LinkOutput,
            ),
        ],
        resourceIdentifiers,
        buildDirUri,
        outDirUri,
      );
      if (result.isFailure) return result.asFailure;
      final (hookOutput, hookDeps) = result.success;
      linkResult = linkResult.copyAdd(hookOutput, hookDeps);
    }

    final errors = [
      for (final e in extensions)
        ...await e.validateApplicationAssets([
          ...buildResult.encodedAssets,
          ...linkResult.encodedAssets,
        ]),
    ];
    if (errors.isEmpty) return Success(linkResult);

    _printErrors('Application asset verification failed', errors);
    return const Failure(HooksRunnerFailure.hookRun);
  });

  void _printErrors(String message, ValidationErrors errors) {
    assert(errors.isNotEmpty);
    logger.severe(message);
    for (final error in errors) {
      logger.severe('- $error');
    }
  }

  Future<(Uri, Uri, Uri)> _setupDirectories(
    Hook hook,
    HookInputBuilder inputBuilder,
    Package package,
  ) => _timeAsync('_setupDirectories', () async {
    final buildDirName = inputBuilder.computeChecksum();
    final packageName = package.name;
    final buildDirUri = packageLayout.dartToolNativeAssetsBuilder.resolve(
      '$packageName/$buildDirName/',
    );
    final outDirUri = buildDirUri.resolve('out/');
    final outDir = _fileSystem.directory(outDirUri);
    if (!await outDir.exists()) {
      // TODO(https://dartbug.com/50565): Purge old or unused folders.
      await outDir.create(recursive: true);
    }
    final outDirSharedUri = packageLayout.dartToolNativeAssetsBuilder.resolve(
      'shared/${package.name}/${hook.name}/',
    );
    final outDirShared = _fileSystem.directory(outDirSharedUri);
    if (!await outDirShared.exists()) {
      // TODO(https://dartbug.com/50565): Purge old or unused folders.
      await outDirShared.create(recursive: true);
    }
    return (buildDirUri, outDirUri, outDirSharedUri);
  });

  Future<Result<(HookOutput, List<Uri>), HooksRunnerFailure>>
  _runHookForPackageCached(
    Hook hook,
    HookInput input,
    _HookValidator validator,
    Uri? resources,
    Uri buildDirUri,
    Uri outputDirectory,
  ) async => _timeAsync(
    '_runHookForPackageCached',
    arguments: {'hook': hook.name, 'package': input.packageName},
    () async => await runUnderDirectoriesLock(
      _fileSystem,
      [
        _fileSystem.directory(input.outputDirectoryShared).parent.uri,
        _fileSystem.directory(outputDirectory).parent.uri,
      ],
      timeout: singleHookTimeout,
      logger: logger,
      () async {
        final hookCompileResult = await _compileHookForPackageCached(
          input.packageName,
          buildDirUri,
          input.packageRoot.resolve('hook/${hook.scriptName}'),
        );
        if (hookCompileResult.isFailure) return hookCompileResult.asFailure;
        final (hookKernelFile, hookHashes, didRecompile) =
            hookCompileResult.success;

        final buildOutputFile = _fileSystem.file(input.outputFile);

        final dependenciesHashFile = buildDirUri.resolve(
          'dependencies.dependencies_hash_file.json',
        );
        final dependenciesHashes = DependenciesHashFile(
          _fileSystem,
          fileUri: dependenciesHashFile,
          task: _task,
        );
        final lastModifiedCutoffTime = DateTime.now();
        if (await buildOutputFile.exists() &&
            await dependenciesHashes.exists()) {
          final outputResult = await _readHookOutputFromUri(
            hook,
            buildOutputFile,
            input.packageName,
          );
          if (outputResult.isFailure) {
            return const Failure(HooksRunnerFailure.hookRun);
          }
          final output = outputResult.success;

          final outdatedDependency = await dependenciesHashes
              .findOutdatedDependency(hookEnvironment);
          if (outdatedDependency == null && !didRecompile) {
            // Note, we can only rely on didRecompile as long as the hook
            // compilations are not shared across different `BuildConfig`s.
            logger.info(
              'Skipping ${hook.name} for ${input.packageName}'
              ' in ${buildDirUri.toFilePath()}.'
              ' Last build on ${output.timestamp}.',
            );
            // All build flags go into [outDir]. Therefore we do not have to
            // check here whether the input is equal.
            return Success((output, hookHashes.fileSystemEntities));
          }
          logger.info(
            'Rerunning ${hook.name} for ${input.packageName}'
            ' in ${buildDirUri.toFilePath()}. '
            '${outdatedDependency ?? hookKernelFile.uri}',
          );
        }

        final result = await _runHookForPackage(
          hook,
          input,
          validator,
          resources,
          hookKernelFile,
          hookEnvironment,
          buildDirUri,
          outputDirectory,
        );
        if (result.isFailure) {
          if (await dependenciesHashes.exists()) {
            await dependenciesHashes.delete();
          }
          return result.asFailure;
        } else {
          final success = result.success;
          final modifiedDuringBuild = await dependenciesHashes.hashDependencies(
            [...success.dependencies],
            lastModifiedCutoffTime,
            hookEnvironment,
          );
          if (modifiedDuringBuild != null) {
            logger.severe('File modified during build. Build must be rerun.');
          }
          return Success((success, hookHashes.fileSystemEntities));
        }
      },
    ),
  );

  /// The list of environment variables used if [hookEnvironment] is not passed
  /// in.
  /// This allowlist lists environment variables needed to run mainstream
  /// compilers.
  static const hookEnvironmentVariablesFilter = {
    'ANDROID_HOME', // Needed for the NDK.
    'HOME', // Needed to find tools in default install locations.
    'PATH', // Needed to invoke native tools.
    'PROGRAMDATA', // Needed for vswhere.exe.
    'SYSTEMDRIVE', // Needed for CMake.
    'SYSTEMROOT', // Needed for process invocations on Windows.
    'TEMP', // Needed for temp dirs in Dart process.
    'TMP', // Needed for temp dirs in Dart process.
    'TMPDIR', // Needed for temp dirs in Dart process.
    'USERPROFILE', // Needed to find tools in default install locations.
    'WINDIR', // Needed for CMake.
  };

  Future<Result<HookOutput, HooksRunnerFailure>> _runHookForPackage(
    Hook hook,
    HookInput input,
    _HookValidator validator,
    Uri? resources,
    File hookKernelFile,
    Map<String, String> environment,
    Uri buildDirUri,
    Uri outputDirectory,
  ) => _timeAsync('_runHookForPackage', () async {
    final inputFile = buildDirUri.resolve('input.json');
    final inputFileContents = const JsonEncoder.withIndent(
      '  ',
    ).convert(input.json);
    logger.info('input.json contents:\n$inputFileContents');
    await _fileSystem.file(inputFile).writeAsString(inputFileContents);
    final hookOutputUri = input.outputFile;
    final hookOutputFile = _fileSystem.file(hookOutputUri);
    if (await hookOutputFile.exists()) {
      // Ensure we'll never read outdated build results.
      await hookOutputFile.delete();
    }

    final arguments = [
      '--packages=${packageLayout.packageConfigUri.toFilePath()}',
      hookKernelFile.path,
      '--config=${inputFile.toFilePath()}',
      if (resources != null) resources.toFilePath(),
    ];
    final wrappedLogger = await _createFileStreamingLogger(buildDirUri);
    final workingDirectory = input.packageRoot;
    final result = await runProcess(
      filesystem: _fileSystem,
      workingDirectory: workingDirectory,
      executable: dartExecutable,
      arguments: arguments,
      logger: wrappedLogger,
      includeParentEnvironment: false,
      environment: environment,
      task: _task,
    );

    var deleteOutputIfExists = false;
    try {
      if (result.exitCode != 0) {
        final printWorkingDir =
            workingDirectory != _fileSystem.currentDirectory.uri;
        final commandString = [
          if (printWorkingDir) '(cd ${workingDirectory.toFilePath()};',
          dartExecutable.toFilePath(),
          ...arguments.map((a) => a.contains(' ') ? "'$a'" : a),
          if (printWorkingDir) ')',
        ].join(' ');
        logger.severe('''
  Building assets for package:${input.packageName} failed.
  ${hook.scriptName} returned with exit code: ${result.exitCode}.
  To reproduce run:
  $commandString
  stderr:
  ${result.stderr}
  stdout:
  ${result.stdout}
          ''');
        deleteOutputIfExists = true;
        if (result.exitCode > 2 && result.exitCode < 255) {
          logger.warning(
            'Hook exited with a reserved exit code: ${result.exitCode}. '
            'Only 0, 1, 2, and 255 are in use.',
          );
        }
        final failureType = switch (result.exitCode) {
          2 => HooksRunnerFailure.infra,
          _ => HooksRunnerFailure.hookRun,
        };
        return Failure(failureType);
      }

      final outputResult = await _readHookOutputFromUri(
        hook,
        hookOutputFile,
        input.packageName,
      );
      if (outputResult.isFailure) {
        return outputResult.asFailure;
      }
      final output = outputResult.success;
      final errors = await _validate(input, output, validator);
      if (errors.isNotEmpty) {
        _printErrors(
          '$hook hook of package:${input.packageName} has invalid output',
          errors,
        );
        deleteOutputIfExists = true;
        return const Failure(HooksRunnerFailure.hookRun);
      }
      return Success(output);
    } finally {
      if (deleteOutputIfExists) {
        if (await hookOutputFile.exists()) {
          await hookOutputFile.delete();
        }
      }
    }
  });

  Future<Logger> _createFileStreamingLogger(Uri buildDirUri) async {
    final stdoutFile = _fileSystemUntraced.file(
      buildDirUri.resolve('stdout.txt'),
    );
    await stdoutFile.writeAsString('');
    final stderrFile = _fileSystemUntraced.file(
      buildDirUri.resolve('stderr.txt'),
    );
    await stderrFile.writeAsString('');
    final wrappedLogger = Logger.detached('')
      ..level = Level.ALL
      ..onRecord.listen((record) async {
        logger.log(record.level, record.message);
        if (record.level <= Level.INFO) {
          await stdoutFile.writeAsString(
            '${record.message}\n',
            mode: FileMode.append,
          );
        } else {
          await stderrFile.writeAsString(
            '${record.message}\n',
            mode: FileMode.append,
          );
        }
      });
    return wrappedLogger;
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
  /// It does not reuse the cached kernel for different inputs due to
  /// reentrancy requirements. For more info see:
  /// https://github.com/dart-lang/native/issues/1319
  ///
  /// TODO(https://github.com/dart-lang/native/issues/1578): Compile only once
  /// instead of per input. This requires more locking.
  Future<
    Result<
      (File kernelFile, DependenciesHashFile cacheFile, bool didCompile),
      HooksRunnerFailure
    >
  >
  _compileHookForPackageCached(
    String packageName,
    Uri buildDirUri,
    Uri scriptUri,
  ) => _timeAsync(
    '_compileHookForPackageCached',
    arguments: {'scriptUri': scriptUri.toFilePath(), 'package': packageName},
    () async {
      // Don't invalidate cache with environment changes.
      final environmentForCaching = <String, String>{};
      final kernelFile = _fileSystem.file(buildDirUri.resolve('hook.dill'));
      final depFile = _fileSystem.file(buildDirUri.resolve('hook.dill.d'));
      final dependenciesHashFile = buildDirUri.resolve(
        'hook.dependencies_hash_file.json',
      );
      final dependenciesHashes = DependenciesHashFile(
        _fileSystem,
        fileUri: dependenciesHashFile,
        task: _task,
      );
      final lastModifiedCutoffTime = DateTime.now();
      var mustCompile = false;
      if (!await dependenciesHashes.exists()) {
        mustCompile = true;
      } else {
        final outdatedDependency = await dependenciesHashes
            .findOutdatedDependency(environmentForCaching);
        if (outdatedDependency != null) {
          mustCompile = true;
          logger.info(
            'Recompiling ${scriptUri.toFilePath()}. $outdatedDependency',
          );
        }
      }

      if (!mustCompile) {
        return Success((kernelFile, dependenciesHashes, false));
      }

      final compileResult = await _compileHookForPackage(
        packageName,
        scriptUri,
        kernelFile,
        depFile,
      );
      if (compileResult.isFailure) {
        return compileResult.asFailure;
      }

      final dartSources = await _readDepFile(depFile);

      final modifiedDuringBuild = await dependenciesHashes.hashDependencies(
        [
          ...dartSources.where(
            (e) => e != packageLayout.packageConfigUri && !_isImmutable(e),
          ),
          packageLayout.packageConfigUri,
          // If the Dart version changed, recompile.
          dartExecutable.resolve('../version'),
        ],
        lastModifiedCutoffTime,
        environmentForCaching,
      );
      if (modifiedDuringBuild != null) {
        logger.severe('File modified during build. Build must be rerun.');
      }
      return Success((kernelFile, dependenciesHashes, true));
    },
  );

  // TODO(https://github.com/dart-lang/pub/issues/4577): Use immutability bit
  // when available.
  static bool _isImmutable(Uri e) =>
      e.toFilePath(windows: false).contains('/hosted/pub.dev/');

  Future<Result<void, HooksRunnerFailure>> _compileHookForPackage(
    String packageName,
    Uri scriptUri,
    File kernelFile,
    File depFile,
  ) => _timeAsync(
    '_compileHookForPackage',
    arguments: {'package': packageName},
    () async {
      final compileArguments = [
        'compile',
        'kernel',
        '--packages=${packageLayout.packageConfigUri.toFilePath()}',
        '--output=${kernelFile.path}',
        '--depfile=${depFile.path}',
        scriptUri.toFilePath(),
      ];
      final workingDirectory = packageLayout.packageConfigUri.resolve('../');
      final compileResult = await runProcess(
        filesystem: _fileSystem,
        workingDirectory: workingDirectory,
        executable: dartExecutable,
        arguments: compileArguments,
        logger: logger,
        includeParentEnvironment: true,
        task: _task,
      );
      if (compileResult.exitCode != 0) {
        final printWorkingDir =
            workingDirectory != _fileSystem.currentDirectory.uri;
        final commandString = [
          if (printWorkingDir) '(cd ${workingDirectory.toFilePath()};',
          dartExecutable.toFilePath(),
          ...compileArguments.map((a) => a.contains(' ') ? "'$a'" : a),
          if (printWorkingDir) ')',
        ].join(' ');
        logger.severe('''
Building native assets for package:$packageName failed.
Compilation of hook returned with exit code: ${compileResult.exitCode}.
To reproduce run:
$commandString
stderr:
${compileResult.stderr}
stdout:
${compileResult.stdout}
        ''');
        if (await depFile.exists()) {
          await depFile.delete();
        }
        if (await kernelFile.exists()) {
          await kernelFile.delete();
        }
        return const Failure(HooksRunnerFailure.hookRun);
      }
      return const Success(null);
    },
  );

  /// Returns only the assets output as assetForBuild by the packages that are
  /// the direct dependencies of [packageName].
  Map<String, List<EncodedAsset>>? _assetsForBuildForPackage({
    required PackageGraph packageGraph,
    required String packageName,
    Map<String, List<EncodedAsset>>? globalAssetsForBuild,
  }) {
    if (globalAssetsForBuild == null) {
      return null;
    }
    final dependencies = packageGraph.neighborsOf(packageName).toSet();
    return {
      for (final entry in globalAssetsForBuild.entries)
        if (dependencies.contains(entry.key)) entry.key: entry.value,
    };
  }

  Future<ValidationErrors> _validate(
    HookInput input,
    HookOutput output,
    _HookValidator validator,
  ) async {
    final errors = input is BuildInput
        ? await ProtocolBase.validateBuildOutput(input, output as BuildOutput)
        : await ProtocolBase.validateLinkOutput(
            input as LinkInput,
            output as LinkOutput,
          );
    errors.addAll(await validator(input, output));

    if (input is BuildInput) {
      final planner = await _planner;
      final packagesWithLink = (await planner.packagesWithHook(
        Hook.link,
      )).map((p) => p.name);
      for (final targetPackage
          in (output as BuildOutput).assets.encodedAssetsForLinking.keys) {
        if (!packagesWithLink.contains(targetPackage)) {
          for (final asset
              in output.assets.encodedAssetsForLinking[targetPackage]!) {
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

  late final _planner = () async {
    final planner = await NativeAssetsBuildPlanner.fromPackageConfigUri(
      packageConfigUri: packageLayout.packageConfigUri,
      dartExecutable: Uri.file(Platform.resolvedExecutable),
      logger: logger,
      packageLayout: packageLayout,
      fileSystem: _fileSystem,
      task: _task,
    );
    return planner;
  }();

  Future<
    Result<(BuildPlan plan, PackageGraph? dependencyGraph), HooksRunnerFailure>
  >
  _makePlan({required Hook hook, BuildResult? buildResult}) async => _timeAsync(
    '_makePlan',
    () async {
      switch (hook) {
        case Hook.build:
          final planner = await _planner;
          final planResult = await planner.makeBuildHookPlan();
          if (planResult.isFailure) {
            return planResult.asFailure;
          }
          return Success((planResult.success, planner.packageGraph));
        case Hook.link:
          // Link hooks are not run in any particular order.
          // Link hooks are skipped if no assets for linking are provided.
          final buildPlan = <Package>[];
          final skipped = <String>[];
          final encodedAssetsForLinking = buildResult!.encodedAssetsForLinking;
          final planner = await _planner;
          final packagesWithHook = await planner.packagesWithHook(Hook.link);
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
          return Success((buildPlan, null));
      }
    },
  );

  Future<Result<HookOutput, HooksRunnerFailure>> _readHookOutputFromUri(
    Hook hook,
    File hookOutputFile,
    String packageName,
  ) async {
    final file = hookOutputFile;
    final fileContents = await file.readAsString();
    logger.info('output.json contents:\n$fileContents');
    final Map<String, Object?> hookOutputJson;
    try {
      hookOutputJson = jsonDecode(fileContents) as Map<String, Object?>;
    } on FormatException catch (e) {
      logger.severe('''
Building assets for package:$packageName failed.
${hookOutputFile.uri.toFilePath()} contained a format error.

Contents: $fileContents.
${e.message}''');
      return const Failure(HooksRunnerFailure.hookRun);
    }
    switch (hook) {
      case Hook.build:
        final output = BuildOutputMaybeFailure(hookOutputJson);
        switch (output) {
          case BuildOutput _:
            return Success(output);
          case BuildOutputFailure(type: FailureType.infra):
            return const Failure(HooksRunnerFailure.infra);
          case BuildOutputFailure _:
            return const Failure(HooksRunnerFailure.hookRun);
        }
      case Hook.link:
        final output = LinkOutputMaybeFailure(hookOutputJson);
        switch (output) {
          case LinkOutput _:
            return Success(output);
          case LinkOutputFailure(type: FailureType.infra):
            return const Failure(HooksRunnerFailure.infra);
          case LinkOutputFailure _:
            return const Failure(HooksRunnerFailure.hookRun);
        }
    }
  }

  /// Returns a list of errors for [_readHooksUserDefinesFromPubspec].
  static List<String> _validateHooksUserDefinesFromPubspec(
    Map<Object?, Object?> pubspec,
  ) {
    final hooks = pubspec['hooks'];
    if (hooks == null) return [];
    if (hooks is! Map) {
      return ["Expected 'hooks' to be a map. Found: '$hooks'"];
    }
    final userDefines = hooks['user_defines'];
    if (userDefines == null) return [];
    if (userDefines is! Map) {
      return [
        "Expected 'hooks.user_defines' to be a map. Found: '$userDefines'",
      ];
    }

    final errors = <String>[];
    for (final MapEntry(:key, :value) in userDefines.entries) {
      if (key is! String) {
        errors.add(
          "Expected 'hooks.user_defines' to be a map with string keys."
          " Found key: '$key'.",
        );
      }
      if (value is! Map) {
        errors.add(
          "Expected 'hooks.user_defines.$key' to be a map. Found: '$value'",
        );
        continue;
      }
      for (final childKey in value.keys) {
        if (childKey is! String) {
          errors.add(
            "Expected 'hooks.user_defines.$key' to be a "
            "map with string keys. Found key: '$childKey'.",
          );
        }
      }
    }
    return errors;
  }

  /// Reads the user-defines from a pubspec.yaml in the suggested location.
  ///
  /// SDKs do not have to follow this, they might support user-defines in a
  /// different way.
  ///
  /// The [pubspec] is expected to be the decoded yaml, a Map.
  ///
  /// Before invoking, check errors with [_validateHooksUserDefinesFromPubspec].
  static Map<String, Map<String, Object?>> _readHooksUserDefinesFromPubspec(
    Map<Object?, Object?> pubspec,
  ) {
    assert(_validateHooksUserDefinesFromPubspec(pubspec).isEmpty);
    final hooks = pubspec['hooks'];
    if (hooks is! Map) {
      return {};
    }
    final userDefines = hooks['user_defines'];
    if (userDefines is! Map) {
      return {};
    }
    return {
      for (final MapEntry(:key, :value) in userDefines.entries)
        if (key is String)
          key: {
            if (value is Map)
              for (final MapEntry(:key, :value) in value.entries)
                if (key is String) key: value,
          },
    };
  }

  late final Future<LoadedUserDefines?> _loadedUserDefines = _loadUserDefines();

  Future<LoadedUserDefines?> _loadUserDefines() async =>
      _timeAsync('_loadUserDefines', () async {
        final pubspec = userDefines?.workspacePubspec;
        if (pubspec == null) {
          return null;
        }
        final contents = await _timeAsync(
          'read pubspec.yaml',
          () async => await _fileSystem.file(pubspec).readAsString(),
        );
        final decoded = await _timeAsync(
          'parse pubspec.yaml',
          () async => loadYaml(contents) as Map<Object?, Object?>,
        );
        final errors = _validateHooksUserDefinesFromPubspec(decoded);
        final defines = _readHooksUserDefinesFromPubspec(decoded);
        return LoadedUserDefines(
          pubspecErrors: errors,
          pubspecDefines: defines,
          pubspecBasePath: pubspec,
        );
      });

  Future<T> _timeAsync<T>(
    String name,
    Future<T> Function() function, {
    Map<String, Object>? arguments,
  }) async {
    _task.start(name, arguments: arguments);
    try {
      return await function();
    } finally {
      _task.finish();
    }
  }
}

/// The user-defines information passed from the SDK to the
/// [NativeAssetsBuildRunner].
///
/// Currently only holds [workspacePubspec]. (In the future this class will also
/// take command-line arguments and a working directory for the command-line
/// argument paths to be resolved against.)
class UserDefines {
  /// The pubspec.yaml of the pub workspace.
  ///
  /// User-defines are read from this file.
  final Uri? workspacePubspec;

  UserDefines({required this.workspacePubspec});
}

class LoadedUserDefines {
  final List<String> pubspecErrors;

  final Map<String, Map<String, Object?>> pubspecDefines;

  final Uri pubspecBasePath;

  LoadedUserDefines({
    required this.pubspecErrors,
    required this.pubspecDefines,
    required this.pubspecBasePath,
  });

  PackageUserDefines operator [](String packageName) => PackageUserDefines(
    workspacePubspec: switch (pubspecDefines[packageName]) {
      null => null,
      final defines => PackageUserDefinesSource(
        defines: defines,
        basePath: pubspecBasePath,
      ),
    },
  );
}

/// Parses depfile contents.
///
/// Format: `path/to/my.dill: path/to/my.dart, path/to/more.dart`
///
/// However, the spaces in paths are escaped with backslashes, and the
/// backslashes are escaped with backslashes:
///
/// ```dart
/// String _escapePath(String path) {
///   return path.replaceAll('\\', '\\\\').replaceAll(' ', '\\ ');
/// }
/// ```
@internal
List<String> parseDepFileInputs(String contents) {
  final output = contents.substring(0, contents.indexOf(': '));
  contents = contents.substring(output.length + ': '.length).trim();
  final pathsEscaped = _splitOnNonEscapedSpaces(contents);
  return pathsEscaped.map(_unescapeDepsPath).toList();
}

String _unescapeDepsPath(String path) =>
    path.replaceAll(r'\ ', ' ').replaceAll(r'\\', r'\');

List<String> _splitOnNonEscapedSpaces(String contents) {
  var index = 0;
  final result = <String>[];
  while (index < contents.length) {
    final start = index;
    while (index < contents.length) {
      final u = contents.codeUnitAt(index);
      if (u == ' '.codeUnitAt(0)) {
        break;
      }
      if (u == r'\'.codeUnitAt(0)) {
        index++;
        if (index == contents.length) {
          throw const FormatException('malformed, ending with backslash');
        }
        final v = contents.codeUnitAt(index);
        assert(v == ' '.codeUnitAt(0) || v == r'\'.codeUnitAt(0));
      }
      index++;
    }
    result.add(contents.substring(start, index));
    index++;
  }
  return result;
}

Future<List<Uri>> _readDepFile(File depFile) async {
  final depFileContents = await depFile.readAsString();
  final dartSources = parseDepFileInputs(depFileContents);
  return dartSources.map(Uri.file).toList();
}

@internal
Map<String, String> filteredEnvironment(Set<String> allowList) => {
  for (final entry in Platform.environment.entries)
    if (allowList.contains(entry.key.toUpperCase())) entry.key: entry.value,
};
