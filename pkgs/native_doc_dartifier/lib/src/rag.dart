// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../objectbox.g.dart';
import 'rag_models.dart';

class RAG {
  late final Store _store;
  late final Box<ClassSummaryRAGModel> _classSummaryBox;

  RAG._create(this._store) {
    _classSummaryBox = Box<ClassSummaryRAGModel>(_store);
  }

  static Future<RAG> create() async {
    final store = openStore();
    return RAG._create(store);
  }

  void close() {
    _store.close();
  }

  Future<List<String>> queryRAG(
    String javaSnippet, {
    int numRetrievedDocs = 20,
  }) async {
    final apiKey = Platform.environment['GEMINI_API_KEY'];
    if (apiKey == null) {
      stderr.writeln(r'No $GEMINI_API_KEY environment variable');
      exit(1);
    }

    final embeddingModel = GenerativeModel(
      apiKey: apiKey,
      model: 'gemini-embedding-001',
    );

    final queryEmbeddings = await embeddingModel
        .embedContent(Content.text(javaSnippet))
        .then((embedContent) => embedContent.embedding.values);

    // The Database makes use of HNSW algorithm for embeddings search which
    // is O(log n) in search time complexity better than O(n).
    // but the tradeoff that it gets the approximate nearest neighbors
    // instead of the exact ones
    // so make it to return approx 100 nearest neighbors and then get the top K.
    final query =
        _classSummaryBox
            .query(
              ClassSummaryRAGModel_.embeddings.nearestNeighborsF32(
                queryEmbeddings,
                100,
              ),
            )
            .build();
    query.limit = numRetrievedDocs;
    final resultWithScore = query.findWithScores();
    print('RAG query returned ${resultWithScore.length} results.');
    final result = resultWithScore.map((e) => e.object.summary).toList();

    query.close();
    return result;
  }

  Future<void> addAllDocumentsToRag(List<String> classesSummary) async {
    final apiKey = Platform.environment['GEMINI_API_KEY'];
    if (apiKey == null) {
      stderr.writeln(r'No $GEMINI_API_KEY environment variable');
      exit(1);
    }

    final embeddingModel = GenerativeModel(
      apiKey: apiKey,
      model: 'gemini-embedding-001',
    );

    // TODO: Check if the documents already exist in the RAG and skip
    // adding them instead of clearing all and re-adding them.
    print('Clearing existing RAG documents...');
    _classSummaryBox.removeAll();

    const batchSize = 100;
    final batchEmbededContent = <BatchEmbedContentsResponse>[];

    for (var i = 0; i < classesSummary.length; i += batchSize) {
      final upperbound =
          i + batchSize < classesSummary.length
              ? i + batchSize
              : classesSummary.length;
      print('Processing batch from $i to $upperbound...');
      final batch = classesSummary.sublist(
        i,
        i + batchSize > classesSummary.length
            ? classesSummary.length
            : i + batchSize,
      );

      final batchResponse = await embeddingModel.batchEmbedContents(
        List.generate(
          batch.length,
          (index) => EmbedContentRequest(Content.text(batch[index])),
        ),
      );

      batchEmbededContent.add(batchResponse);

      // Quota limit is 100 requests per minute
      await Future<void>.delayed(const Duration(minutes: 1));
    }

    final embeddings = <List<double>>[];
    for (final response in batchEmbededContent) {
      for (final embedContent in response.embeddings) {
        embeddings.add(embedContent.values);
      }
    }

    final classSummaries = <ClassSummaryRAGModel>[];
    for (var i = 0; i < classesSummary.length; i++) {
      classSummaries.add(
        ClassSummaryRAGModel(classesSummary[i], embeddings[i]),
      );
    }
    _classSummaryBox.putMany(classSummaries);

    print('Added ${classesSummary.length} documents to the RAG.');
  }
}
