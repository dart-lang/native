// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import '../api/build_output.dart' as api;
import '../utils/datetime.dart';
import '../utils/file.dart';
import '../utils/map.dart';
import '../utils/yaml.dart';
import 'asset.dart';
import 'dependencies.dart';
import 'metadata.dart';

class BuildOutput implements api.BuildOutput {
  /// Time the build this output belongs to started.
  ///
  /// Rounded down to whole seconds, because [File.lastModified] is rounded
  /// to whole seconds and caching logic compares these timestamps.
  @override
  final DateTime timestamp;
  @override
  final List<Asset> assets;
  @override
  final Dependencies dependencies;
  @override
  final Metadata metadata;

  BuildOutput({
    DateTime? timestamp,
    List<Asset>? assets,
    Dependencies? dependencies,
    Metadata? metadata,
  })  : timestamp = (timestamp ?? DateTime.now()).roundDownToSeconds(),
        assets = assets ?? [],
        // ignore: prefer_const_constructors
        dependencies = dependencies ?? Dependencies([]),
        // ignore: prefer_const_constructors
        metadata = metadata ?? Metadata({});

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
        _assetsKey: assets.toYaml(),
        _dependenciesKey: dependencies.toYaml(),
        _metadataKey: metadata.toYaml(),
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

  /// Writes the YAML file from [outputUri].
  static Future<BuildOutput?> readFromFile({required Uri outputUri}) async {
    final buildOutputFile = File.fromUri(outputUri);
    if (!await buildOutputFile.exists()) {
      return null;
    }
    return BuildOutput.fromYamlString(await buildOutputFile.readAsString());
  }

  /// Writes the [toYamlString] to [output].
  @override
  Future<void> writeToFile({required Uri output}) async {
    await File.fromUri(output).writeAsStringCreateDirectory(toYamlString());
  }

  @override
  String toString() => toYamlString();

  @override
  bool operator ==(Object other) {
    if (other is! BuildOutput) {
      return false;
    }
    return other.timestamp == timestamp &&
        const ListEquality<Asset>().equals(other.assets, assets) &&
        other.dependencies == dependencies &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => Object.hash(
        timestamp.hashCode,
        const ListEquality<Asset>().hash(assets),
        dependencies,
        metadata,
      );
}
