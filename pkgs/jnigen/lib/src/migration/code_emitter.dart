// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'config_values.dart';

/// Formats and emits a clean Dart generator script from
/// [JnigenMigrationConfig].
class CodeEmitter {
  final JnigenMigrationConfig config;

  CodeEmitter(this.config);

  String emit() {
    final buffer = StringBuffer();

    // 1. License header
    buffer.writeln(
      '// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS '
      'file\n'
      '// for details. All rights reserved. Use of this source code is '
      'governed by a\n'
      '// BSD-style license that can be found in the LICENSE file.',
    );
    buffer.writeln();

    // 2. Imports
    buffer.writeln("import 'dart:io';");
    buffer.writeln();
    buffer.writeln("import 'package:jnigen/jnigen.dart';");
    buffer.writeln();

    // 3. Preamble (if any)
    if (config.preamble != null && config.preamble!.isNotEmpty) {
      buffer.writeln('const preamble = ${_formatPreamble(config.preamble!)};');
      buffer.writeln();
    }

    // 4. getConfig function
    buffer.writeln(
      'JniGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {',
    );
    buffer.writeln(
      "  packageRoot ??= Uri.directory('${config.defaultPackageRoot}');",
    );
    buffer.writeln('  return JniGenerator(');
    _emitInput(buffer);
    _emitOutput(buffer);
    _emitImports(buffer);
    _emitNullability(buffer);
    buffer.writeln('  );');
    buffer.writeln('}');
    buffer.writeln();

    // 5. main function
    buffer.writeln('Future<void> main(List<String> args) async {');
    buffer.writeln('  final outputDir = args.firstOrNull != null');
    buffer.writeln('      ? Uri.directory(args.first)');
    buffer.writeln("      : (Platform.environment['OUTPUT_DIR'] != null");
    buffer.writeln(
      "          ? Uri.directory(Platform.environment['OUTPUT_DIR']!)",
    );
    buffer.writeln('          : null);');
    buffer.writeln('  await getConfig(outputDir: outputDir).generate();');
    buffer.writeln('}');
    buffer.writeln();

    return buffer.toString();
  }

  void _emitInput(StringBuffer buffer) {
    buffer.writeln('    input: Input(');
    if (config.sourcePaths.isNotEmpty) {
      buffer.writeln('      sourcePath: [');
      for (final p in config.sourcePaths) {
        buffer.writeln("        packageRoot.resolve('$p'),");
      }
      buffer.writeln('      ],');
    }
    if (config.classPaths.isNotEmpty) {
      buffer.writeln('      classPath: [');
      for (final p in config.classPaths) {
        buffer.writeln("        packageRoot.resolve('$p'),");
      }
      buffer.writeln('      ],');
    }
    buffer.writeln('      classes: [');
    for (final c in config.classes) {
      buffer.writeln("        '$c',");
    }
    buffer.writeln('      ],');
    if (config.extraArgs.isNotEmpty) {
      buffer.writeln('      extraArgs: [');
      for (final arg in config.extraArgs) {
        buffer.writeln("        '$arg',");
      }
      buffer.writeln('      ],');
    }
    if (config.workingDirectory != null) {
      buffer.writeln(
        '      workingDirectory: '
        "packageRoot.resolve('${config.workingDirectory}'),",
      );
    }
    if (config.summarizerBackend != null) {
      final bStr = config.summarizerBackend == SummarizerBackendConfig.asm
          ? 'SummarizerBackend.asm'
          : 'SummarizerBackend.doclet';
      buffer.writeln('      backend: $bStr,');
    }
    if (config.mavenDownloads != null) {
      _emitMavenDownloads(buffer, config.mavenDownloads!);
    }
    if (config.androidSdk != null) {
      _emitAndroidSdk(buffer, config.androidSdk!);
    }
    buffer.writeln('    ),');
  }

  void _emitMavenDownloads(StringBuffer buffer, MavenDownloadsConfig m) {
    buffer.writeln('      mavenDownloads: MavenDownloads(');
    if (m.sourceDeps.isNotEmpty) {
      buffer.writeln('        sourceDeps: [');
      for (final dep in m.sourceDeps) {
        buffer.writeln("          '$dep',");
      }
      buffer.writeln('        ],');
    }
    final sourceDir = m.sourceDir ?? 'mvn_java/';
    final formattedSourceDir =
        sourceDir.endsWith('/') ? sourceDir : '$sourceDir/';
    buffer.writeln(
      "        sourceDir: packageRoot.resolve('$formattedSourceDir'),",
    );

    if (m.jarOnlyDeps.isNotEmpty) {
      buffer.writeln('        jarOnlyDeps: [');
      for (final dep in m.jarOnlyDeps) {
        buffer.writeln("          '$dep',");
      }
      buffer.writeln('        ],');
    }
    final jarDir = m.jarDir ?? 'mvn_jar/';
    final formattedJarDir = jarDir.endsWith('/') ? jarDir : '$jarDir/';
    buffer.writeln("        jarDir: packageRoot.resolve('$formattedJarDir'),");
    buffer.writeln('      ),');
  }

