// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'context.dart';
import 'generator/generator.dart';
import 'parser/parser.dart';
import 'transformer/transform.dart';
import 'utils.dart';

extension Swift2ObjCGeneratorMethod on Swift2ObjCGenerator {
  /// Used to generate the wrapper swift file.
  Future<void> generate({required Logger? logger}) => _generateWrapper(
    this,
    Context(logger ?? (Logger.detached('dev/null')..level = Level.OFF)),
  );
}

Future<void> _generateWrapper(
  Swift2ObjCGenerator config,
  Context context,
) async {
  final Directory tempDir;
  final bool deleteTempDirWhenDone;

  var lazyTarget = config.target;
  Future<String> target() async => lazyTarget ??= await hostTargetTriple;
  var lazySdkPath = config.sdk;
  Future<Uri> sdkPath() async => lazySdkPath ??= await hostSdk;

  if (config.tempDir == null) {
    tempDir = Directory.systemTemp.createTempSync(defaultTempDirPrefix);
    deleteTempDirWhenDone = true;
  } else {
    tempDir = Directory.fromUri(config.tempDir!);
    deleteTempDirWhenDone = false;
  }
  tempDir.createSync();

  final sourceModules = <String?>[];
  final mergedSymbolgraph = ParsedSymbolgraph();
  final allInputConfigs = [...config.inputs, builtInInputConfig];

  for (final input in allInputConfigs) {
    final isFoundation =
        input is ModuleInputConfig && input.module == 'Foundation';

    // Use JSON cache for Foundation to speed up generation
    if (isFoundation && await _tryLoadFoundationCache(mergedSymbolgraph)) {
      sourceModules.add('Foundation');
      continue;
    }

    // Generate symbolgraph or use provided JSON
    if (input is HasSymbolgraphCommand) {
      await _generateSymbolgraphJson(
        (input as HasSymbolgraphCommand).symbolgraphCommand(
          await target(),
          p.absolute((await sdkPath()).path),
        ),
        tempDir,
      );
    }

    final symbolgraphFileName = switch (input) {
      FilesInputConfig() => '${input.tempModuleName}$symbolgraphFileSuffix',
      ModuleInputConfig() => '${input.module}$symbolgraphFileSuffix',
      JsonFileInputConfig() => p.absolute(input.jsonFile.path),
    };

    final symbolgraphJsonPath = p.join(tempDir.path, symbolgraphFileName);
    final symbolgraphJson = readJsonFile(symbolgraphJsonPath);

    sourceModules.add(switch (input) {
      FilesInputConfig() => null,
      ModuleInputConfig() => input.module,
      JsonFileInputConfig() => parseModuleName(symbolgraphJson),
    });
    mergedSymbolgraph.merge(parseSymbolgraph(input, symbolgraphJson));
  }

  final declarations = parseDeclarations(context, mergedSymbolgraph);
  final transformedDeclarations = transform(
    context,
    declarations,
    filter: config.include,
  );

  final wrapperCode = generate(
    transformedDeclarations,
    importedModuleNames: sourceModules.nonNulls.toList(),
    preamble: config.preamble,
  );

  File.fromUri(config.outputFile).writeAsStringSync(wrapperCode);

  if (deleteTempDirWhenDone) {
    tempDir.deleteSync(recursive: true);
  }
}

Future<void> _generateSymbolgraphJson(
  Command symbolgraphCommand,
  Directory workingDirectory,
) async {
  final result = await Process.run(
    symbolgraphCommand.executable,
    symbolgraphCommand.args,
    workingDirectory: workingDirectory.path,
  );

  if (result.exitCode != 0) {
    throw ProcessException(
      symbolgraphCommand.executable,
      symbolgraphCommand.args,
      'Error generating symbol graph \n${result.stdout} \n${result.stderr}',
    );
  }
}

/// Find the Foundation cache directory.
Directory? _findFoundationCacheDir() {
  final cacheRelativePath = p.join('lib', 'src', 'foundation_cache');

  // Check current directory
  var cacheDir = Directory(p.join(Directory.current.path, cacheRelativePath));
  if (cacheDir.existsSync()) return cacheDir;

  // Walk up directory tree looking for pubspec.yaml
  var dir = Directory.current;
  while (true) {
    if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
      cacheDir = Directory(p.join(dir.path, cacheRelativePath));
      if (cacheDir.existsSync()) return cacheDir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return null;
}

/// Try to load Foundation symbolgraph from cache.
///
/// Loads ALL Foundation*.symbols.json files (including extensions) to preserve
/// relationships needed for nested type assertions.
Future<bool> _tryLoadFoundationCache(ParsedSymbolgraph target) async {
  final cacheDir = _findFoundationCacheDir();
  if (cacheDir == null) return false;

  // Load all Foundation*.symbols.json files
  final files = cacheDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.symbols.json'))
      .toList();

  if (files.isEmpty) return false;

  for (final file in files) {
    final json = readJsonFile(file.path);
    target.merge(parseSymbolgraph(builtInInputConfig, json));
  }

  return true;
}
