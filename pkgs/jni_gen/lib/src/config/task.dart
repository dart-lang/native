// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';

import 'package:jni_gen/src/writers/bindings_writer.dart';
import 'package:jni_gen/src/config/config.dart';
import 'package:jni_gen/src/elements/elements.dart';

/// Represents a complete jni_gen binding generation configuration.
/// * [summarySource] handles the API summary generation.
/// * [options] specify any semantic options regarding generated code.
/// * [outputWriter] handles the output configuration.
class JniGenTask {
  JniGenTask({
    required this.summarySource,
    this.options = const WrapperOptions(),
    required this.outputWriter,
  });
  BindingsWriter outputWriter;
  SummarySource summarySource;
  WrapperOptions options;

  // execute this task
  Future<void> run({bool dumpJson = false}) async {
    Stream<List<int>> input;
    try {
      input = await summarySource.getInputStream();
    } on Exception catch (e) {
      stderr.writeln('error obtaining API summary: $e');
      return;
    }
    final stream = JsonDecoder().bind(Utf8Decoder().bind(input));
    dynamic json;
    try {
      json = await stream.single;
    } on Exception catch (e) {
      stderr.writeln('error while parsing summary: $e');
      return;
    }
    if (json == null) {
      stderr.writeln('error: expected JSON element from summarizer.');
      return;
    }
    if (dumpJson) {
      stderr.writeln(json);
    }
    final list = json as List;
    try {
      await outputWriter.writeBindings(
          list.map((c) => ClassDecl.fromJson(c)), options);
    } on Exception catch (e, trace) {
      stderr.writeln(trace);
      stderr.writeln('error writing bindings: $e');
    }
  }
}
