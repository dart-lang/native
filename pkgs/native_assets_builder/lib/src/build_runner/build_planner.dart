// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:graphs/graphs.dart' as graphs;
import 'package:logging/logging.dart';
import 'package:package_config/package_config.dart';

class NativeAssetsPlanner {
  final DependencyGraph dependencyGraph;
  final List<Package> packagesWithNativeAssets;
  final Uri dartExecutable;
  final Logger logger;

  NativeAssetsPlanner({
    required this.dependencyGraph,
    required this.packagesWithNativeAssets,
    required this.dartExecutable,
    required this.logger,
  });

  static Future<NativeAssetsPlanner> fromRootPackageRoot({
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
    final dependencyGraph =
        DependencyGraph.fromPubDepsJsonString(result.stdout as String);
    return NativeAssetsPlanner(
      dependencyGraph: dependencyGraph,
      packagesWithNativeAssets: packagesWithNativeAssets,
      dartExecutable: dartExecutable,
      logger: logger,
    );
  }

  (List<Package> packages, bool success) plan() {
    final packageMap = {
      for (final package in packagesWithNativeAssets) package.name: package
    };
    final packagesToBuild = packageMap.keys.toSet();
    final stronglyConnectedComponents =
        dependencyGraph.computeStrongComponents();
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

/// A graph of package dependencies, encoded as package name -> list of package
/// dependencies.
class DependencyGraph {
  final Map<String, List<String>> map;

  DependencyGraph(this.map);

  /// Construct a graph from the JSON produced by `dart pub deps --json`.
  factory DependencyGraph.fromPubDepsJsonString(String json) =>
      DependencyGraph.fromPubDepsJson(
          jsonDecode(json) as Map<dynamic, dynamic>);

  /// Construct a graph from the JSON produced by `dart pub deps --json`.
  factory DependencyGraph.fromPubDepsJson(Map<dynamic, dynamic> map) {
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
    return DependencyGraph(result);
  }

  Iterable<String> neighborsOf(String vertex) => map[vertex] ?? [];

  Iterable<String> get vertices => map.keys;

  List<List<String>> computeStrongComponents() =>
      graphs.stronglyConnectedComponents(vertices, neighborsOf);
}
