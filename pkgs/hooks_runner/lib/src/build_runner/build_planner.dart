// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:developer';

import 'package:file/file.dart';
import 'package:graphs/graphs.dart' as graphs;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart';

import '../package_layout/package_layout.dart';
import 'failure.dart';
import 'result.dart';

/// The order in which packages' build hooks should be run.
typedef BuildPlan = List<Package>;

@internal
class NativeAssetsBuildPlanner {
  final TimelineTask task;

  final PackageGraph packageGraph;
  final Uri dartExecutable;
  final Logger logger;
  final PackageLayout packageLayout;
  final FileSystem fileSystem;

  NativeAssetsBuildPlanner._({
    required this.task,
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
    TimelineTask? task,
  }) async {
    final packageGraphJsonFile = fileSystem.file(
      packageConfigUri.resolve('package_graph.json'),
    );
    assert(await packageGraphJsonFile.exists());
    final packageGraphJson = await packageGraphJsonFile.readAsString();
    final packageGraph = PackageGraph.fromPackageGraphJsonString(
      packageGraphJson,
      packageLayout.runPackageName,
      includeDevDependencies: packageLayout.includeDevDependencies,
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
      task: task ?? TimelineTask(),
    );
  }

  /// All packages in [PackageLayout.packageConfig] with native assets.
  ///
  /// Whether a package has native assets is defined by whether it contains
  /// a `hook/build.dart` or `hook/link.dart`.
  Future<List<Package>> packagesWithHook(Hook hook) async => _timeAsync(
    'BuildPlanner.packagesWithHook',
    arguments: {'hook': hook.toString()},
    () async => switch (hook) {
      Hook.build => _packagesWithBuildHook ??= await _runPackagesWithHook(hook),
      Hook.link => _packagesWithLinkHook ??= await _runPackagesWithHook(hook),
    },
  );

  List<Package>? _packagesWithBuildHook;
  List<Package>? _packagesWithLinkHook;

  Future<List<Package>> _runPackagesWithHook(Hook hook) async {
    final packageNamesInDependencies = packageGraph.vertices.toSet();
    final result = <Package>[];
    final watch = Stopwatch()..start();
    var length = 0;
    for (final package in packageLayout.packageConfig.packages) {
      if (!packageNamesInDependencies.contains(package.name)) {
        continue;
      }
      final packageRoot = package.root;
      if (packageRoot.scheme == 'file') {
        length++;
        if (await fileSystem
            .file(packageRoot.resolve('hook/').resolve(hook.scriptName))
            .exists()) {
          result.add(package);
        }
      }
    }
    watch.stop();
    logger.finest(
      'Checking $length packages for hook/${hook.scriptName} '
      'took ${watch.elapsedMilliseconds} ms.',
    );
    return result;
  }

  BuildPlan? _buildHookPlan;
  BuildPlan? _linkHookPlan;

  /// Plans in what order to run build hooks.
  ///
  /// [PackageLayout.runPackageName] provides the entry-point in the graph. The
  /// hooks of packages not in the transitive dependencies of
  /// [PackageLayout.runPackageName] will not be run.
  ///
  /// Returns a [Future] that completes with a [Result]. On success, the
  /// [Result] is a [Success] containing the [BuildPlan], which is a list of
  /// packages in the order their build hooks should be executed. On failure, if
  /// a cyclic dependency is detected among packages with native asset build
  /// hooks, the [Result] is a [Failure] containing a
  /// [HooksRunnerFailure.projectConfig].
  Future<Result<BuildPlan, HooksRunnerFailure>> makeBuildHookPlan() async =>
      _timeAsync(
        'BuildPlanner.makeBuildHookPlan',
        () async => _makeHookPlan(
          hookType: Hook.build,
          cachedPlan: _buildHookPlan,
          setCachedPlan: (plan) => _buildHookPlan = plan,
          reverseOrder: false,
        ),
      );

  /// Plans in what order to run link hooks.
  ///
  /// [PackageLayout.runPackageName] provides the entry-point in the graph. The
  /// hooks of packages not in the transitive dependencies of
  /// [PackageLayout.runPackageName] will not be run.
  ///
  /// Returns a [Future] that completes with a [Result]. On success, the
  /// [Result] is a [Success] containing the [BuildPlan], which is a list of
  /// packages in the order their link hooks should be executed. On failure, if
  /// a cyclic dependency is detected among packages with native asset link
  /// hooks, the [Result] is a [Failure] containing a
  /// [HooksRunnerFailure.projectConfig].
  Future<Result<BuildPlan, HooksRunnerFailure>> makeLinkHookPlan() async =>
      _timeAsync(
        'BuildPlanner.makeLinkHookPlan',
        () async => _makeHookPlan(
          hookType: Hook.link,
          cachedPlan: _linkHookPlan,
          setCachedPlan: (plan) => _linkHookPlan = plan,
          reverseOrder: true, // Key difference from [makeBuildHookPlan]
        ),
      );

