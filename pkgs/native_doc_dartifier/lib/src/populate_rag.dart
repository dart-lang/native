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

  final bindingsClassSummary =
      context.bindingsSummary.map((c) => c.toDartLikeRepresentation()).toList();

  listOfSummaries.addAll(bindingsClassSummary);

  for (final package in context.packageSummaries) {
    final packageClassesSummary =
        package.classesSummaries
            .map((c) => c.toDartLikeRepresentation())
            .toList();
    listOfSummaries.addAll(packageClassesSummary);
  }

  await RAG.instance.addAllDocumentsToRag(listOfSummaries);
}
