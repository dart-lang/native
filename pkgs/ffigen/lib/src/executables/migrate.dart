// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Executable script to migrate a legacy YAML ffigen config to a Dart script
// that uses the `FfiGenerator` Dart API.
import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart' show Ansi;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as yaml;

import '../code_generator/utils.dart' show dartExecutable;
import '../config_provider/yaml_config.dart';
import '../config_provider/yaml_to_dart.dart';

final _ansi = Ansi(Ansi.terminalSupportsAnsi);
final logger = () {
  final l = Logger('ffigen.migrate');
  l.onRecord.listen((record) {
    final levelStr = '[${record.level.name}]'.padRight(9);
    final log = '$levelStr: ${record.message}';
    if (record.level < Level.SEVERE) {
      print(log);
    } else {
      print('${_ansi.red}$log${_ansi.none}');
    }
  });
  return l;
}();

const _configOpt = 'config';
const _outputOpt = 'output';
const _formatFlag = 'format';
const _verboseOpt = 'verbose';
const _helpFlag = 'help';
const _pubspecName = 'pubspec.yaml';
const _configKey = 'ffigen';
const _defaultOutputPath = 'tool/ffigen.dart';
const _logAll = 'all';
const _logFine = 'fine';
const _logInfo = 'info';
const _logWarning = 'warning';
const _logSevere = 'severe';

Future<void> main(List<String> args) async {
  final argResult = _getArgResults(args);

  Logger.root.level = _parseLogLevel(argResult);

  final configPath = argResult[_configOpt] as String?;
  final outputPath = argResult[_outputOpt] as String;

  final String yamlSource;
  final String configFilename;
  if (configPath != null) {
    final configFile = File(configPath);
    if (!configFile.existsSync()) {
      logger.severe('Error: $configPath not found.');
      exit(1);
    }
    yamlSource = configFile.readAsStringSync();
    configFilename = configFile.absolute.path;
  } else {
    final pubspecFile = File(_pubspecName);
    if (!pubspecFile.existsSync()) {
      logger.severe(
        'Error: $_pubspecName not found, please run this tool from the '
        'root of your package, or pass --$_configOpt.',
      );
      exit(1);
    }
    yamlSource = pubspecFile.readAsStringSync();
    configFilename = pubspecFile.absolute.path;
  }

  yaml.YamlMap configMap;
  try {
    final doc = yaml.loadYaml(yamlSource, sourceUrl: Uri.file(configFilename));
    if (configPath != null) {
      configMap = doc as yaml.YamlMap;
    } else {
      final fromPubspec = (doc as yaml.YamlMap)[_configKey] as yaml.YamlMap?;
      if (fromPubspec == null) {
        logger.severe(
          "Error: Couldn't find an entry for '$_configKey' in "
          '$_pubspecName.',
        );
        exit(1);
      }
      configMap = fromPubspec;
    }
  } on yaml.YamlException catch (e) {
    logger.severe('Error parsing YAML: $e');
    exit(1);
  }

  // Reuse the legacy config's validation to surface configuration errors
  // early, but keep going even if it fails -- this is a best-effort
  // migration tool.
  try {
    YamlConfig.fromYaml(configMap, logger, filename: configFilename);
  } on FormatException {
    logger.warning(
      'The input configuration has validation errors (see above). '
      'Migration will continue on a best-effort basis.',
    );
  }

  final dartSource = emitDartConfig(
    configMap,
    configFilename: configFilename,
    outputFilePath: p.absolute(outputPath),
  );

  final outputFile = File(outputPath);
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(dartSource);

  if (argResult[_formatFlag] as bool) {
    final result = Process.runSync(dartExecutable, [
      'format',
      outputFile.absolute.path,
    ], workingDirectory: outputFile.parent.absolute.path);
    if (result.exitCode != 0) {
      logger.warning(
        'Formatting the generated script failed, it may need manual '
        'cleanup:\n${result.stdout}\n${result.stderr}',
      );
    }
  }

  logger.info('Wrote migrated Dart config to $outputPath.');
  logger.info(
    'Review the TODO comments (if any) at the top of the generated file, '
    'then run it with `dart run $outputPath` to generate your bindings.',
  );
}

ArgResults _getArgResults(List<String> args) {
  final parser = ArgParser(allowTrailingOptions: true);

  parser.addSeparator(
    'FFIGEN MIGRATE: Migrate a YAML ffigen config to the Dart API\nUsage:',
  );
  parser.addOption(
    _configOpt,
    abbr: 'c',
    help:
        'Path to the YAML file containing the configuration to migrate. '
        'Defaults to the `ffigen` key in pubspec.yaml.',
  );
  parser.addOption(
    _outputOpt,
    abbr: 'o',
    defaultsTo: _defaultOutputPath,
    help: 'Path to write the migrated Dart script to.',
  );
  parser.addFlag(
    _formatFlag,
    help: 'Format the generated Dart script.',
    defaultsTo: true,
    negatable: true,
  );
  parser.addOption(
    _verboseOpt,
    abbr: 'v',
    defaultsTo: _logInfo,
    allowed: [_logAll, _logFine, _logInfo, _logWarning, _logSevere],
  );
  parser.addFlag(
    _helpFlag,
    abbr: 'h',
    help: 'Prints this usage',
    negatable: false,
  );

  ArgResults results;
  try {
    results = parser.parse(args);
    if (results.wasParsed(_helpFlag)) {
      print(parser.usage);
      exit(0);
    }
  } catch (e) {
    print(e);
    print(parser.usage);
    exit(1);
  }

  return results;
}

Level _parseLogLevel(ArgResults result) {
  switch (result[_verboseOpt] as String?) {
    case _logAll:
      return Level.ALL;
    case _logFine:
      return Level.FINE;
    case _logInfo:
      return Level.INFO;
    case _logWarning:
      return Level.WARNING;
    case _logSevere:
      return Level.SEVERE;
    default:
      return Level.INFO;
  }
}