  void _emitAndroidSdk(StringBuffer buffer, AndroidSdkConfig a) {
    buffer.writeln('      androidSdk: AndroidSdk(');
    if (a.versions != null) {
      buffer.writeln('        versions: [${a.versions!.join(', ')}],');
    }
    if (a.sdkRoot != null) {
      buffer.writeln(
        "        sdkRoot: packageRoot.resolve('${a.sdkRoot}'),",
      );
    }
    if (a.addGradleDeps) {
      buffer.writeln('        addGradleDeps: true,');
    }
    if (a.addGradleSources) {
      buffer.writeln('        addGradleSources: true,');
    }
    if (a.androidExample != null) {
      final ex = a.androidExample!;
      final formatted = ex.endsWith('/') ? ex : '$ex/';
      buffer.writeln(
        "        androidExample: packageRoot.resolve('$formatted'),",
      );
    } else {
      buffer.writeln('        androidExample: packageRoot,');
    }
    buffer.writeln('      ),');
  }

  void _emitOutput(StringBuffer buffer) {
    buffer.writeln('    output: Output(');
    buffer.writeln('      dart: DartOutput(');
    final singleFile =
        config.dartOutput.structure == OutputStructureConfig.singleFile;
    if (singleFile) {
      buffer.writeln("        path: outputDir?.resolve('generated.dart') ??");
      buffer.writeln(
        "            packageRoot.resolve('${config.dartOutput.path}'),",
      );
      buffer.writeln('        structure: OutputStructure.singleFile,');
    } else {
      var relPath = config.dartOutput.path;
      if (!relPath.endsWith('/')) {
        relPath = '$relPath/';
      }
      buffer.writeln("        path: outputDir?.resolve('lib/') ??");
      buffer.writeln("            packageRoot.resolve('$relPath'),");
      if (config.dartOutput.explicitlySpecifiedStructure) {
        buffer.writeln('        structure: OutputStructure.packageStructure,');
      }
    }
    buffer.writeln('      ),');
    if (config.symbols != null && config.symbols!.isNotEmpty) {
      buffer.writeln(
        '      symbols: '
        "SymbolsOutput(packageRoot.resolve('${config.symbols}')),",
      );
    }
    if (config.preamble != null && config.preamble!.isNotEmpty) {
      buffer.writeln('      preamble: preamble,');
    }
    buffer.writeln('    ),');
  }

  void _emitImports(StringBuffer buffer) {
    if (config.hide.isEmpty && config.symbolFiles.isEmpty) {
      return;
    }
    final isConst = config.symbolFiles.isEmpty;
    final constPrefix = isConst ? 'const ' : '';
    buffer.writeln('    imports: ${constPrefix}SymbolImports(');
    if (config.symbolFiles.isNotEmpty) {
      buffer.writeln('      symbolFiles: [');
      for (final s in config.symbolFiles) {
        buffer.writeln("        Uri.parse('$s'),");
      }
      buffer.writeln('      ],');
    }
    if (config.hide.isNotEmpty) {
      buffer.writeln('      hide: [');
      for (final h in config.hide) {
        buffer.writeln("        '$h',");
      }
      buffer.writeln('      ],');
    }
    buffer.writeln('    ),');
  }

  void _emitNullability(StringBuffer buffer) {
    if (config.nullability == null) {
      return;
    }
    final n = config.nullability!;
    if (n.nonNull.isEmpty && n.nullable.isEmpty) {
      return;
    }
    buffer.writeln('    nullability: const NullabilityAnnotations(');
    if (n.nonNull.isNotEmpty) {
      buffer.writeln('      nonNull: [');
      for (final ann in n.nonNull) {
        buffer.writeln("        '$ann',");
      }
      buffer.writeln('      ],');
    }
    if (n.nullable.isNotEmpty) {
      buffer.writeln('      nullable: [');
      for (final ann in n.nullable) {
        buffer.writeln("        '$ann',");
      }
      buffer.writeln('      ],');
    }
    buffer.writeln('    ),');
  }

  static String _formatPreamble(String preamble) {
    final escaped = preamble
        .replaceAll(r'\', r'\\')
        .replaceAll("'''", r"\'\'\'")
        .replaceAll(r'$', r'\$');
    return "'''\n$escaped'''";
  }
}
