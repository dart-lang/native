// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart' as p;

import 'ast.dart';
import 'public_abstractor.dart';
import 'rag.dart';

class Context {
  final RAG? rag;
  final String projectAbsolutePath;
  final String bindingsFileAbsolutePath;
  final List<String> importedPackages = [];
  final List<PackageSummary> packageSummaries = [];
  final List<Class> bindingsSummary = [];

  Context._({
    required this.projectAbsolutePath,
    required this.bindingsFileAbsolutePath,
    required bool usingRag,
  }) : rag = (usingRag ? RAG.instance : null);

  static Future<Context> create(
    String projectAbsolutePath,
    String bindingsFileAbsolutePath, {
    bool usingRag = false,
  }) async {
    final context = Context._(
      projectAbsolutePath: projectAbsolutePath,
      bindingsFileAbsolutePath: bindingsFileAbsolutePath,
      usingRag: usingRag,
    );
    await context._init();
    return context;
  }

  Future<void> _init() async {
    final bindingsFile = File(bindingsFileAbsolutePath);
    if (!await bindingsFile.exists()) {
      stderr.writeln('File not found: $bindingsFile');
      exit(1);
    }

    if (rag == null) {
      // Get the bindings file summary
      final abstractor = PublicAbstractor();
      parseString(
        content: await bindingsFile.readAsString(),
      ).unit.visitChildren(abstractor);
      bindingsSummary.addAll(abstractor.getBindingsClassesSummary());

      // Get packages classes summary, that are imported in the bindings file
      await _getLibrariesSummary(projectAbsolutePath, bindingsFileAbsolutePath);
    }
  }

  Future<void> _getLibrariesSummary(
    String projectAbsolutePath,
    String bindingsFileAbsolutePath,
  ) async {
    final collection = AnalysisContextCollection(
      includedPaths: [p.normalize(projectAbsolutePath)],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final context = collection.contexts.first;

    final parseResult =
        context.currentSession.getParsedUnit(bindingsFileAbsolutePath)
            as ParsedUnitResult;
    for (final directive in parseResult.unit.directives) {
      if (directive is ImportDirective) {
        final uri = directive.uri.toString().replaceAll('\'', '');
        if (uri.startsWith('package:')) {
          importedPackages.add(uri);
          final session = context.currentSession;
          final resolvedPackagePath = session.uriConverter.uriToPath(
            Uri.parse(uri),
          );

          if (resolvedPackagePath != null) {
            print('Import URI: $uri -> Resolved Path: $resolvedPackagePath');
            final resolvedPackage = await context.currentSession
                .getResolvedLibrary(resolvedPackagePath);
            if (resolvedPackage is ResolvedLibraryResult) {
              final packageElement = resolvedPackage.element;
              final packageSummary = PackageSummary(
                packageName: packageElement.identifier,
              );
              await _getLibrarySummary(packageSummary, packageElement);
              packageSummaries.add(packageSummary);
            } else {
              stderr.writeln(
                'Could not resolve library for path: $resolvedPackagePath',
              );
            }
          }
        }
      }
    }
  }

  Future<void> _getLibrarySummary(
    PackageSummary packageSummary,
    LibraryElement libraryElement,
  ) async {
    for (final exportedLibrary in libraryElement.exportedLibraries) {
      await _getLibrarySummary(packageSummary, exportedLibrary);
    }
    packageSummary.topLevelFunctions.addAll(
      libraryElement.topLevelFunctions
          .where((f) => f.isPublic)
          .map((f) => f.displayString()),
    );
    packageSummary.topLevelVariables.addAll(
      libraryElement.topLevelVariables
          .where((v) => v.isPublic)
          .map((v) => v.displayString()),
    );
    for (final classInstance in libraryElement.classes) {
      if (classInstance.isPrivate) continue;
      packageSummary.classesSummaries.add(
        LibraryClassSummary(
          classDeclerationDisplay: classInstance.displayString(),
          methodsDeclerationDisplay:
              classInstance.methods
                  .where((m) => m.isPublic)
                  .map((m) => m.displayString())
                  .toList(),
          fieldsDeclerationDisplay:
              classInstance.fields
                  .where((f) => f.isPublic)
                  .map((f) => f.displayString())
                  .toList(),
          gettersDeclerationDisplay:
              classInstance.getters
                  .where((g) => g.isPublic)
                  .map((g) => g.displayString())
                  .toList(),
          settersDeclerationDisplay:
              classInstance.setters
                  .where((s) => s.isPublic)
                  .map((s) => s.displayString())
                  .toList(),
          constructorsDeclerationDisplay:
              classInstance.constructors
                  .where((c) => c.isPublic)
                  .map((c) => c.displayString())
                  .toList(),
        ),
      );
    }
    return;
  }

  /// It will return the full context,
  /// If [rag] is null or the given [querySnippet] is empty.
  Future<String> toDartLikeRepresentation(String querySnippet) async {
    final buffer = StringBuffer();
    if (rag != null && querySnippet.isNotEmpty) {
      final documents = await rag!.queryRAG(querySnippet);
      for (final classSummary in documents) {
        buffer.writeln(classSummary);
      }
    } else {
      for (final classSummary in bindingsSummary) {
        buffer.writeln(classSummary.toDartLikeRepresentation());
      }
      for (final packageSummary in packageSummaries) {
        buffer.writeln(packageSummary.toDartLikeRepresentation());
      }
    }

    final dartLikeRepresentation = buffer.toString().replaceAll('jni\$_.', '');
    return dartLikeRepresentation;
  }
}
