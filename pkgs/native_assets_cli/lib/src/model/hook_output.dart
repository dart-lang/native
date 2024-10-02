// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/build_output.dart';

final class HookOutputImpl implements BuildOutput, LinkOutput {
  @override
  final DateTime timestamp;

  final List<EncodedAsset> _assets;

  @override
  Iterable<EncodedAsset> get encodedAssets => _assets;

  final Map<String, List<EncodedAsset>> _assetsForLinking;

  @override
  Map<String, List<EncodedAsset>> get encodedAssetsForLinking =>
      _assetsForLinking;

  final Dependencies _dependencies;

  Dependencies get dependenciesModel => _dependencies;

  @override
  Iterable<Uri> get dependencies => _dependencies.dependencies;

  final Metadata metadata;

  HookOutputImpl({
    DateTime? timestamp,
    Iterable<EncodedAsset>? encodedAssets,
    Map<String, List<EncodedAsset>>? encodedAssetsForLinking,
    Dependencies? dependencies,
    Metadata? metadata,
  })  : timestamp = (timestamp ?? DateTime.now()).roundDownToSeconds(),
        _assets = [
          ...?encodedAssets,
        ],
        _assetsForLinking = encodedAssetsForLinking ?? {},
        // ignore: prefer_const_constructors
        _dependencies = dependencies ?? Dependencies([]),
        // ignore: prefer_const_constructors
        metadata = metadata ?? Metadata({});

  @override
  void addDependency(Uri dependency) =>
      _dependencies.dependencies.add(dependency);

  @override
  void addDependencies(Iterable<Uri> dependencies) =>
      _dependencies.dependencies.addAll(dependencies);

  static const _assetsKey = 'assets';
  static const _assetsForLinkingKey = 'assetsForLinking';
  static const _dependenciesKey = 'dependencies';
  static const _metadataKey = 'metadata';
  static const _timestampKey = 'timestamp';
  static const _versionKey = 'version';

  factory HookOutputImpl.fromJsonString(String jsonString) {
    final Object? json = jsonDecode(jsonString);
    return HookOutputImpl.fromJson(as<Map<String, Object?>>(json));
  }

  factory HookOutputImpl.fromJson(Map<String, Object?> jsonMap) {
    final outputVersion = Version.parse(get<String>(jsonMap, 'version'));
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
    return HookOutputImpl(
      timestamp: DateTime.parse(get<String>(jsonMap, _timestampKey)),
      encodedAssets: [
        for (final json in jsonMap.optionalList(_assetsKey) ?? [])
          EncodedAsset.fromJson(json as Map<String, Object?>),
      ],
      encodedAssetsForLinking: {
        for (final MapEntry(:key, :value)
            in (get<Map<String, Object?>?>(jsonMap, _assetsForLinkingKey) ?? {})
                .entries)
          key: [
            for (final json in value as List<Object?>)
              EncodedAsset.fromJson(json as Map<String, Object?>),
          ],
      },
      dependencies:
          Dependencies.fromJson(get<List<Object?>?>(jsonMap, _dependenciesKey)),
      metadata:
          Metadata.fromJson(get<Map<Object?, Object?>?>(jsonMap, _metadataKey)),
    );
  }

  Map<String, Object> toJson(Version version) => {
        _timestampKey: timestamp.toString(),
        if (_assets.isNotEmpty)
          _assetsKey: [
            for (final asset in encodedAssets) asset.toJson(),
          ],
        if (_assetsForLinking.isNotEmpty)
          _assetsForLinkingKey: {
            for (final MapEntry(:key, :value)
                in encodedAssetsForLinking.entries)
              key: [for (final asset in value) asset.toJson()],
          },
        if (_dependencies.dependencies.isNotEmpty)
          _dependenciesKey: _dependencies.toJson(),
        if (metadata.metadata.isNotEmpty) _metadataKey: metadata.toJson(),
        _versionKey: version.toString(),
      }..sortOnKey();

  String toJsonString(Version version) =>
      const JsonEncoder.withIndent('  ').convert(toJson(version));

  /// The version of [HookOutputImpl].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs and
  /// packages through build hook invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the JSON
  /// representation in the protocol.
  ///
  /// [BuildOutput.latestVersion] is tied to [BuildConfig.latestVersion]. This
  /// enables making the JSON serialization in build hooks dependent on the
  /// version of the Dart or Flutter SDK. When there is a need to split the
  /// versions of BuildConfig and BuildOutput, the BuildConfig should start
  /// passing the highest supported version of BuildOutput.
  static Version latestVersion = HookConfigImpl.latestVersion;

  /// Reads the JSON file from [file].
  static HookOutputImpl? readFromFile({required Uri file}) {
    final buildOutputFile = File.fromUri(file);
    if (buildOutputFile.existsSync()) {
      return HookOutputImpl.fromJsonString(buildOutputFile.readAsStringSync());
    }

    return null;
  }

  /// Writes the [toJsonString] to the output file specified in the [config].
  Future<void> writeToFile({required HookConfigImpl config}) async {
    final configVersion = config.version;
    final jsonString = toJsonString(configVersion);
    await File.fromUri(config.outputFile)
        .writeAsStringCreateDirectory(jsonString);
  }

  @override
  String toString() => toJsonString(HookConfigImpl.latestVersion);

  @override
  bool operator ==(Object other) {
    if (other is! HookOutputImpl) {
      return false;
    }
    return other.timestamp == timestamp &&
        const ListEquality<EncodedAsset>().equals(other._assets, _assets) &&
        other._dependencies == _dependencies &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => Object.hash(
        timestamp.hashCode,
        const ListEquality<EncodedAsset>().hash(_assets),
        _dependencies,
        metadata,
      );

  @override
  void addMetadatum(String key, Object value) {
    metadata.metadata[key] = value;
  }

  @override
  void addMetadata(Map<String, Object> metadata) {
    this.metadata.metadata.addAll(metadata);
  }

  Metadata get metadataModel => metadata;

  @override
  void addEncodedAsset(EncodedAsset asset, {String? linkInPackage}) {
    _getEncodedAssetList(linkInPackage).add(asset);
  }

  @override
  void addEncodedAssets(Iterable<EncodedAsset> assets,
      {String? linkInPackage}) {
    _getEncodedAssetList(linkInPackage).addAll(assets.cast());
  }

  List<EncodedAsset> _getEncodedAssetList(String? linkInPackage) =>
      linkInPackage == null
          ? _assets
          : (_assetsForLinking[linkInPackage] ??= []);

  HookOutputImpl copyWith({Iterable<EncodedAsset>? encodedAssets}) =>
      HookOutputImpl(
        timestamp: timestamp,
        encodedAssets: encodedAssets?.toList() ?? _assets,
        encodedAssetsForLinking: encodedAssetsForLinking,
        dependencies: _dependencies,
        metadata: metadata,
      );
}
