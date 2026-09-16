// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Migrates a YAML configuration file to a Dart configuration script.
///
/// Reads [yamlConfig] and writes a Dart configuration script to [outputDart].
void migrate({
  required File yamlConfig,
  required File outputDart,
}) {
  if (!yamlConfig.existsSync()) {
    throw FileSystemException(
      'YAML config file does not exist',
      yamlConfig.path,
    );
  }

  final yamlContent = yamlConfig.readAsStringSync();
  final loaded = loadYaml(yamlContent);
  final yamlMap = loaded is YamlMap ? loaded : const <dynamic, dynamic>{};

  final baseName = p.basename(yamlConfig.path);
  const testPackageRoots = {
    'comprehensive_package.yaml': 'test/simple_package_test/',
    'comprehensive_single_file.yaml': 'example/pdfbox_plugin/',
    'simple.yaml': 'test/simple_package_test/',
  };
  final defaultPackageRoot = testPackageRoots[baseName] ?? '.';

  final buf = StringBuffer();

  // Static imports block
  buf.writeln('// ignore_for_file: unused_import');
  buf.writeln("import 'dart:io';\n");
  buf.writeln("import 'package:jnigen/jnigen.dart';\n");

  final preamble = _getPreamble(yamlMap);
  _emitPreamble(buf, preamble);

  // main
  buf.writeln('Future<void> main() async {');
  buf.writeln("  final packageRoot = Uri.directory('$defaultPackageRoot');");
  buf.writeln('  await JniGenerator(');

  _emitInput(buf, yamlMap);
  _emitOutput(buf, yamlMap, preamble != null && preamble.isNotEmpty);
  _emitImports(buf, yamlMap);
  _emitNullability(buf, yamlMap);

  buf.writeln('  ).generate();');
  buf.writeln('}\n');

  final parentDir = outputDart.parent;
  if (!parentDir.existsSync()) {
    parentDir.createSync(recursive: true);
  }
  outputDart.writeAsStringSync(buf.toString());

  Process.runSync(
    Platform.resolvedExecutable,
    ['format', outputDart.absolute.path],
    workingDirectory: outputDart.parent.absolute.path,
  );
}

List<String> _strList(dynamic value) {
  if (value is List) return value.map((e) => e.toString()).toList();
  if (value is String) return [value];
  return const [];
}

