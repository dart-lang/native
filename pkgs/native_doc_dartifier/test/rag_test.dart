import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:chromadb/chromadb.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:native_doc_dartifier/src/public_abstractor.dart';
import 'package:test/test.dart';

Future<List<List<String?>>> queryChromaDB(
  String javaSnippet,
  GenerativeModel embeddingModel,
  Collection collection,
) async {
  final queryEmbeddings = await embeddingModel
      .embedContent(Content.text(javaSnippet))
      .then((embedContent) => embedContent.embedding.values);

  final query = await collection.query(
    queryEmbeddings: [queryEmbeddings],
    nResults: 10,
  );

  return query.documents!;
}

Future<void> main() async {
  // open the bindings file and get the summary (AST) of each class
  final bindingsFile = File('test/bindings.dart');
  if (!await bindingsFile.exists()) {
    stderr.writeln('File not found: ');
    exit(1);
  }

  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null) {
    stderr.writeln(r'No $GEMINI_API_KEY environment variable');
    exit(1);
  }

  final bindings = await bindingsFile.readAsString();

  final abstractor = PublicAbstractor();
  parseString(content: bindings).unit.visitChildren(abstractor);
  final classesSummary = abstractor.getClassesSummary();

  print('Total Number of Classes: ${classesSummary.length}');

  final geminiModel = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: apiKey,
  );

  final tokenCount = await geminiModel.countTokens([
    Content.text(classesSummary.join('\n')),
  ]);
  print('Total Bindings Tokens: ${tokenCount.totalTokens}');

  // get embeddings of each class summary and add them to chromaDB
  final client = ChromaClient();

  final collection = await client.getOrCreateCollection(name: 'bindings');
  final embeddingModel = GenerativeModel(
    apiKey: apiKey,
    model: 'gemini-embedding-001',
  );

  const batchSize = 100;
  final batchEmbededContent = <BatchEmbedContentsResponse>[];

  for (var i = 0; i < classesSummary.length; i += batchSize) {
    print('Processing batch from $i to ${i + batchSize}');
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
    await Future.delayed(const Duration(minutes: 1));
  }

  final embeddings = <List<double>>[];
  for (final response in batchEmbededContent) {
    for (final embedContent in response.embeddings) {
      embeddings.add(embedContent.values);
    }
  }

  await collection.add(
    ids: List.generate(
      classesSummary.length,
      (index) => (index + 1).toString(),
    ),
    embeddings: embeddings,
    documents: classesSummary,
  );

  print('Added ${classesSummary.length} documents to the chromaDB.');

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
    final documents = await queryChromaDB(
      javaSnippet,
      embeddingModel,
      collection,
    );
    final ragSummary = documents.join('\n');

    expect(ragSummary.contains('class Accumulator'), isTrue);

    print('Query Results:');
    for (var i = 0; i < documents[0].length; i++) {
      print(documents[0][i]!.split('\n')[0]);
    }

    print(
      'Number of Tokens in the RAG Summary: '
      '${await geminiModel.countTokens([Content.text(ragSummary)])}',
    );
  });

  test('Snippet that uses Example only', () async {
    const javaSnippet = '''
Boolean useEnums() {
    Example example = new Example();
    Boolean isTrueUsage = example.enumValueToString(Operation.ADD) == "Addition";
    return isTrueUsage;
}''';
    final documents = await queryChromaDB(
      javaSnippet,
      embeddingModel,
      collection,
    );
    final ragSummary = documents.join('\n');

    expect(ragSummary.contains('class Example'), isTrue);

    print('Query Results:');
    for (var i = 0; i < documents[0]!.length; i++) {
      print(documents[0][i]!.split('\n')[0]);
    }

    print(
      'Number of Tokens in the RAG Summary: '
      '${await geminiModel.countTokens([Content.text(ragSummary)])}',
    );
  });

  test('Snippet that uses both FileReader and BufferReader', () async {
    const javaSnippet = '''
public class ReadFile {
    public static void main(String[] args) {
        String filePath = "my-file.txt";
        try (
            FileReader fileReader = new FileReader(filePath);
            BufferedReader bufferedReader = new BufferedReader(fileReader)
        ) {
            String line = bufferedReader.readLine();
            System.out.println("The first line of the file is: " + line);
        } catch (IOException e) {
            System.err.println("An error occurred while reading the file: " + e.getMessage());
        }
    }
}''';
    final documents = await queryChromaDB(
      javaSnippet,
      embeddingModel,
      collection,
    );
    final ragSummary = documents.join('\n');

    expect(ragSummary.contains('class FileReader'), isTrue);
    expect(ragSummary.contains('class BufferedReader'), isTrue);

    print('Query Results:');
    for (var i = 0; i < documents[0].length; i++) {
      print(documents[0][i]!.split('\n')[0]);
    }

    print(
      'Number of Tokens in the RAG Summary: '
      '${await geminiModel.countTokens([Content.text(ragSummary)])}',
    );
  });
}
