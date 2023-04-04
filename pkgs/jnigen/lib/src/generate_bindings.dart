// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';

import 'bindings/dart_generator.dart';
import 'bindings/excluder.dart';
import 'bindings/linker.dart';
import 'bindings/renamer.dart';
import 'summary/summary.dart';
import 'config/config.dart';
import 'tools/tools.dart';
import 'writers/bindings_writer.dart';
import 'logging/logging.dart';

void collectOutputStream(Stream<List<int>> stream, StringBuffer buffer) =>
    stream.transform(const Utf8Decoder()).forEach(buffer.write);
Future<void> generateJniBindings(Config config) async {
  setLoggingLevel(config.logLevel);

  await buildSummarizerIfNotExists();

  final classes = await getSummary(config);

  final cBased = config.outputConfig.bindingsType == BindingsType.cBased;
  classes
    ..accept(Excluder(config))
    ..accept(Linker(config))
    ..accept(Renamer(config));

  if (cBased) {
    await writeCBindings(config, classes.decls.values.toList());
  }

  try {
    await classes.accept(DartGenerator(config));
    log.info('Completed');
  } on Exception catch (e, trace) {
    stderr.writeln(trace);
    log.fatal('Error while writing bindings: $e');
  }
}
