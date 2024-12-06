// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'bindings/dart_generator.dart';
import 'bindings/descriptor.dart';
import 'bindings/excluder.dart';
import 'bindings/kotlin_processor.dart';
import 'bindings/linker.dart';
import 'bindings/renamer.dart';
import 'config/config.dart';
import 'elements/elements.dart';
import 'elements/j_elements.dart' as j_ast;
import 'logging/logging.dart';
import 'summary/summary.dart';
import 'tools/tools.dart';

void collectOutputStream(Stream<List<int>> stream, StringBuffer buffer) =>
    stream.transform(const Utf8Decoder()).forEach(buffer.write);
Future<void> generateJniBindings(Config config) async {
  Annotated.nonNullAnnotations.addAll(config.nonNullAnnotations ?? []);
  Annotated.nullableAnnotations.addAll(config.nullableAnnotations ?? []);

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

  config.visitors?.forEach((visitor){
    j_ast.Classes(classes).accept(visitor);
  });
  classes.accept(Excluder(config));
  classes.accept(KotlinProcessor());
  await classes.accept(Linker(config));
  classes.accept(const Descriptor());
  classes.accept(Renamer(config));
  // classes.accept(const Printer());

  try {
    await classes.accept(DartGenerator(config));
    log.info('Completed');
  } on Exception catch (e, trace) {
    stderr.writeln(trace);
    log.fatal('Error while writing bindings: $e');
  }
}
