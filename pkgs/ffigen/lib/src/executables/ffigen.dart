// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Executable script to generate bindings for some C library.
import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart' show Ansi;
import 'package:logging/logging.dart';
import 'package:package_config/package_config.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../../ffigen.dart';

final _ansi = Ansi(Ansi.terminalSupportsAnsi);
final logger = () {
  final l = Logger('ffigen.ffigen');
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

const compilerOpts = 'compiler-opts';
const ignoreSourceErrors = 'ignore-source-errors';
const format = 'format';
const conf = 'config';
const help = 'help';
const verbose = 'verbose';
const pubspecName = 'pubspec.yaml';
const configKey = 'ffigen';
const logAll = 'all';
const logFine = 'fine';
const logInfo = 'info';
const logWarning = 'warning';
const logSevere = 'severe';

Future<void> main(List<String> args) async {
  // Parses the cmd args. This will print usage and exit if --help was passed.
  final argResult = getArgResults(args);

  Logger.root.level = _parseLogLevel(argResult);

  // Create a config object.
  FfiGen config;
  try {
    config = getConfig(argResult, await findPackageConfig(Directory.current));
  } on FormatException {
    logger.severe('Please fix configuration errors and re-run the tool.');
    exit(1);
  }

  config.generate(logger: logger);
}

FfiGen getConfig(ArgResults result, PackageConfig? packageConfig) {
  logger.info('Running in ${Directory.current}');
  YamlConfig config;

  // Parse config from yaml.
  if (result.wasParsed(conf)) {
    config = getConfigFromCustomYaml(result[conf] as String, packageConfig);
  } else {
    config = getConfigFromPubspec(packageConfig);
  }

  // Add compiler options from command line.
  if (result.wasParsed(compilerOpts)) {
    logger.fine('Passed compiler opts - "${result[compilerOpts]}"');
    config.addCompilerOpts(result[compilerOpts] as String, highPriority: true);
  }

  if (result.wasParsed(ignoreSourceErrors)) {
    config.ignoreSourceErrors = true;
  }

  config.formatOutput = result[format] as bool;

  return config.configAdapter();
}

/// Extracts configuration from pubspec file.
YamlConfig getConfigFromPubspec(PackageConfig? packageConfig) {
  final pubspecFile = File(pubspecName);

  if (!pubspecFile.existsSync()) {
    logger.severe(
      'Error: $pubspecName not found, please run this tool from '
      'the root of your package.',
    );
    exit(1);
  }

  // Casting this because pubspec is expected to be a YamlMap.

  // Throws a [YamlException] if it's unable to parse the Yaml.
  final pubspecYaml =
      yaml.loadYaml(pubspecFile.readAsStringSync()) as yaml.YamlMap;
  final bindingsConfigMap = pubspecYaml[configKey] as yaml.YamlMap?;

  if (bindingsConfigMap == null) {
    logger.severe("Couldn't find an entry for '$configKey' in $pubspecName.");
    exit(1);
  }
  return YamlConfig.fromYaml(
    bindingsConfigMap,
    logger,
    filename: pubspecFile.path,
    packageConfig: packageConfig,
  );
}

/// Extracts configuration from a custom yaml file.
YamlConfig getConfigFromCustomYaml(
  String yamlPath,
  PackageConfig? packageConfig,
) {
  final yamlFile = File(yamlPath);

  if (!yamlFile.existsSync()) {
    logger.severe('Error: $yamlPath not found.');
    exit(1);
  }

  return YamlConfig.fromFile(yamlFile, logger, packageConfig: packageConfig);
}

/// Parses the cmd line arguments.
ArgResults getArgResults(List<String> args) {
  final parser = ArgParser(allowTrailingOptions: true);

  parser.addSeparator(
    'FFIGEN: Generate dart bindings from C header files\nUsage:',
  );
  parser.addOption(
    conf,
    help: 'Path to Yaml file containing configurations if not in pubspec.yaml',
  );
  parser.addOption(
    verbose,
    abbr: 'v',
    defaultsTo: logInfo,
    allowed: [logAll, logFine, logInfo, logWarning, logSevere],
  );
  parser.addFlag(help, abbr: 'h', help: 'Prints this usage', negatable: false);
  parser.addOption(
    compilerOpts,
    help: 'Compiler options for clang. (E.g --$compilerOpts "-I/headers -W")',
  );
  parser.addFlag(
    ignoreSourceErrors,
    help: 'Ignore any compiler warnings/errors in source header files',
    negatable: false,
  );
  parser.addFlag(
    format,
    help: 'Format the generated code.',
    defaultsTo: true,
    negatable: true,
  );

  ArgResults results;
  try {
    results = parser.parse(args);

    if (results.wasParsed(help)) {
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
  switch (result[verbose] as String?) {
    case logAll:
      // Logs everything, the entire AST touched by our parser.
      return Level.ALL;
    case logFine:
      // Logs AST parts relevant to user (i.e those included in filters).
      return Level.FINE;
    case logInfo:
      // Logs relevant info for general user (default).
      return Level.INFO;
    case logWarning:
      // Logs warnings for relevant stuff.
      return Level.WARNING;
    case logSevere:
      // Logs severe warnings and errors.
      return Level.SEVERE;
    default:
      return Level.INFO;
  }
}
