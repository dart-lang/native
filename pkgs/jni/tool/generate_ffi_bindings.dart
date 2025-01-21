// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This script generates all FFIGEN-based bindings we require to use JNI, which
// includes some C wrappers over `JNIEnv` type and some Dart extension methods.

import 'dart:io';

import 'package:args/args.dart';
import 'package:ffigen/ffigen.dart' as ffigen;
import 'package:ffigen/src/header_parser.dart' as ffigen;
import 'package:logging/logging.dart';

import 'wrapper_generators/generate_c_extensions.dart';
import 'wrapper_generators/generate_dart_extensions.dart';
import 'wrapper_generators/logging.dart';

void main(List<String> args) {
  final levels = Map.fromEntries(
    Level.LEVELS.map((l) => MapEntry(l.name.toLowerCase(), l)),
  );
  final argParser = ArgParser()
    ..addOption(
      'verbose',
      defaultsTo: 'severe',
      help: 'set ffigen log verbosity',
      allowed: levels.keys,
    )
    ..addFlag(
      'help',
      negatable: false,
      abbr: 'h',
      defaultsTo: false,
      help: 'display this help message',
    );

  final argResults = argParser.parse(args);

  if (argResults['help'] as bool) {
    stderr.writeln('Generates FFI bindings required for package:jni');
    stderr.writeln(argParser.usage);
    exitCode = 1;
    return;
  }

  hierarchicalLoggingEnabled = true;
  Logger.root.level = levels[argResults['verbose']]!;
  logger.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    stderr.writeln('${record.level.name}: ${record.message}');
  });

  logger.info('Generating C wrappers');
  final minimalConfig = ffigen.YamlConfig.fromFile(File('ffigen_exts.yaml'));
  final minimalLibrary = ffigen.parse(minimalConfig);
  generateCWrappers(minimalLibrary);

  logger.info('Generating FFI bindings for package:jni');

  final config = ffigen.YamlConfig.fromFile(File('ffigen.yaml'));
  final library = ffigen.parse(config);
  final outputFile = File(config.output.toFilePath());
  library.generateFile(outputFile);

  logger.info('Generating Dart extensions');
  generateDartExtensions(library);
}