  Future<Result<BuildPlan, HooksRunnerFailure>> _makeHookPlan({
    required Hook hookType,
    required BuildPlan? cachedPlan,
    required void Function(BuildPlan) setCachedPlan,
    required bool reverseOrder,
  }) async {
    if (cachedPlan != null) return Success(cachedPlan);

    final packagesWithNativeAssets = await packagesWithHook(hookType);
    if (packagesWithNativeAssets.isEmpty) {
      return const Success([]);
    }

    final packageMap = {
      for (final package in packagesWithNativeAssets) package.name: package,
    };
    final packagesToProcess = packageMap.keys.toSet();

    final stronglyConnectedComponents = reverseOrder
        ? packageGraph.computeStrongComponents().reversed
        : packageGraph.computeStrongComponents();

    final result = <Package>[];
    for (final stronglyConnectedComponent in stronglyConnectedComponents) {
      final stronglyConnectedComponentWithNativeAssets = [
        for (final packageName in stronglyConnectedComponent)
          if (packagesToProcess.contains(packageName)) packageName,
      ];

      if (stronglyConnectedComponentWithNativeAssets.length > 1) {
        logger.severe(
          'Cyclic dependency for ${hookType.name} hooks in the '
          'following packages: $stronglyConnectedComponentWithNativeAssets.',
        );
        return const Failure(HooksRunnerFailure.projectConfig);
      } else if (stronglyConnectedComponentWithNativeAssets.length == 1) {
        result.add(
          packageMap[stronglyConnectedComponentWithNativeAssets.single]!,
        );
      }
    }

    setCachedPlan(result);
    return Success(result);
  }

  Future<T> _timeAsync<T>(
    String name,
    Future<T> Function() function, {
    Map<String, Object>? arguments,
  }) async {
    task.start(name, arguments: arguments);
    try {
      return await function();
    } finally {
      task.finish();
    }
  }
}

/// A graph of package dependencies.
///
/// This is encoded as a mapping from package name to list of package
/// dependencies.
class PackageGraph {
  final Map<String, List<String>> map;
  late final Map<String, List<String>> _inverseMap = _computeInverseMap(map);

  PackageGraph(this.map);

  /// Instead of a map of package -> dependencies, get the map of package ->
  /// dependents.
  static Map<String, List<String>> _computeInverseMap(
    Map<String, List<String>> graphMap,
  ) {
    final inverse = <String, List<String>>{};
    for (final packageName in graphMap.keys) {
      inverse.putIfAbsent(packageName, () => []);
      for (final dependency in graphMap[packageName]!) {
        inverse.putIfAbsent(dependency, () => []).add(packageName);
      }
    }
    return inverse;
  }

  factory PackageGraph.fromPackageGraphJsonString(
    String json,
    String runPackageName, {
    required bool includeDevDependencies,
  }) => PackageGraph.fromPackageGraphJson(
    jsonDecode(json) as Map<dynamic, dynamic>,
    runPackageName,
    includeDevDependencies: includeDevDependencies,
  );

  factory PackageGraph.fromPackageGraphJson(
    Map<dynamic, dynamic> map,
    String runPackageName, {
    required bool includeDevDependencies,
  }) {
    final result = <String, List<String>>{};
    final packages = map['packages'] as List<dynamic>;
    for (final package in packages) {
      final package_ = package as Map<dynamic, dynamic>;
      final name = package_['name'] as String;
      final dependencies = (package_['dependencies'] as List<dynamic>)
          .whereType<String>()
          .toList();
      if (name == runPackageName && includeDevDependencies) {
        final devDependencies =
            (package_['devDependencies'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            [];
        dependencies.addAll(devDependencies);
      }
      result[name] = dependencies;
    }
    return PackageGraph(result);
  }

  Iterable<String> neighborsOf(String vertex) => map[vertex] ?? [];

  Iterable<String> inverseNeighborsOf(String vertex) =>
      _inverseMap[vertex] ?? [];

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

/// The two types of scripts which are hooked into the compilation process.
///
/// The `build.dart` hook runs before, and the `link.dart` hook after
/// compilation. This enum holds static information about these hooks.
enum Hook {
  link('link'),
  build('build');

  final String _scriptName;

  const Hook(this._scriptName);

  String get scriptName => '$_scriptName.dart';
}
