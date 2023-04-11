// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cli_config/cli_config.dart';
import 'package:collection/collection.dart';

import '../utils/map.dart';
import '../utils/yaml.dart';
import 'ios_sdk.dart';
import 'metadata.dart';
import 'packaging_preference.dart';
import 'target.dart';

class BuildConfig {
  /// The folder in which all output and intermediate artifacts should be
  /// placed.
  Uri get outDir => _outDir;
  late final Uri _outDir;

  /// The root of the package the native assets are built for.
  ///
  /// Often a package's native assets are built because a package is a
  /// dependency of another. For this it is convenient to know the packageRoot.
  Uri get packageRoot => _packageRoot;
  late final Uri _packageRoot;

  /// The target that is being compiled for.
  Target get target => _target;
  late final Target _target;

  /// When compiling for iOS, whether to target device or simulator.
  ///
  /// Required when [target.os] equals [OS.iOS].
  IOSSdk? get targetIOSSdk => _targetIOSSdk;
  late final IOSSdk? _targetIOSSdk;

  /// Path to a C compiler.
  Uri? get cc => _cc;
  late final Uri? _cc;

  /// Path to a native linker.
  Uri? get ld => _ld;
  late final Uri? _ld;

  /// Preferred packaging method for library.
  PackagingPreference get packaging => _packaging;
  late final PackagingPreference _packaging;

  /// Metadata from direct dependencies.
  ///
  /// The key in the map is the package name of the dependency.
  ///
  /// The key in the nested map is the key for the metadata from the dependency.
  Map<String, Metadata>? get dependencyMetadata => _dependencyMetadata;
  late final Map<String, Metadata>? _dependencyMetadata;

  factory BuildConfig({
    required Uri outDir,
    required Uri packageRoot,
    required Target target,
    IOSSdk? targetIOSSdk,
    Uri? cc,
    Uri? ld,
    required PackagingPreference packaging,
    Map<String, Metadata>? dependencyMetadata,
  }) {
    final nonValidated = BuildConfig._()
      .._outDir = outDir
      .._packageRoot = packageRoot
      .._target = target
      .._targetIOSSdk = targetIOSSdk
      .._cc = cc
      .._ld = ld
      .._packaging = packaging
      .._dependencyMetadata = dependencyMetadata;
    final parsedConfigFile = nonValidated.toYaml();
    final config = Config(fileParsed: parsedConfigFile);
    return BuildConfig.fromConfig(config);
  }

  BuildConfig._();

  factory BuildConfig.fromConfig(Config config) {
    final result = BuildConfig._();
    final configExceptions = <Object>[];
    for (final f in result._readFieldsFromConfig()) {
      try {
        f(config);
      } on FormatException catch (e, st) {
        configExceptions.add(e);
        configExceptions.add(st);
      }
    }

    if (configExceptions.isNotEmpty) {
      throw FormatException('Configuration is not in the right format. '
          'FormatExceptions: $configExceptions');
    }

    return result;
  }

  static Future<BuildConfig> fromArgs(List<String> args) async {
    final config = await Config.fromArgs(args: args);
    return BuildConfig.fromConfig(config);
  }

  static const outDirConfigKey = 'out_dir';
  static const packageRootConfigKey = 'package_root';
  static const ccConfigKey = 'cc';
  static const ldConfigKey = 'ld';
  static const dependencyMetadataConfigKey = 'dependency_metadata';

  List<void Function(Config)> _readFieldsFromConfig() {
    var targetSet = false;
    return [
      (config) => _outDir = config.path(outDirConfigKey),
      (config) => _packageRoot = config.path(packageRootConfigKey),
      (config) {
        _target = Target.fromString(
          config.string(
            Target.configKey,
            validValues: Target.values.map((e) => '$e'),
          ),
        );
        targetSet = true;
      },
      (config) => _targetIOSSdk = (targetSet && _target.os == OS.iOS)
          ? IOSSdk.fromString(
              config.string(
                IOSSdk.configKey,
                validValues: IOSSdk.values.map((e) => '$e'),
              ),
            )
          : null,
      (config) => _cc = config.optionalPath(ccConfigKey, mustExist: true),
      (config) => _ld = config.optionalPath(ldConfigKey, mustExist: true),
      (config) => _packaging = PackagingPreference.fromString(
            config.string(
              PackagingPreference.configKey,
              validValues: PackagingPreference.values.map((e) => '$e'),
            ),
          ),
      (config) =>
          _dependencyMetadata = _readDependencyMetadataFromConfig(config)
    ];
  }

  Map<String, Metadata>? _readDependencyMetadataFromConfig(Config config) {
    final fileValue =
        config.valueOf<Map<Object?, Object?>?>(dependencyMetadataConfigKey);
    if (fileValue == null) {
      return null;
    }
    final result = <String, Metadata>{};
    for (final entry in fileValue.entries) {
      final packageName = entry.key;
      final defines = entry.value;
      if (defines is! Map) {
        throw FormatException("Unexpected value '$defines' for key "
            "'$dependencyMetadataConfigKey.$packageName' in config file. "
            'Expected a Map.');
      }
      final packageResult = <String, Object>{};
      for (final entry2 in defines.entries) {
        final key = entry2.key;
        assert(key is String);
        final value = entry2.value;
        assert(value != null);
        packageResult[key as String] = value as Object;
      }
      result[packageName as String] = Metadata(packageResult.sortOnKey());
    }
    return result.sortOnKey();
  }

  Map<String, Object> toYaml() => {
        outDirConfigKey: _outDir.path,
        packageRootConfigKey: _packageRoot.path,
        Target.configKey: _target.toString(),
        if (_targetIOSSdk != null) IOSSdk.configKey: _targetIOSSdk.toString(),
        if (_cc != null) ccConfigKey: _cc!.path,
        if (_ld != null) ldConfigKey: _ld!.path,
        PackagingPreference.configKey: _packaging.toString(),
        if (_dependencyMetadata != null)
          dependencyMetadataConfigKey: {
            for (final entry in _dependencyMetadata!.entries)
              entry.key: entry.value.toYaml(),
          },
      }.sortOnKey();

  String toYamlString() => yamlEncode(toYaml());

  @override
  bool operator ==(Object other) {
    if (other is! BuildConfig) {
      return false;
    }
    if (other._outDir != _outDir) return false;
    if (other._packageRoot != _packageRoot) return false;
    if (other._target != _target) return false;
    if (other._targetIOSSdk != _targetIOSSdk) return false;
    if (other._cc != _cc) return false;
    if (other._ld != _ld) return false;
    if (other._packaging != _packaging) return false;
    if (!DeepCollectionEquality()
        .equals(other._dependencyMetadata, _dependencyMetadata)) return false;
    return true;
  }

  // Ordering of fields doesn't matter.
  @override
  int get hashCode =>
      _outDir.hashCode ^
      _packageRoot.hashCode ^
      _target.hashCode ^
      _targetIOSSdk.hashCode ^
      _cc.hashCode ^
      _ld.hashCode ^
      _packaging.hashCode ^
      DeepCollectionEquality().hash(_dependencyMetadata);

  @override
  String toString() => 'BuildConfig(${toYaml()})';
}
