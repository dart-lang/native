// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import 'bindings/dart_generator.dart';
import 'bindings/excluder.dart';
import 'bindings/kotlin_processor.dart';
import 'bindings/linker.dart';
import 'bindings/renamer.dart';
import 'bindings/stub_collector.dart';
import 'bindings/visitor.dart';
import 'config/config.dart';
import 'elements/elements.dart';
import 'elements/j_elements.dart' as j_ast;
import 'logging/logging.dart';
import 'summary/summary.dart';
import 'tools/tools.dart';

void collectOutputStream(Stream<List<int>> stream, StringBuffer buffer) =>
    stream.transform(const Utf8Decoder()).forEach(buffer.write);

extension JniGenGenerator on JniGenerator {
  /// Runs the entire generation pipeline for this config.
  ///
  /// If provided, uses [logger] to output logs. Otherwise, uses a default
  /// logger that logs to stderr and the log file.
  Future<void> generate({Logger? logger}) async {
    logger ??= createDefaultLogger();
    if (logger != log) {
      setLoggingLevel(logger.level);
    }

    Annotated.nonNullAnnotations
      ..clear()
      ..addAll(Annotated.defaultNonNullAnnotations)
      ..addAll(nullability.nonNull);
    Annotated.nullableAnnotations
      ..clear()
      ..addAll(Annotated.defaultNullableAnnotations)
      ..addAll(nullability.nullable);

    if (input.summarizerCommand == null) {
      await buildSummarizerIfNotExists();
    }

    final Classes classes;

    try {
      classes = await getSummary(this);
    } on SummaryParseException catch (e) {
      if (e.stderr != null) {
        printError(e.stderr);
      }
      log.fatal(e.message);
    }

    final userClasses = j_ast.Classes(classes);
    visitors.forEach(userClasses.accept);

    // Keep the order in sync with `elements/elements.dart`.
    var stage = GenerationStage.userVisitors;
    R runStage<R>(TopLevelVisitor<R> visitor) {
      assert(visitor.stage.index == stage.index + 1);
      stage = visitor.stage;
      return classes.accept(visitor);
    }

    runStage(Excluder(this));
    runStage(KotlinProcessor());
    await runStage(Linker(this));
    runStage(StubCollector(this));
    runStage(Renamer(this));
    // classes.accept(const Printer());

    try {
      await classes.accept(DartGenerator(this));
      log.info('Completed');
    } on Exception catch (e, trace) {
      stderr.writeln(trace);
      log.fatal('Error while writing bindings: $e');
    }
  }
}
