// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import '../api/asset.dart' as api;
import '../api/build_output.dart' as api;
import '../utils/datetime.dart';
import '../utils/file.dart';
import '../utils/map.dart';
import '../utils/yaml.dart';
import 'asset.dart';
import 'dependencies.dart';
import 'metadata.dart';

class BuildOutput implements api.BuildOutput {
  @override
  final DateTime timestamp;

  final List<Asset> _assets;

  @override
  Iterable<Asset> get assets => _assets;

  final Dependencies _dependencies;

  Dependencies get dependenciesModel => _dependencies;

  @override
  Iterable<Uri> get dependencies => _dependencies.dependencies;

  final Metadata _metadata;

  BuildOutput({
    DateTime? timestamp,
    List<Asset>? assets,
    Dependencies? dependencies,
    Metadata? metadata,
  })  : timestamp = (timestamp ?? DateTime.now()).roundDownToSeconds(),
        _assets = assets ?? [],
        // ignore: prefer_const_constructors
        _dependencies = dependencies ?? Dependencies([]),
        // ignore: prefer_const_constructors
        _metadata = metadata ?? Metadata({});

  @override
  void addDependencies(Iterable<Uri> dependencies) =>
      _dependencies.dependencies.addAll(dependencies);

  static const _assetsKey = 'assets';
  static const _dependenciesKey = 'dependencies';
  static const _metadataKey = 'metadata';
  static const _timestampKey = 'timestamp';
  static const _versionKey = 'version';

  factory BuildOutput.fromYamlString(String yaml) {
    final yamlObject = loadYaml(yaml);
    return BuildOutput.fromYaml(as<YamlMap>(yamlObject));
  }

  factory BuildOutput.fromYaml(YamlMap yamlMap) {
    final outputVersion = Version.parse(as<String>(yamlMap['version']));
    if (outputVersion.major > version.major) {
      throw FormatException(
        'The output version $outputVersion is newer than the '
        'package:native_assets_cli config version $version in Dart or Flutter, '
        'please update the Dart or Flutter SDK.',
      );
    }
    if (outputVersion.major < version.major) {
      throw FormatException(
        'The output version $outputVersion is newer than this '
        'package:native_assets_cli config version $version in Dart or Flutter, '
        'please update native_assets_cli.',
      );
    }

    return BuildOutput(
      timestamp: DateTime.parse(as<String>(yamlMap[_timestampKey])),
      assets: Asset.listFromYamlList(as<YamlList>(yamlMap[_assetsKey])),
      dependencies:
          Dependencies.fromYaml(as<YamlList?>(yamlMap[_dependenciesKey])),
      metadata: Metadata.fromYaml(as<YamlMap?>(yamlMap[_metadataKey])),
    );
  }

  Map<String, Object> toYaml() => {
        _timestampKey: timestamp.toString(),
        _assetsKey: _assets.toYaml(),
        if (_dependencies.dependencies.isNotEmpty)
          _dependenciesKey: _dependencies.toYaml(),
        _metadataKey: _metadata.toYaml(),
        _versionKey: version.toString(),
      }..sortOnKey();

  String toYamlString() => yamlEncode(toYaml());

  /// The version of [BuildOutput].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through `build.dart` invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the YAML
  /// representation in the protocol.
  static Version version = Version(1, 0, 0);

  static const fileName = 'build_output.yaml';

  /// Writes the YAML file from [outDir]/[fileName].
  static Future<BuildOutput?> readFromFile({required Uri outDir}) async {
    final buildOutputUri = outDir.resolve(fileName);
    final buildOutputFile = File.fromUri(buildOutputUri);
    if (!await buildOutputFile.exists()) {
      return null;
    }
    return BuildOutput.fromYamlString(await buildOutputFile.readAsString());
  }

  /// Writes the [toYamlString] to [outDir]/[fileName].
  @override
  Future<void> writeToFile({required Uri outDir}) async {
    final buildOutputUri = outDir.resolve(fileName);
    await File.fromUri(buildOutputUri)
        .writeAsStringCreateDirectory(toYamlString());
  }

  @override
  String toString() => toYamlString();

  @override
  bool operator ==(Object other) {
    if (other is! BuildOutput) {
      return false;
    }
    return other.timestamp == timestamp &&
        const ListEquality<Asset>().equals(other._assets, _assets) &&
        other._dependencies == _dependencies &&
        other._metadata == _metadata;
  }

  @override
  int get hashCode => Object.hash(
        timestamp.hashCode,
        const ListEquality<Asset>().hash(_assets),
        _dependencies,
        _metadata,
      );

  @override
  void addMetadata(String key, Object value) {
    _metadata.metadata[key] = value;
  }

  @override
  Object? metadata(String key) => _metadata.metadata[key];

  Metadata get metadataModel => _metadata;

  @override
  void addAssets(Iterable<api.Asset> assets) {
    _assets.addAll(assets.cast());
  }
}
