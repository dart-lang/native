// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:ffigen/src/migration.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'config',
      abbr: 'c',
      help: 'Path to the YAML configuration file.',
      valueHelp: 'path/to/config.yaml',
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Path to the output Dart file.',
      valueHelp: 'path/to/output.dart',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Prints usage information.',
    );

  final ArgResults results;
  try {
    results = parser.parse(args);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    _printUsage(parser);
    exit(1);
  }

  if (results['help'] as bool) {
    print(
      'Usage: dart run ffigen:migrate [options] <config.yaml> <output.dart>\n',
    );
    print(parser.usage);
    exit(0);
  }

  var configPath = results['config'] as String?;
  var outputPath = results['output'] as String?;
  final rest = results.rest;

  var restIndex = 0;
  if (configPath == null && restIndex < rest.length) {
    configPath = rest[restIndex++];
  }
  if (outputPath == null && restIndex < rest.length) {
    outputPath = rest[restIndex++];
  }

  if (configPath == null || outputPath == null || restIndex < rest.length) {
    stderr.writeln(
      'Error: Both input config YAML and output Dart paths must be specified.',
    );
    _printUsage(parser);
    exit(1);
  }

  final configFile = File(configPath);
  if (!configFile.existsSync()) {
    stderr.writeln("Error: Config file not found at '$configPath'.");
    exit(1);
  }

  final outputFile = File(outputPath);
  try {
    migrate(yamlConfig: configFile, outputDart: outputFile);
  } on Exception catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  stderr.writeln(
    'Usage: dart run ffigen:migrate [options] <config.yaml> <output.dart>\n',
  );
  stderr.writeln(parser.usage);
}
