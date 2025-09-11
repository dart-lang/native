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
import '../code_generator/unique_namer.dart';
import '../config_provider.dart';
import '../config_provider/utils.dart';
import '../context.dart';
import '../strings.dart' as strings;
import '../visitor/apply_config_filters.dart';
import '../visitor/ast.dart';
import '../visitor/copy_methods_from_super_type.dart';
import '../visitor/fill_method_dependencies.dart';
import '../visitor/find_transitive_deps.dart';
import '../visitor/fix_overridden_methods.dart';
import '../visitor/list_bindings.dart';
import '../visitor/mark_imports.dart';
import '../visitor/opaque_compounds.dart';
import 'clang_bindings/clang_bindings.dart' as clang_types;
import 'sub_parsers/macro_parser.dart';
import 'translation_unit_parser.dart';
import 'utils.dart';

/// Main entrypoint for header_parser.
Library parse(Context context) => Library.fromContext(
  bindings: transformBindings(parseToBindings(context), context),
  context: context,
);

// =============================================================================
//           BELOW FUNCTIONS ARE MEANT FOR INTERNAL USE AND TESTING
// =============================================================================

/// Parses source files and returns the bindings.
List<Binding> parseToBindings(Context context) {
  final index = clang.clang_createIndex(0, 0);
  final config = context.config;

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
    ...context.compilerOpts,
  ];

  context.logger.fine('CompilerOpts used: $compilerOpts');
  clangCmdArgs = createDynamicStringArray(compilerOpts);
  final cmdLen = compilerOpts.length;

  // Contains all bindings. A set ensures we never have duplicates.
  final bindings = <Binding>{};

  // Log all headers for user.
  context.logger.info('Input Headers: ${config.entryPoints}');

  final tuList = <Pointer<clang_types.CXTranslationUnitImpl>>[];

  // Parse all translation units from entry points.
  for (final headerLocationUri in config.entryPoints) {
    final headerLocation = headerLocationUri.toFilePath();
    context.logger.fine('Creating TranslationUnit for header: $headerLocation');

    final tu = clang.clang_parseTranslationUnit(
      index,
      headerLocation.toNativeUtf8().cast(),
      clangCmdArgs.cast(),
      cmdLen,
      nullptr,
      0,
      clang_types.CXTranslationUnit_Flags.CXTranslationUnit_SkipFunctionBodies |
          clang_types
              .CXTranslationUnit_Flags
              .CXTranslationUnit_DetailedPreprocessingRecord |
          clang_types
              .CXTranslationUnit_Flags
              .CXTranslationUnit_IncludeAttributedTypes,
    );

    if (tu == nullptr) {
      context.logger.severe(
        "Skipped header/file: $headerLocation, couldn't parse source.",
      );
      // Skip parsing this header.
      continue;
    }

    logTuDiagnostics(tu, context, headerLocation);
    tuList.add(tu);
  }

  if (context.hasSourceErrors) {
    context.logger.warning(
      'The compiler found warnings/errors in source files.',
    );
    context.logger.warning('This will likely generate invalid bindings.');
    if (config.ignoreSourceErrors) {
      context.logger.warning(
        'Ignored source errors. (User supplied --ignore-source-errors)',
      );
    } else if (config.language == Language.objc) {
      context.logger.warning('Ignored source errors. (ObjC)');
    } else {
      context.logger.severe(
        'Skipped generating bindings due to errors in source files. See https://github.com/dart-lang/native/blob/main/pkgs/ffigen/doc/errors.md.',
      );
      exit(1);
    }
  }

  final tuCursors = tuList.map(
    (tu) => clang.clang_getTranslationUnitCursor(tu),
  );

  // Build usr to CXCusror map from translation units.
  for (final rootCursor in tuCursors) {
    buildUsrCursorDefinitionMap(context, rootCursor);
  }

  // Parse definitions from translation units.
  for (final rootCursor in tuCursors) {
    bindings.addAll(parseTranslationUnit(context, rootCursor));
  }

  // Dispose translation units.
  for (final tu in tuList) {
    clang.clang_disposeTranslationUnit(tu);
  }

  // Add all saved unnamed enums.
  bindings.addAll(context.unnamedEnumConstants);

  // Parse all saved macros.
  bindings.addAll(parseSavedMacros(context));

  clangCmdArgs.dispose(cmdLen);
  clang.clang_disposeIndex(index);
  return bindings.toList();
}