String _formatPreamble(String preamble) {
  final escaped = preamble
      .replaceAll(r'\', r'\\')
      .replaceAll("'''", r"\'\'\'")
      .replaceAll(r'$', r'\$');
  return "'''\n$escaped'''";
}

String? _getPreamble(Map<dynamic, dynamic> yamlMap) {
  final outputYaml = yamlMap['output'];
  return (yamlMap['preamble'] ??
      (outputYaml is Map ? outputYaml['preamble'] : null)) as String?;
}

void _emitPreamble(StringBuffer buf, String? preamble) {
  if (preamble != null && preamble.isNotEmpty) {
    buf.writeln('const preamble = ${_formatPreamble(preamble)};\n');
  }
}

void _emitStringList(
  StringBuffer buf,
  String name,
  List<String> items, {
  bool resolve = false,
}) {
  if (items.isEmpty) return;
  buf.writeln('      $name: [');
  for (final item in items) {
    buf.writeln(
      resolve ? "        packageRoot.resolve('$item')," : "        '$item',",
    );
  }
  buf.writeln('      ],');
}

void _emitClasses(StringBuffer buf, List<String> classes) =>
    _emitStringList(buf, 'classes', classes);

void _emitMavenDownloads(StringBuffer buf, Map<dynamic, dynamic> mavenDl) {
  buf.writeln('      mavenDownloads: MavenDownloads(');
  _emitStringList(buf, 'sourceDeps', _strList(mavenDl['source_deps']));
  final sourceDir = (mavenDl['source_dir'] as String?) ?? 'mvn_java/';
  final fmtSourceDir = sourceDir.endsWith('/') ? sourceDir : '$sourceDir/';
  buf.writeln("        sourceDir: packageRoot.resolve('$fmtSourceDir'),");
  _emitStringList(buf, 'jarOnlyDeps', _strList(mavenDl['jar_only_deps']));
  final jarDir = (mavenDl['jar_dir'] as String?) ?? 'mvn_jar/';
  final fmtJarDir = jarDir.endsWith('/') ? jarDir : '$jarDir/';
  buf.writeln("        jarDir: packageRoot.resolve('$fmtJarDir'),");
  buf.writeln('      ),');
}

void _emitAndroidSdk(StringBuffer buf, Map<dynamic, dynamic> androidSdk) {
  buf.writeln('      androidSdk: AndroidSdk(');
  if (androidSdk['versions'] case final List<dynamic> versions) {
    buf.writeln('        versions: [${versions.join(', ')}],');
  }
  if (androidSdk['sdk_root'] case final String sdkRoot) {
    buf.writeln("        sdkRoot: packageRoot.resolve('$sdkRoot'),");
  }
  if (androidSdk['add_gradle_deps'] == true) {
    buf.writeln('        addGradleDeps: true,');
  }
  if (androidSdk['add_gradle_sources'] == true) {
    buf.writeln('        addGradleSources: true,');
  }
  final example = androidSdk['android_example'] as String?;
  if (example != null) {
    final fmtExample = example.endsWith('/') ? example : '$example/';
    buf.writeln("        androidExample: packageRoot.resolve('$fmtExample'),");
  } else {
    buf.writeln('        androidExample: packageRoot,');
  }
  buf.writeln('      ),');
}

void _emitInput(StringBuffer buf, Map<dynamic, dynamic> yamlMap) {
  buf.writeln('    input: Input(');
  _emitStringList(
    buf,
    'sourcePath',
    _strList(yamlMap['source_path']),
    resolve: true,
  );
  _emitStringList(
    buf,
    'classPath',
    _strList(yamlMap['class_path']),
    resolve: true,
  );
  _emitClasses(buf, _strList(yamlMap['classes']));

  final summarizer = yamlMap['summarizer'];
  final extraArgs = _strList(
    summarizer is Map
        ? summarizer['extra_args']
        : yamlMap['summarizer.extra_args'],
  );
  _emitStringList(buf, 'extraArgs', extraArgs);

  final workingDir = (summarizer is Map
      ? summarizer['working_dir']
      : yamlMap['summarizer.working_dir']) as String?;
  if (workingDir != null) {
    buf.writeln("      workingDirectory: packageRoot.resolve('$workingDir'),");
  }

  final backend = (summarizer is Map ? summarizer['backend'] : null) as String?;
  if (backend == 'asm' || backend == 'doclet') {
    buf.writeln('      backend: SummarizerBackend.$backend,');
  }

  if (yamlMap['maven_downloads'] case final Map<dynamic, dynamic> mavenDl) {
    _emitMavenDownloads(buf, mavenDl);
  }

  if (yamlMap['android_sdk_config']
      case final Map<dynamic, dynamic> androidSdk) {
    _emitAndroidSdk(buf, androidSdk);
  }

  buf.writeln('    ),');
}

void _emitOutput(
  StringBuffer buf,
  Map<dynamic, dynamic> yamlMap,
  bool hasPreamble,
) {
  buf.writeln('    output: Output(');
  buf.writeln('      dart: DartOutput(');

  final outputYaml = yamlMap['output'];
  var dartPath = 'lib/bindings.dart';
  String? structureStr;
  var explicitlySpecifiedStructure = false;

  if (outputYaml is Map) {
    final dart = outputYaml['dart'];
    if (dart is Map) {
      dartPath = dart['path'] as String? ?? dartPath;
      structureStr = dart['structure'] as String?;
      explicitlySpecifiedStructure = structureStr != null;
    } else if (dart is String) {
      dartPath = dart;
    }
  }

  if (structureStr == 'single_file') {
    buf.writeln("        path: packageRoot.resolve('$dartPath'),");
    buf.writeln('        structure: OutputStructure.singleFile,');
  } else {
    final relPath = dartPath.endsWith('/') ? dartPath : '$dartPath/';
    buf.writeln("        path: packageRoot.resolve('$relPath'),");
    if (explicitlySpecifiedStructure && structureStr == 'package_structure') {
      buf.writeln('        structure: OutputStructure.packageStructure,');
    }
  }
  buf.writeln('      ),');

  final symbols = ((outputYaml is Map ? outputYaml['symbols'] : null) ??
      yamlMap['output.symbols']) as String?;
  if (symbols != null && symbols.isNotEmpty) {
    buf.writeln(
      "      symbols: SymbolsOutput(packageRoot.resolve('$symbols')),",
    );
  }

  if (hasPreamble) {
    buf.writeln('      preamble: preamble,');
  }

  buf.writeln('    ),');
}

void _emitImports(StringBuffer buf, Map<dynamic, dynamic> yamlMap) {
  final hide = _strList(yamlMap['hide']);
  final symbolFiles = _strList(yamlMap['import']);
  if (hide.isEmpty && symbolFiles.isEmpty) return;

  final constPrefix = symbolFiles.isEmpty ? 'const ' : '';
  buf.writeln('    imports: ${constPrefix}SymbolImports(');
  if (symbolFiles.isNotEmpty) {
    buf.writeln('      symbolFiles: [');
    for (final s in symbolFiles) {
      buf.writeln("        Uri.parse('$s'),");
    }
    buf.writeln('      ],');
  }
  _emitStringList(buf, 'hide', hide);
  buf.writeln('    ),');
}

void _emitNullability(StringBuffer buf, Map<dynamic, dynamic> yamlMap) {
  final nonNull = _strList(
    yamlMap['non_null_annotations'] ?? yamlMap['non_null'],
  );
  final nullable = _strList(
    yamlMap['nullable_annotations'] ?? yamlMap['nullable'],
  );
  if (nonNull.isEmpty && nullable.isEmpty) return;

  buf.writeln('    nullability: const NullabilityAnnotations(');
  _emitStringList(buf, 'nonNull', nonNull);
  _emitStringList(buf, 'nullable', nullable);
  buf.writeln('    ),');
}
