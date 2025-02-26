// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../code_generator.dart';
import '../code_generator/utils.dart';
import '../config_provider.dart';
import '../config_provider/utils.dart';
import '../strings.dart' as strings;
import '../visitor/apply_config_filters.dart';
import '../visitor/ast.dart';
import '../visitor/copy_methods_from_super_type.dart';
import '../visitor/fill_method_dependencies.dart';
import '../visitor/find_transitive_deps.dart';
import '../visitor/fix_overridden_methods.dart';
import '../visitor/list_bindings.dart';
import '../visitor/opaque_compounds.dart';
import 'clang_bindings/clang_bindings.dart' as clang_types;
import 'data.dart';
import 'sub_parsers/macro_parser.dart';
import 'translation_unit_parser.dart';
import 'utils.dart';

/// Main entrypoint for header_parser.
Library parse(Config config) {
  initParser(config);

  return Library.fromConfig(
    config: config,
    bindings: transformBindings(config, parseToBindings(config)),
  );
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

List<String> _findObjectiveCSysroot() => [
      '-isysroot',
      firstLineOfStdout('xcrun', ['--show-sdk-path'])
    ];

@visibleForTesting
List<Binding> transformBindings(Config config, List<Binding> bindings) {
  visit(CopyMethodsFromSuperTypesVisitation(), bindings);
  visit(FixOverriddenMethodsVisitation(), bindings);

  final filterResults = visit(ApplyConfigFiltersVisitation(config), bindings);
  final directlyIncluded = filterResults.directlyIncluded;
  final included = directlyIncluded.union(filterResults.indirectlyIncluded);

  final byValueCompounds = visit(FindByValueCompoundsVisitation(),
          FindByValueCompoundsVisitation.rootNodes(included))
      .byValueCompounds;
  visit(
      ClearOpaqueCompoundMembersVisitation(config, byValueCompounds, included),
      bindings);

  final transitives =
      visit(FindTransitiveDepsVisitation(), included).transitives;
  final directTransitives = visit(
          FindDirectTransitiveDepsVisitation(
              config, included, directlyIncluded),
          included)
      .directTransitives;

  // Fill method deps (msgSend and protocol blocks) after calculating all the
  // transitive deps, so that msgSends etc don't force include AST nodes that
  // would otherwise be omitted. This is safe because the method deps don't use
  // any types that aren't already being used by the method itself.
  visit(FillMethodDependenciesVisitation(), bindings);

  final finalBindings = visit(
          ListBindingsVisitation(
              config, included, transitives, directTransitives),
          bindings)
      .bindings;
  visit(MarkBindingsVisitation(finalBindings), bindings);

  final finalBindingsList = finalBindings.toList();

  /// Sort bindings.
  if (config.sort) {
    finalBindingsList.sortBy((b) => b.name);
    for (final b in finalBindingsList) {
      b.sort();
    }
  }

  /// Handle any declaration-declaration name conflicts and emit warnings.
  final declConflictHandler = UniqueNamer({});
  for (final b in finalBindingsList) {
    _warnIfPrivateDeclaration(b);
    _resolveIfNameConflicts(declConflictHandler, b);
  }

  // Override pack values according to config. We do this after declaration
  // conflicts have been handled so that users can target the generated names.
  for (final b in finalBindingsList) {
    if (b is Struct) {
      final pack = config.structPackingOverride(b);
      if (pack != null) {
        b.pack = pack.value;
      }
    }
  }

  return finalBindingsList;
}

/// Logs a warning if generated declaration will be private.
void _warnIfPrivateDeclaration(Binding b) {
  if (b.name.startsWith('_') && !b.isInternal) {
    _logger.warning("Generated declaration '${b.name}' starts with '_' "
        'and therefore will be private.');
  }
}

/// Resolves name conflict(if any) and logs a warning.
void _resolveIfNameConflicts(UniqueNamer namer, Binding b) {
  // Print warning if name was conflicting and has been changed.
  if (namer.isUsed(b.name)) {
    final oldName = b.name;
    b.name = namer.makeUnique(b.name);

    _logger.warning("Resolved name conflict: Declaration '$oldName' "
        "and has been renamed to '${b.name}'.");
  } else {
    namer.markUsed(b.name);
  }
}
