// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'bindings/dart_generator.dart';
import 'bindings/exporter.dart';
import 'bindings/graph_builder.dart';
import 'bindings/importer.dart';
import 'bindings/kotlin_processor.dart';
import 'bindings/linker.dart';
import 'bindings/visitor.dart';
import 'config/config.dart';
import 'elements/elements.dart';
import 'logging/logging.dart';
import 'summary/summary.dart';
import 'tools/tools.dart';
import 'transformers/default_renamer.dart';
import 'transformers/graph.dart';

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

  // Keep the order in sync with `elements/elements.dart`.
  var stage = GenerationStage.unprocessed;
  R runStage<R>(TopLevelVisitor<R> visitor) {
    assert(visitor.stage.index == stage.index + 1);
    stage = visitor.stage;
    return classes.accept(visitor);
  }

  void runUserTransformersStage(Bindings bindings) {
    assert(GenerationStage.userTransformers.index == stage.index + 1);
    stage = GenerationStage.userTransformers;
    config.visitors?.forEach(bindings.accept);
    // FIXME
    bindings.accept(DefaultRenamer(config));
  }

  runStage(KotlinProcessor());
  await runStage(Importer(config));
  await runStage(Linker(config));
  final bindings = runStage(GraphBuilder(config));
  runUserTransformersStage(bindings);
  await runStage(Exporter(config));
  await runStage(DartGenerator(config));
  // classes.accept(const Printer());
}