List<String> _findObjectiveCSysroot() => [
  '-isysroot',
  firstLineOfStdout('xcrun', ['--show-sdk-path']),
];

@visibleForTesting
List<Binding> transformBindings(List<Binding> bindings, Context context) {
  final config = context.config;
  visit(context, CopyMethodsFromSuperTypesVisitation(), bindings);
  visit(context, FixOverriddenMethodsVisitation(context), bindings);
  visit(context, FillMethodDependenciesVisitation(), bindings);

  final applyConfigFiltersVisitation = ApplyConfigFiltersVisitation(config);
  visit(context, applyConfigFiltersVisitation, bindings);
  final directlyIncluded = applyConfigFiltersVisitation.directlyIncluded;
  final included = directlyIncluded.union(
    applyConfigFiltersVisitation.indirectlyIncluded,
  );

  final byValueCompounds = visit(
    context,
    FindByValueCompoundsVisitation(),
    FindByValueCompoundsVisitation.rootNodes(included),
  ).byValueCompounds;
  visit(
    context,
    ClearOpaqueCompoundMembersVisitation(config, byValueCompounds, included),
    bindings,
  );

  final transitives = visit(
    context,
    FindTransitiveDepsVisitation(),
    included,
  ).transitives;
  final directTransitives = visit(
    context,
    FindDirectTransitiveDepsVisitation(config, included, directlyIncluded),
    included,
  ).directTransitives;

  final finalBindings = visit(
    context,
    ListBindingsVisitation(config, included, transitives, directTransitives),
    bindings,
  ).bindings;
  visit(context, MarkBindingsVisitation(finalBindings), bindings);

  visit(context, MarkImportsVisitation(context), finalBindings);

  // TODO(https://github.com/dart-lang/native/issues/1259): Remove libNamer when
  // renaming is another ordinary transformer.
  final libNamer = UniqueNamer()..markAllUsed(finalBindings.map((d) => d.name));
  context.libs.fillPrefixes(libNamer);

  final finalBindingsList = finalBindings.toList();

  /// Sort bindings.
  if (config.sort) {
    finalBindingsList.sortBy((b) => b.name);
    for (final b in finalBindingsList) {
      b.sort();
    }
  }

  /// Handle any declaration-declaration name conflicts and emit warnings.
  final declConflictHandler = UniqueNamer();
  for (final b in finalBindingsList) {
    _warnIfPrivateDeclaration(b, context.logger);
    _resolveIfNameConflicts(declConflictHandler, b, context.logger);
  }

  // Override pack values according to config. We do this after declaration
  // conflicts have been handled so that users can target the generated names.
  for (final b in finalBindingsList) {
    if (b is Struct) {
      final pack = config.structs.packingOverride(b);
      if (pack != null) {
        b.pack = pack.value;
      }
    }
  }

  return finalBindingsList;
}

/// Logs a warning if generated declaration will be private.
void _warnIfPrivateDeclaration(Binding b, Logger logger) {
  if (b.name.startsWith('_') && !b.isInternal) {
    logger.warning(
      "Generated declaration '${b.name}' starts with '_' "
      'and therefore will be private.',
    );
  }
}

/// Resolves name conflict(if any) and logs a warning.
void _resolveIfNameConflicts(UniqueNamer namer, Binding b, Logger logger) {
  // Print warning if name was conflicting and has been changed.
  final oldName = b.name;
  b.name = namer.makeUnique(b.name);
  if (oldName != b.name) {
    logger.warning(
      "Resolved name conflict: Declaration '$oldName' "
      "and has been renamed to '${b.name}'.",
    );
  }
}
