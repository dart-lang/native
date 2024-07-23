// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:collection/collection.dart';

import '../utils/file.dart';
import '../utils/json.dart';
import '../utils/uri.dart';
import '../api/asset.dart';

class Dependencies {
  /// The dependencies a hook relied on.
  ///
  /// Combines all dependencies the [assetDependencies] and
  /// [assetTypeDependencies].
  List<Uri> get dependencies => [
        for (final dependencies in [
          ...assetDependencies.values,
          ...assetTypeDependencies.values,
        ])
          for (final dependency in dependencies) dependency,
      ].toSet().toList()
        ..sort(_uriCompare);

  int _uriCompare(Uri u1, Uri u2) => u1.toString().compareTo(u2.toString());

  final Map<String, Iterable<Uri>> assetDependencies;

  void addAssetDependencies(String assetId, Iterable<Uri> dependencies) {
    assetDependencies[assetId] = [
      ...?assetDependencies[assetId],
      ...dependencies,
    ];
  }

  void addAssetTypeDependencies(String assetType, Iterable<Uri> dependencies) {
    assetTypeDependencies[assetType] = [
      ...?assetTypeDependencies[assetType],
      ...dependencies,
    ];
  }

  final Map<String, Iterable<Uri>> assetTypeDependencies;

  const Dependencies({
    required this.assetDependencies,
    required this.assetTypeDependencies,
  });

  static const _assetDependenciesKey = 'assets';
  static const _assetTypeDependenciesKey = 'asset_types';

  factory Dependencies.fromJson(Map<Object?, Object?>? jsonMap) {
    if (jsonMap == null) {
      return Dependencies(
        assetDependencies: {},
        assetTypeDependencies: {},
      );
    }
    return Dependencies(
      assetDependencies: _readDependenciesMap(get(
        jsonMap,
        _assetDependenciesKey,
      )),
      assetTypeDependencies: _readDependenciesMap(get(
        jsonMap,
        _assetTypeDependenciesKey,
      )),
    );
  }

  static Map<String, Iterable<Uri>> _readDependenciesMap(
          Map<Object?, Object?>? assetDependenciesMap) =>
      {
        if (assetDependenciesMap != null)
          for (final entry in assetDependenciesMap.entries)
            as<String>(entry.key): [
              for (final uri in as<List<Object?>>(entry.value))
                fileSystemPathToUri(as<String>(uri)),
            ],
      };

  factory Dependencies.fromJsonV1_5(
    List<Object?>? jsonList,
    Iterable<String> assetIds,
  ) {
    final dependencies = [
      if (jsonList != null)
        for (final dependency in jsonList)
          fileSystemPathToUri(as<String>(dependency)),
    ];
    return Dependencies(
      assetDependencies: {
        for (final assetId in assetIds) assetId: dependencies,
      },
      assetTypeDependencies: {
        for (final assetType in [NativeCodeAsset.type, DataAsset.type])
          assetType: dependencies,
      },
    );
  }

  Map<String, Map<String, List<String>>> toJson() => {
        _assetDependenciesKey: {
          for (final entry in assetDependencies.entries)
            entry.key: toJsonList(entry.value),
        },
        _assetTypeDependenciesKey: {
          for (final entry in assetTypeDependencies.entries)
            entry.key: toJsonList(entry.value),
        },
      };

  List<String> toJsonV1_5() => toJsonList(
        assetDependencies.values
            .expand((e) => e)
            .followedBy(assetTypeDependencies.values.expand((e) => e))
            .toSet(),
      );

  static List<String> toJsonList(Iterable<Uri> dependencies) => [
        for (final dependency in dependencies) dependency.toFilePath(),
      ]..sort();

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJsonV1_5());

  Future<DateTime> lastModified() =>
      dependencies.map((u) => u.fileSystemEntity).lastModified();

  @override
  bool operator ==(Object other) {
    if (other is! Dependencies) {
      return false;
    }
    return const ListEquality<Uri>().equals(other.dependencies, dependencies);
  }

  @override
  int get hashCode => const ListEquality<Uri>().hash(dependencies);
}
