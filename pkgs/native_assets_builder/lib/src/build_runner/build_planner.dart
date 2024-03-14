// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:graphs/graphs.dart' as graphs;
import 'package:logging/logging.dart';
import 'package:package_config/package_config.dart';

class NativeAssetsBuildPlanner {
  final PackageGraph packageGraph;
  final List<Package> packagesWithNativeAssets;
  final Uri dartExecutable;
  final Logger logger;

  NativeAssetsBuildPlanner({
    required this.packageGraph,
    required this.packagesWithNativeAssets,
    required this.dartExecutable,
    required this.logger,
  });

  static Future<NativeAssetsBuildPlanner> fromRootPackageRoot({
    required Uri rootPackageRoot,
    required List<Package> packagesWithNativeAssets,
    required Uri dartExecutable,
    required Logger logger,
  }) async {
    final result = await Process.run(
      dartExecutable.toFilePath(),
      [
        'pub',
        'deps',
        '--json',
      ],
      workingDirectory: rootPackageRoot.toFilePath(),
    );
    final packageGraph =
        PackageGraph.fromPubDepsJsonString(result.stdout as String);
    return NativeAssetsBuildPlanner(
      packageGraph: packageGraph,
      packagesWithNativeAssets: packagesWithNativeAssets,
      dartExecutable: dartExecutable,
      logger: logger,
    );
  }

  (List<Package> packages, bool success) plan({
    String? runPackageName,
  }) {
    final PackageGraph packageGraph;
    if (runPackageName != null) {
      packageGraph = this.packageGraph.subGraph(runPackageName);
    } else {
      packageGraph = this.packageGraph;
    }
    final packageMap = {
      for (final package in packagesWithNativeAssets) package.name: package
    };
    final packagesToBuild = packageMap.keys.toSet();
    final stronglyConnectedComponents = packageGraph.computeStrongComponents();
    final result = <Package>[];
    var success = true;
    for (final stronglyConnectedComponent in stronglyConnectedComponents) {
      final stronglyConnectedComponentWithNativeAssets = [
        for (final packageName in stronglyConnectedComponent)
          if (packagesToBuild.contains(packageName)) packageName
      ];
      if (stronglyConnectedComponentWithNativeAssets.length > 1) {
        logger.severe(
          'Cyclic dependency for native asset builds in the following '
          'packages: $stronglyConnectedComponentWithNativeAssets.',
        );
        success = false;
      } else if (stronglyConnectedComponentWithNativeAssets.length == 1) {
        result.add(
            packageMap[stronglyConnectedComponentWithNativeAssets.single]!);
      }
    }
    return (result, success);
  }
}

class PackageGraph {
  final Map<String, List<String>> map;

  PackageGraph(this.map);

  /// Constructs a graph from the JSON produced by `dart pub deps --json`.
  factory PackageGraph.fromPubDepsJsonString(String json) =>
      PackageGraph.fromPubDepsJson(jsonDecode(json) as Map<dynamic, dynamic>);

  /// Constructs a graph from the JSON produced by `dart pub deps --json`.
  factory PackageGraph.fromPubDepsJson(Map<dynamic, dynamic> map) {
    final result = <String, List<String>>{};
    final packages = map['packages'] as List<dynamic>;
    for (final package in packages) {
      final package_ = package as Map<dynamic, dynamic>;
      final name = package_['name'] as String;
      final dependencies = (package_['dependencies'] as List<dynamic>)
          .whereType<String>()
          .toList();
      result[name] = dependencies;
    }
    return PackageGraph(result);
  }

  Iterable<String> neighborsOf(String vertex) => map[vertex] ?? [];

  Iterable<String> get vertices => map.keys;

  List<List<String>> computeStrongComponents() =>
      graphs.stronglyConnectedComponents(vertices, neighborsOf);

  PackageGraph subGraph(String rootPackageName) {
    if (!vertices.contains(rootPackageName)) {
      // Some downstream tooling requested a package that doesn't exist.
      // This will likely lead to an error, so avoid building native assets.
      return PackageGraph({});
    }
    final subgraphVertices = [
      ...graphs.transitiveClosure(vertices, neighborsOf)[rootPackageName]!,
      rootPackageName,
    ];
    return PackageGraph({
      for (final vertex in map.keys)
        if (subgraphVertices.contains(vertex))
          vertex: [
            for (final neighbor in map[vertex]!)
              if (subgraphVertices.contains(neighbor)) neighbor,
          ]
    });
  }
}
