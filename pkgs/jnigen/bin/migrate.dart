// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:jnigen/src/migration.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'input',
      abbr: 'i',
      help: 'Path to the YAML configuration file.',
      valueHelp: 'path/to/config.yaml',
    )
    ..addOption(
      'out',
      abbr: 'o',
      aliases: ['output'],
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
      'Usage: dart run jnigen:migrate -i <config.yaml> -o <output.dart>\n',
    );
    print(parser.usage);
    exit(0);
  }

  final inputPath = results['input'] as String?;
  final outputPath = results['out'] as String?;

  if (inputPath == null || outputPath == null || results.rest.isNotEmpty) {
    stderr.writeln(
      'Error: Both input config YAML and output Dart paths must be specified.',
    );
    _printUsage(parser);
    exit(1);
  }

  final configFile = File(inputPath);
  if (!configFile.existsSync()) {
    stderr.writeln("Error: Config file not found at '$inputPath'.");
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
    'Usage: dart run jnigen:migrate -i <config.yaml> -o <output.dart>\n',
  );
  stderr.writeln(parser.usage);
}
