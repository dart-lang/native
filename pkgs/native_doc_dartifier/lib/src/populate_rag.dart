// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'context.dart';
import 'rag.dart';

Future<void> populateRAG(
  String projectAbsolutePath,
  String bindingsFileAbsolutePath,
) async {
  final context = await Context.create(
    projectAbsolutePath,
    bindingsFileAbsolutePath,
  );

  final listOfSummaries = <String>[];

  final bindingsClassSummary = context.bindingsSummary
      .map((c) => c.toDartLikeRepresentation())
      .toList();

  listOfSummaries.addAll(bindingsClassSummary);

  for (final package in context.packageSummaries) {
    final packageClassesSummary = package.classesSummaries
        .map((c) => c.toDartLikeRepresentation())
        .toList();
    listOfSummaries.addAll(packageClassesSummary);
  }

  final rag = await RAG.create();
  await rag.addAllDocumentsToRag(listOfSummaries);
}
