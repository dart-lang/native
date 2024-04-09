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

  factory BuildOutputImpl.fromJsonString(String jsonString) {
    final Object? json;
    if (jsonString.startsWith('{')) {
      json = jsonDecode(jsonString);
    } else {
      // TODO(https://github.com/dart-lang/native/issues/1000): At some point
      // remove the YAML fallback.
      json = loadYaml(jsonString);
    }
    return BuildOutputImpl.fromJson(as<Map<Object?, Object?>>(json));
  }

  factory BuildOutputImpl.fromJson(Map<Object?, Object?> jsonMap) {
    final outputVersion = Version.parse(as<String>(jsonMap['version']));
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
        AssetImpl.listFromJsonList(as<List<Object?>>(jsonMap[_assetsKey]));

    return BuildOutputImpl(
      timestamp: DateTime.parse(as<String>(jsonMap[_timestampKey])),
      assets: assets,
      dependencies:
          Dependencies.fromJson(as<List<Object?>?>(jsonMap[_dependenciesKey])),
      metadata:
          Metadata.fromJson(as<Map<Object?, Object?>?>(jsonMap[_metadataKey])),
    );
  }

  Map<String, Object> toJson(Version version) {
    final assets = <AssetImpl>[];
    for (final asset in _assets) {
      switch (asset) {
        case NativeCodeAssetImpl _:
          if (version <= Version(1, 0, 0) && asset.architecture == null) {
            // Dry run does not report architecture. But old Dart and Flutter
            // expect architecture to be populated. So, populate assets for all
            // architectures.
            for (final architecture in asset.os.architectures) {
              assets.add(asset.copyWith(
                architecture: architecture,
              ));
            }
          } else {
            assets.add(asset);
          }
        default:
          assets.add(asset);
      }
    }
    return {
      _timestampKey: timestamp.toString(),
      _assetsKey: [
        for (final asset in assets) asset.toJson(version),
      ],
      if (_dependencies.dependencies.isNotEmpty)
        _dependenciesKey: _dependencies.toJson(),
      _metadataKey: _metadata.toJson(),
      _versionKey: version.toString(),
    }..sortOnKey();
  }

  String toJsonString(Version version) =>
      const JsonEncoder.withIndent('  ').convert(toJson(version));

  /// The version of [BuildOutputImpl].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs and
  /// packages through build hook invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the YAML
  /// representation in the protocol.
  ///
  /// [BuildOutput.latestVersion] is tied to [BuildConfig.latestVersion]. This
  /// enables making the JSON serialization in build hooks dependent on the
  /// version of the Dart or Flutter SDK. When there is a need to split the
  /// versions of BuildConfig and BuildOutput, the BuildConfig should start
  /// passing the highest supported version of BuildOutput.
  static Version latestVersion = BuildConfigImpl.latestVersion;

  static const fileName = 'build_output.json';
  static const fileNameV1_1_0 = 'build_output.yaml';

  /// Reads the JSON file from [outDir]/[fileName].
  static Future<BuildOutputImpl?> readFromFile({required Uri outDir}) async {
    final buildOutputUri = outDir.resolve(fileName);
    final buildOutputFile = File.fromUri(buildOutputUri);
    if (await buildOutputFile.exists()) {
      return BuildOutputImpl.fromJsonString(
          await buildOutputFile.readAsString());
    }

    final buildOutputUriV1_1_0 = outDir.resolve(fileNameV1_1_0);
    final buildOutputFileV1_1_0 = File.fromUri(buildOutputUriV1_1_0);
    if (await buildOutputFileV1_1_0.exists()) {
      return BuildOutputImpl.fromJsonString(
          await buildOutputFileV1_1_0.readAsString());
    }

    return null;
  }

  /// Writes the [toJsonString] to [BuildConfig.outputDirectory]/[fileName].
  Future<void> writeToFile({required BuildConfig config}) async {
    final configVersion = (config as BuildConfigImpl).version;
    final outDir = config.outputDirectory;
    final Uri buildOutputUri;
    if (configVersion <= Version(1, 1, 0)) {
      buildOutputUri = outDir.resolve(fileNameV1_1_0);
    } else {
      buildOutputUri = outDir.resolve(fileName);
    }
    final jsonString = toJsonString(configVersion);
    await File.fromUri(buildOutputUri).writeAsStringCreateDirectory(jsonString);
  }

  @override
  String toString() => toJsonString(BuildConfigImpl.latestVersion);

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
