// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart' as p;

import 'ast.dart';
import 'public_abstractor.dart';

class Context {
  final String projectAbsolutePath;
  final String bindingsFileAbsolutePath;
  final List<String> importedPackages = [];
  final List<LibraryClassSummary> libraryClassesSummaries = [];
  final List<Class> bindingsSummary = [];

  Context._({
    required this.projectAbsolutePath,
    required this.bindingsFileAbsolutePath,
  });

  static Future<Context> create(
    String projectAbsolutePath,
    String bindingsFileAbsolutePath,
  ) async {
    final context = Context._(
      projectAbsolutePath: projectAbsolutePath,
      bindingsFileAbsolutePath: bindingsFileAbsolutePath,
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

    // Get the bindings file summary
    final abstractor = PublicAbstractor();
    parseString(
      content: await bindingsFile.readAsString(),
    ).unit.visitChildren(abstractor);
    bindingsSummary.addAll(abstractor.getBindingsClassesSummary());

    // Get the packages classes summary, that are imported in the bindings file
    await _getLibrariesSummary(projectAbsolutePath, bindingsFileAbsolutePath);
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
            libraryClassesSummaries.addAll(
              await _getLibrarySummary(context, resolvedPackagePath),
            );
          }
        }
      }
    }
  }

  Future<List<LibraryClassSummary>> _getLibrarySummary(
    AnalysisContext context,
    String libraryFileAbsolutePath,
  ) async {
    final resolvedLibraryResult = await context.currentSession
        .getResolvedLibrary(libraryFileAbsolutePath);
    if (resolvedLibraryResult is ResolvedLibraryResult) {
      final libraryElement = resolvedLibraryResult.element;
      final classesSummaries = <LibraryClassSummary>[];
      for (final library in libraryElement.exportedLibraries) {
        for (final element in library.classes) {
          if (element.isPrivate) continue;
          classesSummaries.add(
            LibraryClassSummary(
              libraryName: libraryElement.identifier,
              classDeclerationDisplay: element.displayString(),
              methodsDeclerationDisplay:
                  element.methods
                      .takeWhile((m) => m.isPublic)
                      .map((m) => m.displayString())
                      .toList(),
              fieldsDeclerationDisplay:
                  element.fields
                      .takeWhile((f) => f.isPublic)
                      .map((f) => f.displayString())
                      .toList(),
              gettersDeclerationDisplay:
                  element.getters
                      .takeWhile((g) => g.isPublic)
                      .map((g) => g.displayString())
                      .toList(),
              settersDeclerationDisplay:
                  element.setters
                      .takeWhile((s) => s.isPublic)
                      .map((s) => s.displayString())
                      .toList(),
              constructorsDeclerationDisplay:
                  element.constructors
                      .takeWhile((c) => c.isPublic)
                      .map((c) => c.displayString())
                      .toList(),
            ),
          );
        }
      }
      return classesSummaries;
    } else {
      stderr.writeln(
        'Could not resolve library for path: $libraryFileAbsolutePath',
      );
      return [];
    }
  }

  String toDartLikeRepresentation() {
    final buffer = StringBuffer();
    for (final classSummary in bindingsSummary) {
      buffer.writeln(classSummary.toDartLikeRepresentaion());
    }
    for (final libraryClassSummary in libraryClassesSummaries) {
      buffer.writeln(libraryClassSummary.toDartLikeRepresentaion());
    }
    final dartLikeRepresentation = buffer.toString().replaceAll('jni\$_.', '');
    return dartLikeRepresentation;
  }
}
