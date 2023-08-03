// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

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
  /// Completes the future with an error if the build fails.
  Future<BuildResult> build({
    required LinkModePreference linkModePreference,
    required Target target,
    required Uri workingDirectory,
    required BuildMode buildMode,
    CCompilerConfig? cCompilerConfig,
    IOSSdk? targetIOSSdk,
    int? targetAndroidNdkApi,
    required bool includeParentEnvironment,
  }) async {
    final packageLayout =
        await PackageLayout.fromRootPackageRoot(workingDirectory);
    final packagesWithNativeAssets =
        await packageLayout.packagesWithNativeAssets;
    final planner = await NativeAssetsBuildPlanner.fromRootPackageRoot(
      rootPackageRoot: packageLayout.rootPackageRoot,
      packagesWithNativeAssets: packagesWithNativeAssets,
      dartExecutable: Uri.file(Platform.resolvedExecutable),
    );
    final plan = planner.plan();
    final assets = <Asset>[];
    final dependencies = <Uri>[];
    final errors = <NativeAssetsBuilderError>[];
    final metadata = <String, Metadata>{};
    if (plan.errors.isNotEmpty) {
      errors.addAll(plan.errors);
    } else {
      for (final package in plan.packages) {
        final dependencyMetadata = _metadataForPackage(
          packageGraph: planner.packageGraph,
          packageName: package.name,
          targetMetadata: metadata,
        );
        final config = await _cliConfig(
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
        final (
          packageAssets,
          packageDependencies,
          packageMetadata,
          packageErrors
        ) = await _buildPackageCached(
          config,
          packageLayout.packageConfigUri,
          workingDirectory,
          includeParentEnvironment,
        );
        assets.addAll(packageAssets);
        dependencies.addAll(packageDependencies);
        errors.addAll(packageErrors);
        if (packageMetadata != null) {
          metadata[config.packageName] = packageMetadata;
        }
      }
    }
    return _BuildResultImpl(
      assets: assets,
      dependencies: dependencies..sort(_uriCompare),
      errors: errors,
    );
  }

  /// [workingDirectory] is expected to contain `.dart_tool`.
  ///
  /// This method is invoked by launchers such as dartdev (for `dart run`) and
  /// flutter_tools (for `flutter run` and `flutter build`).
  ///
  /// Completes the future with an error if the build fails.
  Future<DryRunResult> dryRun({
    required LinkModePreference linkModePreference,
    required OS targetOs,
    required Uri workingDirectory,
    required bool includeParentEnvironment,
  }) async {
    final packageLayout =
        await PackageLayout.fromRootPackageRoot(workingDirectory);
    final packagesWithNativeAssets =
        await packageLayout.packagesWithNativeAssets;
    final planner = await NativeAssetsBuildPlanner.fromRootPackageRoot(
      rootPackageRoot: packageLayout.rootPackageRoot,
      packagesWithNativeAssets: packagesWithNativeAssets,
      dartExecutable: Uri.file(Platform.resolvedExecutable),
    );
    final plan = planner.plan();
    final assets = <Asset>[];
    final errors = <NativeAssetsBuilderError>[];
    if (plan.errors.isNotEmpty) {
      errors.addAll(plan.errors);
    } else {
      for (final package in plan.packages) {
        final config = await _cliConfigDryRun(
          packageName: package.name,
          packageRoot: packageLayout.packageRoot(package.name),
          targetOs: targetOs,
          linkMode: linkModePreference,
          buildParentDir: packageLayout.dartToolNativeAssetsBuilder,
        );
        final (packageAssets, _, _, packageErrors) = await _buildPackage(
          config,
          packageLayout.packageConfigUri,
          workingDirectory,
          includeParentEnvironment,
          dryRun: true,
        );
        assets.addAll(packageAssets);
        errors.addAll(packageErrors);
      }
    }
    return _DryRunResultImpl(
      assets: assets,
      errors: errors,
    );
  }

  Future<(List<Asset>, List<Uri>, Metadata?, List<NativeAssetsBuilderError>)>
      _buildPackageCached(
    BuildConfig config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment,
  ) async {
    final packageName = config.packageName;
    final outDir = config.outDir;
    if (!await Directory.fromUri(outDir).exists()) {
      await Directory.fromUri(outDir).create(recursive: true);
    }

    final buildOutput = await BuildOutput.readFromFile(outDir: outDir);
    final lastBuilt = buildOutput?.timestamp.roundDownToSeconds() ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final dependencies = buildOutput?.dependencies;
    final lastChange = await dependencies?.lastModified() ?? DateTime.now();

    if (lastBuilt.isAfter(lastChange)) {
      logger.info('Skipping build for $packageName in $outDir. '
          'Last build on $lastBuilt, last input change on $lastChange.');
      // All build flags go into [outDir]. Therefore we do not have to check
      // here whether the config is equal.
      final assets = buildOutput!.assets;
      final dependencies = buildOutput.dependencies.dependencies;
      final metadata = buildOutput.metadata;
      return (assets, dependencies, metadata, <NativeAssetsBuilderError>[]);
    }

    return await _buildPackage(
      config,
      packageConfigUri,
      workingDirectory,
      includeParentEnvironment,
      dryRun: false,
    );
  }

  Future<(List<Asset>, List<Uri>, Metadata?, List<NativeAssetsBuilderError>)>
      _buildPackage(
    BuildConfig config,
    Uri packageConfigUri,
    Uri workingDirectory,
    bool includeParentEnvironment, {
    required bool dryRun,
  }) async {
    final outDir = config.outDir;
    final configFile = outDir.resolve('../config.yaml');
    final buildDotDart = config.packageRoot.resolve('build.dart');
    final configFileContents = config.toYamlString();
    logger.info('config.yaml contents: $configFileContents');
    await File.fromUri(configFile).writeAsString(configFileContents);
    final buildOutputFile = File.fromUri(outDir.resolve(BuildOutput.fileName));
    if (await buildOutputFile.exists()) {
      // Ensure we'll never read outdated build results.
      await buildOutputFile.delete();
    }
    final arguments = [
      '--packages=${packageConfigUri.toFilePath()}',
      buildDotDart.toFilePath(),
      '--config=${configFile.toFilePath()}',
    ];
    final result = await runProcess(
      workingDirectory: workingDirectory,
      executable: dartExecutable,
      arguments: arguments,
      logger: logger,
      includeParentEnvironment: includeParentEnvironment,
    );
    final errors = <NativeAssetsBuilderError>[];
    if (result.exitCode != 0) {
      final printWorkingDir = workingDirectory != Directory.current.uri;
      final commandString = [
        if (printWorkingDir) '(cd ${workingDirectory.toFilePath()};',
        dartExecutable.toFilePath(),
        ...arguments.map((a) => a.contains(' ') ? "'$a'" : a),
        if (printWorkingDir) ')',
      ].join(' ');
      errors.add(NativeAssetsBuilderError(
        package: config.packageName,
        '''Building native assets failed.
build.dart returned with exit code: ${result.exitCode}.
To reproduce run:
$commandString
stderr:
${result.stderr}
stdout:
${result.stdout}
        ''',
      ));
    }

    try {
      final buildOutput = await BuildOutput.readFromFile(outDir: outDir);
      final assets = buildOutput?.assets ?? [];
      errors.addAll(validateAssetsPackage(assets, config.packageName));
      final dependencies = buildOutput?.dependencies.dependencies ?? [];
      final metadata = dryRun ? null : buildOutput?.metadata;
      return (assets, dependencies, metadata, errors);
    } on FormatException catch (e) {
      return (
        <Asset>[],
        <Uri>[],
        null,
        [
          NativeAssetsBuilderError(
            package: config.packageName,
            '''Building native assets failed.
build_output.yaml contained a format error.
${e.message}
        ''',
          ),
        ],
      );
      // TODO(https://github.com/dart-lang/native/issues/109): Stop throwing
      // type errors in native_assets_cli, release a new version of that package
      // and then remove this.
      // ignore: avoid_catching_errors
    } on TypeError {
      return (
        <Asset>[],
        <Uri>[],
        null,
        [
          NativeAssetsBuilderError(
            package: config.packageName,
            '''Building native assets failed.
build_output.yaml contained a format error.
        ''',
          ),
        ],
      );
    }
  }

  static Future<BuildConfig> _cliConfig({
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

  List<NativeAssetsBuilderError> validateAssetsPackage(
      List<Asset> assets, String packageName) {
    final invalidAssetIds = assets
        .map((a) => a.name)
        .where((n) => !n.startsWith('package:$packageName/'))
        .toSet()
        .toList()
      ..sort();
    return [
      if (invalidAssetIds.isNotEmpty)
        NativeAssetsBuilderError(
          '`package:$packageName` declares the following assets which do not '
          'start with `package:$packageName/`: ${invalidAssetIds.join(', ')}.',
        ),
    ];
  }
}

/// The result from a [NativeAssetsBuildRunner.dryRun].
abstract interface class DryRunResult {
  /// The native assets for all [Target]s for the build or dry run.
  List<Asset> get assets;

  /// Any errors
  List<NativeAssetsBuilderError> get errors;
}

final class _DryRunResultImpl implements DryRunResult {
  @override
  final List<Asset> assets;

  @override
  final List<NativeAssetsBuilderError> errors;

  _DryRunResultImpl({
    required this.assets,
    required this.errors,
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
  final List<Asset> assets;

  @override
  final List<Uri> dependencies;

  @override
  final List<NativeAssetsBuilderError> errors;

  _BuildResultImpl({
    required this.assets,
    required this.dependencies,
    required this.errors,
  });
}

final class NativeAssetsBuilderError {
  final String message;

  /// The package that was being built that caused an error.
  final String? package;

  NativeAssetsBuilderError(
    this.message, {
    this.package,
  });
}

extension on DateTime {
  DateTime roundDownToSeconds() =>
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch -
          millisecondsSinceEpoch % Duration(seconds: 1).inMilliseconds);
}

extension on BuildConfig {
  String get packageName =>
      packageRoot.pathSegments.lastWhere((e) => e.isNotEmpty);
}

int _uriCompare(Uri u1, Uri u2) => u1.toString().compareTo(u2.toString());
