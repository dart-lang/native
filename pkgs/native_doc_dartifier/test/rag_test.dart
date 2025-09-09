// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';
import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:native_doc_dartifier/src/public_abstractor.dart';
import 'package:native_doc_dartifier/src/rag.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final bindingsFile = File('test/dartify_simple_cases/bindings.dart');

  if (!await bindingsFile.exists()) {
    stderr.writeln('File not found: ');
    exit(1);
  }

  final bindings = await bindingsFile.readAsString();

  final abstractor = PublicAbstractor();
  parseString(content: bindings).unit.visitChildren(abstractor);
  final classesSummary =
      abstractor
          .getBindingsClassesSummary()
          .map((c) => c.toDartLikeRepresentation())
          .toList();

  print('Total Number of Classes: ${classesSummary.length}');

  final rag = RAG.instance;
  await rag.addAllDocumentsToRag(classesSummary);

  group('Normal RAG Query', () {
    test('Snippet that uses Accumulator only', () async {
      const javaSnippet = '''
Boolean overloadedMethods() {
    Accumulator acc1 = new Accumulator();
    acc1.add(10);
    acc1.add(10, 10);
    acc1.add(10, 10, 10);

    Accumulator acc2 = new Accumulator(20);
    acc2.add(acc1);

    Accumulator acc3 = new Accumulator(acc2);
    return acc3.accumulator == 80;
}
''';

      final documents = await rag.queryRAG(javaSnippet, numRetrievedDocs: 2);
      final ragSummary = documents.join('\n');

      print('Query Results:');
      for (var i = 0; i < documents.length; i++) {
        print(documents[i].split('\n')[0]);
      }

      expect(ragSummary.contains('class Accumulator'), isTrue);
    });

    test('Snippet that uses Example only', () async {
      const javaSnippet = '''
Boolean useEnums() {
    Example example = new Example();
    Boolean isTrueUsage = example.enumValueToString(Operation.ADD) == "Addition";
    return isTrueUsage;
}''';
      final documents = await rag.queryRAG(javaSnippet, numRetrievedDocs: 2);
      final ragSummary = documents.join('\n');

      print('Query Results:');
      for (var i = 0; i < documents.length; i++) {
        print(documents[i].split('\n')[0]);
      }

      expect(ragSummary.contains('class Example'), isTrue);
    });
  });
}
