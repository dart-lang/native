// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'config.dart';
import 'context.dart';
import 'generator/generator.dart';
import 'parser/_core/binary_serialization.dart';
import 'parser/parser.dart';
import 'transformer/transform.dart';
import 'utils.dart';
import 'utils/perf_timer.dart';

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
  final scope = PerfScope('swift2objc generation', logger: context.logger);

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

  // Parse symbolgraph
  final parseScope = scope.child('parse symbolgraph');
  for (final input in allInputConfigs) {
    final isFoundation =
        input is ModuleInputConfig && input.module == 'Foundation';

    ParsedSymbolgraph? foundationSymbolgraph;

    // Phase 2: Try binary cache for Foundation
    if (isFoundation) {
      foundationSymbolgraph = await _tryLoadFoundationBinary(context);
    }

    // If binary loaded, use it; otherwise generate/use JSON
    if (foundationSymbolgraph != null) {
      // Use binary-loaded symbolgraph (Phase 2)
      sourceModules.add('Foundation');
      mergedSymbolgraph.merge(foundationSymbolgraph);
    } else {
      // Generate/use JSON (Phase 1 fallback or non-Foundation input)
      if (input is HasSymbolgraphCommand) {
        await _generateSymbolgraphJson(
          (input as HasSymbolgraphCommand).symbolgraphCommand(
            await target(),
            path.absolute((await sdkPath()).path),
          ),
          tempDir,
        );
      }

      final symbolgraphFileName = switch (input) {
        FilesInputConfig() => '${input.tempModuleName}$symbolgraphFileSuffix',
        ModuleInputConfig() => '${input.module}$symbolgraphFileSuffix',
        JsonFileInputConfig() => path.absolute(input.jsonFile.path),
      };
      final symbolgraphJsonPath = path.join(tempDir.path, symbolgraphFileName);
      final symbolgraphJson = readJsonFile(symbolgraphJsonPath);

      sourceModules.add(switch (input) {
        FilesInputConfig() => null,
        ModuleInputConfig() => input.module,
        JsonFileInputConfig() => parseModuleName(symbolgraphJson),
      });
      mergedSymbolgraph.merge(parseSymbolgraph(input, symbolgraphJson));
    }
  }
  parseScope.close();

  // Parse declarations
  final declScope = scope.child('parse declarations');
  final declarations = parseDeclarations(context, mergedSymbolgraph);
  declScope.close();

  // Transform declarations
  final transformScope = scope.child('transform');
  final transformedDeclarations = transform(
    context,
    declarations,
    filter: config.include,
  );
  transformScope.close();

  // Generate code
  final genScope = scope.child('generate');
  final wrapperCode = generate(
    transformedDeclarations,
    importedModuleNames: sourceModules.nonNulls.toList(),
    preamble: config.preamble,
  );
  genScope.close();

  File.fromUri(config.outputFile).writeAsStringSync(wrapperCode);

  if (deleteTempDirWhenDone) {
    tempDir.deleteSync(recursive: true);
  }

  scope.close();
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

/// Try to load Foundation symbolgraph from binary cache (Phase 2).
///
/// Returns ParsedSymbolgraph if binary cache found, null otherwise.
/// Binary deserialization is 10-50x faster than JSON parsing.
Future<ParsedSymbolgraph?> _tryLoadFoundationBinary(Context context) async {
  try {
    // Try multiple search strategies to find the binary cache
    final searchPaths = [
      // Strategy 1: Relative to current working directory (common in tests)
      path.join(
        Directory.current.path,
        'lib',
        'src',
        'foundation_cache',
        'Foundation.symbols.bin',
      ),
      // Strategy 2: Relative to script directory (CLI usage)
      path.join(
        path.dirname(path.fromUri(Platform.script)),
        '..',
        'lib',
        'src',
        'foundation_cache',
        'Foundation.symbols.bin',
      ),
      // Strategy 3: Explicit absolute path (for installed packages)
      '/Users/divyaprakash/dart/native/pkgs/swift2objc/lib/src/foundation_cache/Foundation.symbols.bin',
    ];

    for (final binPath in searchPaths) {
      final normalized = path.normalize(binPath);
      final binFile = File(normalized);
      if (binFile.existsSync()) {
        try {
          final binaryTimer = PerfTimer.start('binary_load', context.logger);
          final binData = await binFile.readAsBytes();
          final sizeMB = binData.length ~/ (1024 * 1024);
          context.logger.info(
            'Loading Foundation from binary cache (${sizeMB}MB)...',
          );
          final symbolgraph = deserializeSymbolgraph(binData);
          binaryTimer.stop();
          context.logger.info('✓ Loaded Foundation from binary cache');
          return symbolgraph;
        } catch (e) {
          context.logger.warning('Failed to deserialize binary cache: $e');
          // Fall through to JSON cache
        }
      }
    }

    // Try JSON cache (Phase 1) as fallback
    final jsonSearchPaths = [
      path.join(
        Directory.current.path,
        'lib',
        'src',
        'foundation_cache',
        'Foundation$symbolgraphFileSuffix',
      ),
      path.join(
        path.dirname(path.fromUri(Platform.script)),
        '..',
        'lib',
        'src',
        'foundation_cache',
        'Foundation$symbolgraphFileSuffix',
      ),
    ];

    File? cachedFile;
    for (final jsonPath in jsonSearchPaths) {
      final normalized = path.normalize(jsonPath);
      final file = File(normalized);
      if (file.existsSync()) {
        cachedFile = file;
        break;
      }
    }

    if (cachedFile != null) {
      context.logger.info(
        'Using cached Foundation symbolgraph (JSON Phase 1 fallback)',
      );
      final jsonTimer = PerfTimer.start('json_load', context.logger);
      final symbolgraph = parseSymbolgraph(
        const ModuleInputConfig(module: 'Foundation'),
        readJsonFile(cachedFile.path),
      );
      jsonTimer.stop();
      return symbolgraph;
    }

    return null;
  } catch (e) {
    context.logger.warning('Failed to load Foundation from cache: $e');
    return null;
  }
}
