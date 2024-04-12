// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/build_output.dart';

final class HookOutputImpl implements BuildOutput, LinkOutput {
  @override
  final DateTime timestamp;

  final List<AssetImpl> _assets;

  @override
  Iterable<AssetImpl> get assets => _assets;

  final Map<String, List<AssetImpl>> _assetsForLinking;

  @override
  Map<String, List<AssetImpl>> get assetsForLinking => _assetsForLinking;

  final Dependencies _dependencies;

  Dependencies get dependenciesModel => _dependencies;

  @override
  Iterable<Uri> get dependencies => _dependencies.dependencies;

  final Metadata metadata;

  HookOutputImpl({
    DateTime? timestamp,
    List<AssetImpl>? assets,
    Map<String, List<AssetImpl>>? assetsForLinking,
    Dependencies? dependencies,
    Metadata? metadata,
  })  : timestamp = (timestamp ?? DateTime.now()).roundDownToSeconds(),
        _assets = assets ?? [],
        _assetsForLinking = assetsForLinking ?? {},
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
    final Object? json;
    if (jsonString.startsWith('{')) {
      json = jsonDecode(jsonString);
    } else {
      // TODO(https://github.com/dart-lang/native/issues/1000): At some point
      // remove the YAML fallback.
      json = loadYaml(jsonString);
    }
    return HookOutputImpl.fromJson(as<Map<Object?, Object?>>(json));
  }

  factory HookOutputImpl.fromJson(Map<Object?, Object?> jsonMap) {
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
    return HookOutputImpl(
      timestamp: DateTime.parse(as<String>(jsonMap[_timestampKey])),
      assets: AssetImpl.listFromJson(as<List<Object?>?>(jsonMap[_assetsKey])),
      assetsForLinking: as<Map<String, dynamic>?>(jsonMap[_assetsForLinkingKey])
          ?.map((packageName, assets) => MapEntry(
              packageName, AssetImpl.listFromJson(as<List<Object?>>(assets)))),
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
    final linkMinVersion = Version(1, 3, 0);
    if (_assetsForLinking.isNotEmpty && version < linkMinVersion) {
      throw UnsupportedError('Please update your Dart SDK to link assets in '
          '`link.dart` scripts. Your current version is $version, but this '
          'feature requires $linkMinVersion');
    }
    return {
      _timestampKey: timestamp.toString(),
      if (assets.isNotEmpty) _assetsKey: AssetImpl.listToJson(assets, version),
      if (version >= linkMinVersion && _assetsForLinking.isNotEmpty)
        _assetsForLinkingKey:
            _assetsForLinking.map((packageName, assets) => MapEntry(
                  packageName,
                  AssetImpl.listToJson(assets, version),
                )),
      if (_dependencies.dependencies.isNotEmpty)
        _dependenciesKey: _dependencies.toJson(),
      if (metadata.metadata.isNotEmpty) _metadataKey: metadata.toJson(),
      _versionKey: version.toString(),
    }..sortOnKey();
  }

  String toJsonString(Version version) =>
      const JsonEncoder.withIndent('  ').convert(toJson(version));

  /// The version of [HookOutputImpl].
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

  /// Writes the JSON file from [file].
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
  String toString() => toJsonString(BuildConfigImpl.latestVersion);

  @override
  bool operator ==(Object other) {
    if (other is! HookOutputImpl) {
      return false;
    }
    return other.timestamp == timestamp &&
        const ListEquality<AssetImpl>().equals(other._assets, _assets) &&
        other._dependencies == _dependencies &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => Object.hash(
        timestamp.hashCode,
        const ListEquality<AssetImpl>().hash(_assets),
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
  void addAsset(Asset asset, {String? linkInPackage}) {
    _getAssetList(linkInPackage).add(asset as AssetImpl);
  }

  @override
  void addAssets(Iterable<Asset> assets, {String? linkInPackage}) {
    _getAssetList(linkInPackage).addAll(assets.cast());
  }

  List<AssetImpl> _getAssetList(String? linkInPackage) => linkInPackage == null
      ? _assets
      : (_assetsForLinking[linkInPackage] ??= []);
}
