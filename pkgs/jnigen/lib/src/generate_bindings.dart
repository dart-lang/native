// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';

import 'bindings/c_generator.dart';
import 'bindings/dart_generator.dart';
import 'bindings/excluder.dart';
import 'bindings/linker.dart';
import 'bindings/renamer.dart';
import 'elements/elements.dart';
import 'summary/summary.dart';
import 'config/config.dart';
import 'tools/tools.dart';
import 'logging/logging.dart';

void collectOutputStream(Stream<List<int>> stream, StringBuffer buffer) =>
    stream.transform(const Utf8Decoder()).forEach(buffer.write);
Future<void> generateJniBindings(Config config) async {
  setLoggingLevel(config.logLevel);

  await buildSummarizerIfNotExists();

  final Classes classes;

  try {
    classes = await getSummary(config);
  } on SummaryParseException catch (e) {
    if (e.stderr != null) {
      printError(e.stderr);
    }
    log.fatal(e.message);
  }

  classes.accept(Excluder(config));
  await classes.accept(Linker(config));
  classes.accept(Renamer(config));

  final cBased = config.outputConfig.bindingsType == BindingsType.cBased;
  if (cBased) {
    await classes.accept(CGenerator(config));
  }

  try {
    await classes.accept(DartGenerator(config));
    log.info('Completed');
  } on Exception catch (e, trace) {
    stderr.writeln(trace);
    log.fatal('Error while writing bindings: $e');
  }
}
