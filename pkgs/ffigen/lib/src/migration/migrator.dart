// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:yaml/yaml.dart';

import 'code_buffer.dart';
import 'import_type_emitter.dart';
import 'input_emitter.dart';
import 'output_emitter.dart';
import 'path_resolver.dart';
import 'visitor_emitter.dart';

/// Orchestrates migrating a YAML configuration file to a Dart script.
class YamlMigrator {
  final File yamlConfig;
  final File outputDart;

  YamlMigrator({required this.yamlConfig, required this.outputDart});

  void migrate() {
    final yamlContent = yamlConfig.readAsStringSync();
    final yamlMap = loadYaml(yamlContent) as YamlMap;

    final pathResolver = PathResolver(
      yamlConfigFile: yamlConfig,
      outputDartFile: outputDart,
    );

    final outputEmitter = OutputEmitter(
      yamlMap: yamlMap,
      pathResolver: pathResolver,
    );
    final inputEmitter = InputEmitter(
      yamlMap: yamlMap,
      pathResolver: pathResolver,
    );
    final visitorEmitter = VisitorEmitter(yamlMap: yamlMap);
    final importTypeEmitter = ImportTypeEmitter(
      yamlMap: yamlMap,
      pathResolver: pathResolver,
    );

    final codeBuffer = CodeBuffer();
    codeBuffer.addImport('dart:io');
    codeBuffer.addImport('package:ffigen/ffigen.dart');

    importTypeEmitter.emitTopLevelDeclarations(codeBuffer);

    // Emit getConfig
    codeBuffer.writeln(
      'FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {',
    );
    codeBuffer.indent();

    codeBuffer.writeln(
      'packageRoot ??= ${pathResolver.packageRootDefaultExpr};',
    );
    if (!pathResolver.isConfigDirAtPackageRoot) {
      codeBuffer.writeln('final configDir = ${pathResolver.configDirExpr};');
    }

    outputEmitter.emitPathRedirections(codeBuffer);

    codeBuffer.writeln('return FfiGenerator(');
    codeBuffer.indent();

    outputEmitter.emitOutput(codeBuffer);
    inputEmitter.emitInput(codeBuffer);

    _emitObjectiveC(codeBuffer, yamlMap);
    _emitCpp(codeBuffer, yamlMap);

    importTypeEmitter.emitImportTypeArgument(codeBuffer);
    visitorEmitter.emitVisitor(codeBuffer);

    codeBuffer.dedent();
    codeBuffer.writeln(');');
    codeBuffer.dedent();
    codeBuffer.writeln('}');
    codeBuffer.writeln();

    // Emit main
    codeBuffer.writeln('Future<void> main(List<String> args) async {');
    codeBuffer.indent();
    codeBuffer.writeln('final outputDir = args.isNotEmpty');
    codeBuffer.writeln('    ? Uri.directory(args.first)');
    codeBuffer.writeln("    : Platform.environment['OUTPUT_DIR'] != null");
    codeBuffer.writeln(
      "        ? Uri.directory(Platform.environment['OUTPUT_DIR']!)",
    );
    codeBuffer.writeln('        : null;');
    codeBuffer.writeln('await getConfig(outputDir: outputDir).generate();');
    codeBuffer.dedent();
    codeBuffer.writeln('}');
    codeBuffer.writeln();

    final unformattedCode = StringBuffer()
      ..writeln(
        '// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file',
      )
      ..writeln(
        '// for details. All rights reserved. Use of this source code is governed by a',
      )
      ..writeln('// BSD-style license that can be found in the LICENSE file.')
      ..writeln()
      ..write(codeBuffer.generateImports())
      ..writeln()
      ..write(codeBuffer.toString());

    final parentDir = outputDart.parent;
    if (!parentDir.existsSync()) {
      parentDir.createSync(recursive: true);
    }
    outputDart.writeAsStringSync(unformattedCode.toString());

    Process.runSync(Platform.resolvedExecutable, [
      'format',
      outputDart.absolute.path,
    ], workingDirectory: outputDart.parent.absolute.path);
  }

  void _emitObjectiveC(CodeBuffer buffer, YamlMap yamlMap) {
    final genPkgObjC = yamlMap['generate-for-package-objective-c'] == true;
    if (yamlMap['language'] != 'objc' && !genPkgObjC) return;

    final extVersions = yamlMap['external-versions'] as Map?;

    if (extVersions != null) {
      buffer.writeln('objectiveC: ObjectiveC(');
      buffer.indent();
      buffer.writeln('externalVersions: ExternalVersions(');
      buffer.indent();
      if (extVersions.containsKey('ios')) {
        final iosMin = (extVersions['ios'] as Map)['min'].toString();
        buffer.writeln('ios: Versions(min: ${_formatVersion(iosMin)}),');
      }
      if (extVersions.containsKey('macos')) {
        final macosMin = (extVersions['macos'] as Map)['min'].toString();
        buffer.writeln('macos: Versions(min: ${_formatVersion(macosMin)}),');
      }
      buffer.dedent();
      buffer.writeln('),');
      if (genPkgObjC) {
        buffer.writeln('generateForPackageObjectiveC: true,');
      }
      buffer.dedent();
      buffer.writeln('),');
    } else if (genPkgObjC) {
      buffer.writeln(
        'objectiveC: const ObjectiveC(generateForPackageObjectiveC: true),',
      );
    } else {
      buffer.writeln('objectiveC: const ObjectiveC(),');
    }
  }

  void _emitCpp(CodeBuffer buffer, YamlMap yamlMap) {
    if (yamlMap.containsKey('cpp')) {
      buffer.writeln('cpp: const Cpp(),');
    }
  }

  static String _formatVersion(String v) {
    final parts = v.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return 'Version(${parts[0]}, ${parts[1]}, ${parts[2]})';
  }
}
