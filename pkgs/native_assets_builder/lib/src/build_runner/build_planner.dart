// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io' show Process;

import 'package:file/file.dart';
import 'package:graphs/graphs.dart' as graphs;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:package_config/package_config.dart';

import '../package_layout/package_layout.dart';

@internal
class NativeAssetsBuildPlanner {
  final PackageGraph packageGraph;
  final Uri dartExecutable;
  final Logger logger;
  final PackageLayout packageLayout;
  final FileSystem fileSystem;

  NativeAssetsBuildPlanner._({
    required this.packageGraph,
    required this.dartExecutable,
    required this.logger,
    required this.packageLayout,
    required this.fileSystem,
  });

  static Future<NativeAssetsBuildPlanner> fromPackageConfigUri({
    required Uri packageConfigUri,
    required Uri dartExecutable,
    required Logger logger,
    required PackageLayout packageLayout,
    required FileSystem fileSystem,
  }) async {
    final workingDirectory = packageConfigUri.resolve('../');
    final result = await Process.run(dartExecutable.toFilePath(), [
      'pub',
      'deps',
      '--json',
    ], workingDirectory: workingDirectory.toFilePath());
    final packageGraph = PackageGraph.fromPubDepsJsonString(
      result.stdout as String,
    );
    final packageGraphFromRunPackage = packageGraph.subGraph(
      packageLayout.runPackageName,
    );
    return NativeAssetsBuildPlanner._(
      packageGraph: packageGraphFromRunPackage,
      dartExecutable: dartExecutable,
      logger: logger,
      packageLayout: packageLayout,
      fileSystem: fileSystem,
    );
  }

  /// All packages in [PackageLayout.packageConfig] with native assets.
  ///
  /// Whether a package has native assets is defined by whether it contains
  /// a `hook/build.dart` or `hook/link.dart`.
  ///
  /// For backwards compatibility, a toplevel `build.dart` is also supported.
  // TODO(https://github.com/dart-lang/native/issues/823): Remove fallback when
  // everyone has migrated. (Probably once we stop backwards compatibility of
  // the protocol version pre 1.2.0 on some future version.)
  Future<List<Package>> packagesWithHook(Hook hook) async => switch (hook) {
    Hook.build => _packagesWithBuildHook ??= await _runPackagesWithHook(hook),
    Hook.link => _packagesWithLinkHook ??= await _runPackagesWithHook(hook),
  };

  List<Package>? _packagesWithBuildHook;
  List<Package>? _packagesWithLinkHook;

  Future<List<Package>> _runPackagesWithHook(Hook hook) async {
    final packageNamesInDependencies = packageGraph.vertices.toSet();
    final result = <Package>[];
    for (final package in packageLayout.packageConfig.packages) {
      if (!packageNamesInDependencies.contains(package.name)) {
        continue;
      }
      final packageRoot = package.root;
      if (packageRoot.scheme == 'file') {
        if (await fileSystem
                .file(packageRoot.resolve('hook/').resolve(hook.scriptName))
                .exists() ||
            await fileSystem
                .file(packageRoot.resolve(hook.scriptName))
                .exists()) {
          result.add(package);
        }
      }
    }
    return result;
  }

  List<Package>? _buildHookPlan;

  /// Plans in what order to run build hooks.
  ///
  /// [PackageLayout.runPackageName] provides the entry-point in the graph. The
  /// hooks of packages not in the transitive dependencies of
  /// [PackageLayout.runPackageName] will not be run.
  Future<List<Package>?> makeBuildHookPlan() async {
    if (_buildHookPlan != null) return _buildHookPlan;
    final packagesWithNativeAssets = await packagesWithHook(Hook.build);
    final packageMap = {
      for (final package in packagesWithNativeAssets) package.name: package,
    };
    final packagesToBuild = packageMap.keys.toSet();
    final stronglyConnectedComponents = packageGraph.computeStrongComponents();
    final result = <Package>[];
    for (final stronglyConnectedComponent in stronglyConnectedComponents) {
      final stronglyConnectedComponentWithNativeAssets = [
        for (final packageName in stronglyConnectedComponent)
          if (packagesToBuild.contains(packageName)) packageName,
      ];
      if (stronglyConnectedComponentWithNativeAssets.length > 1) {
        logger.severe(
          'Cyclic dependency for native asset builds in the following '
          'packages: $stronglyConnectedComponentWithNativeAssets.',
        );
        return null;
      } else if (stronglyConnectedComponentWithNativeAssets.length == 1) {
        result.add(
          packageMap[stronglyConnectedComponentWithNativeAssets.single]!,
        );
      }
    }
    _buildHookPlan = result;
    return result;
  }
}

/// A graph of package dependencies.
///
/// This is encoded as a mapping from package name to list of package
/// dependencies.
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
      final dependencies =
          (package_['dependencies'] as List<dynamic>)
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
          ],
    });
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('PackageGraph(');
    for (final node in vertices) {
      buffer.writeln('  $node ->');
      for (final neighbor in neighborsOf(node)) {
        buffer.writeln('    $neighbor');
      }
    }
    buffer.writeln(')');
    return buffer.toString();
  }
}
