// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart';

import '../code_generator.dart';
import '../config_provider.dart';
import '../config_provider/config_types.dart';
import '../strings.dart' as strings;
import 'clang_bindings/clang_bindings.dart' as clang_types;
import 'data.dart';
import 'sub_parsers/macro_parser.dart';
import 'translation_unit_parser.dart';
import 'utils.dart';

/// Main entrypoint for header_parser.
Library parse(Config c) {
  initParser(c);

  final bindings = parseToBindings(c);

  final library = Library(
    bindings: bindings,
    name: c.wrapperName,
    description: c.wrapperDocComment,
    header: c.preamble,
    sort: c.sort,
    generateForPackageObjectiveC: c.generateForPackageObjectiveC,
    packingOverride: c.structPackingOverride,
    libraryImports: c.libraryImports.values.toList(),
    silenceEnumWarning: c.silenceEnumWarning,
    nativeEntryPoints: c.entryPoints.map((uri) => uri.toFilePath()).toList(),
  );

  return library;
}

// =============================================================================
//           BELOW FUNCTIONS ARE MEANT FOR INTERNAL USE AND TESTING
// =============================================================================

final _logger = Logger('ffigen.header_parser.parser');

/// Initializes parser, clears any previous values.
void initParser(Config c) {
  // Initialize global variables.
  initializeGlobals(
    config: c,
  );
}

/// Parses source files and returns the bindings.
List<Binding> parseToBindings(Config c) {
  final index = clang.clang_createIndex(0, 0);

  Pointer<Pointer<Utf8>> clangCmdArgs = nullptr;
  final compilerOpts = <String>[
    // Add compiler opt for comment parsing for clang based on config.
    if (config.commentType.length != CommentLength.none &&
        config.commentType.style == CommentStyle.any)
      strings.fparseAllComments,

    // If the config targets Objective C, add a compiler opt for it.
    if (config.language == Language.objc) ...[
      ...strings.clangLangObjC,
      ..._findObjectiveCSysroot(),
    ],

    // Add the user options last so they can override any other options.
    ...config.compilerOpts
  ];

  _logger.fine('CompilerOpts used: $compilerOpts');
  clangCmdArgs = createDynamicStringArray(compilerOpts);
  final cmdLen = compilerOpts.length;

  // Contains all bindings. A set ensures we never have duplicates.
  final bindings = <Binding>{};

  // Log all headers for user.
  _logger.info('Input Headers: ${config.entryPoints}');

  final tuList = <Pointer<clang_types.CXTranslationUnitImpl>>[];

  // Parse all translation units from entry points.
  for (final headerLocationUri in config.entryPoints) {
    final headerLocation = headerLocationUri.toFilePath();
    _logger.fine('Creating TranslationUnit for header: $headerLocation');

    final tu = clang.clang_parseTranslationUnit(
      index,
      headerLocation.toNativeUtf8().cast(),
      clangCmdArgs.cast(),
      cmdLen,
      nullptr,
      0,
      clang_types.CXTranslationUnit_Flags.CXTranslationUnit_SkipFunctionBodies |
          clang_types.CXTranslationUnit_Flags
              .CXTranslationUnit_DetailedPreprocessingRecord |
          clang_types
              .CXTranslationUnit_Flags.CXTranslationUnit_IncludeAttributedTypes,
    );

    if (tu == nullptr) {
      _logger.severe(
          "Skipped header/file: $headerLocation, couldn't parse source.");
      // Skip parsing this header.
      continue;
    }

    logTuDiagnostics(tu, _logger, headerLocation);
    tuList.add(tu);
  }

  if (hasSourceErrors) {
    _logger.warning('The compiler found warnings/errors in source files.');
    _logger.warning('This will likely generate invalid bindings.');
    if (config.ignoreSourceErrors) {
      _logger.warning(
          'Ignored source errors. (User supplied --ignore-source-errors)');
    } else if (config.language == Language.objc) {
      _logger.warning('Ignored source errors. (ObjC)');
    } else {
      _logger.severe(
          'Skipped generating bindings due to errors in source files. See https://github.com/dart-lang/native/blob/main/pkgs/ffigen/doc/errors.md.');
      exit(1);
    }
  }

  final tuCursors =
      tuList.map((tu) => clang.clang_getTranslationUnitCursor(tu));

  // Build usr to CXCusror map from translation units.
  for (final rootCursor in tuCursors) {
    buildUsrCursorDefinitionMap(rootCursor);
  }

  // Parse definitions from translation units.
  for (final rootCursor in tuCursors) {
    bindings.addAll(parseTranslationUnit(rootCursor));
  }

  // Dispose translation units.
  for (final tu in tuList) {
    clang.clang_disposeTranslationUnit(tu);
  }

  // Add all saved unnamed enums.
  bindings.addAll(unnamedEnumConstants);

  // Parse all saved macros.
  bindings.addAll(parseSavedMacros());

  clangCmdArgs.dispose(cmdLen);
  clang.clang_disposeIndex(index);
  return bindings.toList();
}

List<String> _findObjectiveCSysroot() {
  final result = Process.runSync('xcrun', ['--show-sdk-path']);
  if (result.exitCode == 0) {
    for (final line in (result.stdout as String).split('\n')) {
      if (line.isNotEmpty) {
        return ['-isysroot', line];
      }
    }
  }
  return [];
}
