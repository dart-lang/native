// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/build_output.dart';

final class BuildOutputImpl implements BuildOutput {
  @override
  final DateTime timestamp;

  final List<AssetImpl> _assets;

  @override
  Iterable<AssetImpl> get assets => _assets;

  final Dependencies _dependencies;

  Dependencies get dependenciesModel => _dependencies;

  @override
  Iterable<Uri> get dependencies => _dependencies.dependencies;

  final Metadata _metadata;

  BuildOutputImpl({
    DateTime? timestamp,
    List<AssetImpl>? assets,
    Dependencies? dependencies,
    Metadata? metadata,
  })  : timestamp = (timestamp ?? DateTime.now()).roundDownToSeconds(),
        _assets = assets ?? [],
        // ignore: prefer_const_constructors
        _dependencies = dependencies ?? Dependencies([]),
        // ignore: prefer_const_constructors
        _metadata = metadata ?? Metadata({});

  @override
  void addDependency(Uri dependency) =>
      _dependencies.dependencies.add(dependency);

  @override
  void addDependencies(Iterable<Uri> dependencies) =>
      _dependencies.dependencies.addAll(dependencies);

  static const _assetsKey = 'assets';
  static const _dependenciesKey = 'dependencies';
  static const _metadataKey = 'metadata';
  static const _timestampKey = 'timestamp';
  static const _versionKey = 'version';

  factory BuildOutputImpl.fromYamlString(String yaml) {
    final yamlObject = loadYaml(yaml);
    return BuildOutputImpl.fromYaml(as<YamlMap>(yamlObject));
  }

  factory BuildOutputImpl.fromYaml(YamlMap yamlMap) {
    final outputVersion = Version.parse(as<String>(yamlMap['version']));
    if (outputVersion.major > latestVersion.major) {
      throw FormatException(
        'The output version $outputVersion is newer than the '
        'package:native_assets_cli config version $latestVersion in Dart or '
        'Flutter, please update the Dart or Flutter SDK.',
      );
    }
    if (outputVersion.major < latestVersion.major) {
      throw FormatException(
        'The output version $outputVersion is newer than this '
        'package:native_assets_cli config version $latestVersion in Dart or '
        'Flutter, please update native_assets_cli.',
      );
    }

    final assets =
        AssetImpl.listFromYamlList(as<YamlList>(yamlMap[_assetsKey]));

    return BuildOutputImpl(
      timestamp: DateTime.parse(as<String>(yamlMap[_timestampKey])),
      assets: assets,
      dependencies:
          Dependencies.fromYaml(as<YamlList?>(yamlMap[_dependenciesKey])),
      metadata: Metadata.fromYaml(as<YamlMap?>(yamlMap[_metadataKey])),
    );
  }

  Map<String, Object> toYaml(Version version) => {
        _timestampKey: timestamp.toString(),
        _assetsKey: [
          for (final asset in _assets) asset.toYaml(version),
        ],
        if (_dependencies.dependencies.isNotEmpty)
          _dependenciesKey: _dependencies.toYaml(),
        _metadataKey: _metadata.toYaml(),
        _versionKey: version.toString(),
      }..sortOnKey();

  String toYamlString(Version version) => yamlEncode(toYaml(version));

  /// The version of [BuildOutputImpl].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs and
  /// packages through `build.dart` invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the YAML
  /// representation in the protocol.
  ///
  /// [BuildOutput.latestVersion] is tied to [BuildConfig.latestVersion]. This
  /// enables making the yaml serialization in `build.dart` dependent on the
  /// version of the Dart or Flutter SDK. When there is a need to split the
  /// versions of BuildConfig and BuildOutput, the BuildConfig should start
  /// passing the highest supported version of BuildOutput.
  static Version latestVersion = BuildConfigImpl.latestVersion;

  static const fileName = 'build_output.yaml';

  /// Reads the YAML file from [outDir]/[fileName].
  static Future<BuildOutputImpl?> readFromFile({required Uri outDir}) async {
    final buildOutputUri = outDir.resolve(fileName);
    final buildOutputFile = File.fromUri(buildOutputUri);
    if (!await buildOutputFile.exists()) {
      return null;
    }
    return BuildOutputImpl.fromYamlString(await buildOutputFile.readAsString());
  }

  /// Writes the [toYamlString] to [BuildConfig.outDir]/[fileName].
  @override
  Future<void> writeToFile({required BuildConfig config}) async {
    final outDir = config.outDir;
    final buildOutputUri = outDir.resolve(fileName);
    final yamlString = toYamlString((config as BuildConfigImpl).version);
    await File.fromUri(buildOutputUri).writeAsStringCreateDirectory(yamlString);
  }

  @override
  String toString() => toYamlString(BuildConfigImpl.latestVersion);

  @override
  bool operator ==(Object other) {
    if (other is! BuildOutputImpl) {
      return false;
    }
    return other.timestamp == timestamp &&
        const ListEquality<AssetImpl>().equals(other._assets, _assets) &&
        other._dependencies == _dependencies &&
        other._metadata == _metadata;
  }

  @override
  int get hashCode => Object.hash(
        timestamp.hashCode,
        const ListEquality<AssetImpl>().hash(_assets),
        _dependencies,
        _metadata,
      );

  @override
  void addMetadatum(String key, Object value) {
    _metadata.metadata[key] = value;
  }

  @override
  void addMetadata(Map<String, Object> metadata) {
    _metadata.metadata.addAll(metadata);
  }

  Metadata get metadataModel => _metadata;

  @override
  void addAsset(Asset asset) {
    _assets.add(asset as AssetImpl);
  }

  @override
  void addAssets(Iterable<Asset> assets) {
    _assets.addAll(assets.cast());
  }
}
