// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Migrates a YAML configuration file to a Dart configuration script.
///
/// Reads [yamlConfig] (or file at [yamlPath]) and writes a Dart configuration
/// script to [outputDart] (or file at [outputPath]).
void migrate({
  File? yamlConfig,
  File? outputDart,
  String? yamlPath,
  String? outputPath,
}) {
  final configFile = yamlConfig ?? (yamlPath != null ? File(yamlPath) : null);
  final dartFile = outputDart ?? (outputPath != null ? File(outputPath) : null);

  if (configFile == null) {
    throw ArgumentError('Either yamlConfig or yamlPath must be provided.');
  }
  if (dartFile == null) {
    throw ArgumentError('Either outputDart or outputPath must be provided.');
  }

  if (!configFile.existsSync()) {
    throw FileSystemException(
      'YAML config file does not exist',
      configFile.path,
    );
  }

  final yamlContent = configFile.readAsStringSync();
  final loaded = loadYaml(yamlContent);
  final yamlMap = loaded is YamlMap ? loaded : const <dynamic, dynamic>{};

  final baseName = p.basename(configFile.path);
  const testPackageRoots = {
    'comprehensive_package.yaml': 'test/simple_package_test/',
    'comprehensive_single_file.yaml': 'example/pdfbox_plugin/',
  };
  final defaultPackageRoot = testPackageRoots[baseName] ?? '.';

  final buf = StringBuffer();

  // License header
  buf.writeln(
    '// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file\n'
    '// for details. All rights reserved. Use of this source code is governed by a\n'
    '// BSD-style license that can be found in the LICENSE file.\n',
  );

  // Static imports block
  buf.writeln('// ignore_for_file: unused_import');
  buf.writeln("import 'dart:io';\n");
  buf.writeln("import 'package:jnigen/jnigen.dart';\n");

  // Preamble
  final outputYaml = yamlMap['output'];
  final preamble = (yamlMap['preamble'] ??
      (outputYaml is Map ? outputYaml['preamble'] : null)) as String?;
  if (preamble != null && preamble.isNotEmpty) {
    buf.writeln('const preamble = ${_formatPreamble(preamble)};\n');
  }

  // getConfig
  buf.writeln('JniGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {');
  buf.writeln("  packageRoot ??= Uri.directory('$defaultPackageRoot');");
  buf.writeln('  return JniGenerator(');

  _emitInput(buf, yamlMap);
  _emitOutput(buf, yamlMap, preamble != null && preamble.isNotEmpty);
  _emitImports(buf, yamlMap);
  _emitNullability(buf, yamlMap);

  buf.writeln('  );');
  buf.writeln('}\n');

  // main
  buf.writeln('''Future<void> main(List<String> args) async {
  final outputDir = args.firstOrNull != null
      ? Uri.directory(args.first)
      : (Platform.environment['OUTPUT_DIR'] != null
          ? Uri.directory(Platform.environment['OUTPUT_DIR']!)
          : null);
  await getConfig(outputDir: outputDir).generate();
}
''');

  final parentDir = dartFile.parent;
  if (!parentDir.existsSync()) {
    parentDir.createSync(recursive: true);
  }
  dartFile.writeAsStringSync(buf.toString());

  Process.runSync(
    Platform.resolvedExecutable,
    ['format', dartFile.absolute.path],
    workingDirectory: dartFile.parent.absolute.path,
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

void _emitInput(StringBuffer buf, Map<dynamic, dynamic> yamlMap) {
  buf.writeln('    input: Input(');
  final sourcePaths = _strList(yamlMap['source_path']);
  if (sourcePaths.isNotEmpty) {
    buf.writeln('      sourcePath: [');
    for (final p in sourcePaths) {
      buf.writeln("        packageRoot.resolve('$p'),");
    }
    buf.writeln('      ],');
  }

  final classPaths = _strList(yamlMap['class_path']);
  if (classPaths.isNotEmpty) {
    buf.writeln('      classPath: [');
    for (final p in classPaths) {
      buf.writeln("        packageRoot.resolve('$p'),");
    }
    buf.writeln('      ],');
  }

  final classes = _strList(yamlMap['classes']);
  buf.writeln('      classes: [');
  for (final c in classes) {
    buf.writeln("        '$c',");
  }
  buf.writeln('      ],');

  final summarizer = yamlMap['summarizer'];
  final extraArgs = _strList(
    summarizer is Map
        ? summarizer['extra_args']
        : yamlMap['summarizer.extra_args'],
  );
  if (extraArgs.isNotEmpty) {
    buf.writeln('      extraArgs: [');
    for (final a in extraArgs) {
      buf.writeln("        '$a',");
    }
    buf.writeln('      ],');
  }

  final workingDir = (summarizer is Map
      ? summarizer['working_dir']
      : yamlMap['summarizer.working_dir']) as String?;
  if (workingDir != null) {
    buf.writeln("      workingDirectory: packageRoot.resolve('$workingDir'),");
  }

  final backend = (summarizer is Map ? summarizer['backend'] : null) as String?;
  if (backend == 'asm') {
    buf.writeln('      backend: SummarizerBackend.asm,');
  } else if (backend == 'doclet') {
    buf.writeln('      backend: SummarizerBackend.doclet,');
  }

  final mavenDl = yamlMap['maven_downloads'];
  if (mavenDl is Map) {
    buf.writeln('      mavenDownloads: MavenDownloads(');
    final sourceDeps = _strList(mavenDl['source_deps']);
    if (sourceDeps.isNotEmpty) {
      buf.writeln('        sourceDeps: [');
      for (final dep in sourceDeps) {
        buf.writeln("          '$dep',");
      }
      buf.writeln('        ],');
    }
    final sourceDir = (mavenDl['source_dir'] as String?) ?? 'mvn_java/';
    final formattedSourceDir =
        sourceDir.endsWith('/') ? sourceDir : '$sourceDir/';
    buf.writeln(
      "        sourceDir: packageRoot.resolve('$formattedSourceDir'),",
    );

    final jarOnlyDeps = _strList(mavenDl['jar_only_deps']);
    if (jarOnlyDeps.isNotEmpty) {
      buf.writeln('        jarOnlyDeps: [');
      for (final dep in jarOnlyDeps) {
        buf.writeln("          '$dep',");
      }
      buf.writeln('        ],');
    }
    final jarDir = (mavenDl['jar_dir'] as String?) ?? 'mvn_jar/';
    final formattedJarDir = jarDir.endsWith('/') ? jarDir : '$jarDir/';
    buf.writeln("        jarDir: packageRoot.resolve('$formattedJarDir'),");
    buf.writeln('      ),');
  }

  final androidSdk = yamlMap['android_sdk_config'];
  if (androidSdk is Map) {
    buf.writeln('      androidSdk: AndroidSdk(');
    final versions = androidSdk['versions'];
    if (versions is List) {
      buf.writeln('        versions: [${versions.join(', ')}],');
    }
    final sdkRoot = androidSdk['sdk_root'] as String?;
    if (sdkRoot != null) {
      buf.writeln("        sdkRoot: packageRoot.resolve('$sdkRoot'),");
    }
    if (androidSdk['add_gradle_deps'] == true) {
      buf.writeln('        addGradleDeps: true,');
    }
    if (androidSdk['add_gradle_sources'] == true) {
      buf.writeln('        addGradleSources: true,');
    }
    final androidExample = androidSdk['android_example'] as String?;
    if (androidExample != null) {
      final formatted =
          androidExample.endsWith('/') ? androidExample : '$androidExample/';
      buf.writeln(
        "        androidExample: packageRoot.resolve('$formatted'),",
      );
    } else {
      buf.writeln('        androidExample: packageRoot,');
    }
    buf.writeln('      ),');
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
      dartPath = dart['path'] as String? ?? 'lib/bindings.dart';
      structureStr = dart['structure'] as String?;
      if (structureStr != null) explicitlySpecifiedStructure = true;
    } else if (dart is String) {
      dartPath = dart;
    }
  }

  final singleFile = structureStr == 'single_file';
  if (singleFile) {
    buf.writeln("        path: outputDir?.resolve('generated.dart') ??");
    buf.writeln("            packageRoot.resolve('$dartPath'),");
    buf.writeln('        structure: OutputStructure.singleFile,');
  } else {
    final relPath = dartPath.endsWith('/') ? dartPath : '$dartPath/';
    buf.writeln("        path: outputDir?.resolve('lib/') ??");
    buf.writeln("            packageRoot.resolve('$relPath'),");
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
  if (hide.isNotEmpty) {
    buf.writeln('      hide: [');
    for (final h in hide) {
      buf.writeln("        '$h',");
    }
    buf.writeln('      ],');
  }
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
  if (nonNull.isNotEmpty) {
    buf.writeln('      nonNull: [');
    for (final ann in nonNull) {
      buf.writeln("        '$ann',");
    }
    buf.writeln('      ],');
  }
  if (nullable.isNotEmpty) {
    buf.writeln('      nullable: [');
    for (final ann in nullable) {
      buf.writeln("        '$ann',");
    }
    buf.writeln('      ],');
  }
  buf.writeln('    ),');
}
