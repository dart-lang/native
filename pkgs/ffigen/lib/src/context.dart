// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:logging/logging.dart';

import 'code_generator.dart';
import 'code_generator/unique_namer.dart';
import 'config_provider.dart' show FfiGen;
import 'header_parser/clang_bindings/clang_bindings.dart' show Clang;
import 'header_parser/utils.dart';

/// Wrapper around various ffigen-wide variables.
class Context {
  final Logger logger;

  final FfiGen config;

  final CursorIndex cursorIndex;

  final bindingsIndex = BindingsIndex();

  final incrementalNamer = IncrementalNamer();

  final savedMacros = <String, Macro>{};

  final unnamedEnumConstants = <Constant>[];

  final ObjCBuiltInFunctions objCBuiltInFunctions;

  bool hasSourceErrors = false;

  final reportedCommentRanges = <((String, int), (String, int))>{};

  final libs = LibraryImports();

  Context(this.logger, this.config)
    : cursorIndex = CursorIndex(logger),
      objCBuiltInFunctions = ObjCBuiltInFunctions(
        config.wrapperName,
        config.generateForPackageObjectiveC,
      ) {
    _clang ??= Clang(DynamicLibrary.open(config.libclangDylib.toFilePath()));
  }
}

/// The clang bindings.
//
// Ideally this would be in the Context, but the plumbing needed would be
// excessive. The point of putting globals in the Context is to allow multiple
// concurrent FfiGen runs without any risk of clobbering global state. The
// clang bindings are loaded from a dylib specified by the config, so it's
// possible that two different versions of clang could be loaded. But since we
// interact with clang through a stable API, there's no real danger of version
// skew. So the safest thing is to simply load clang the first time a Context
// is created, and reuse it for all subsequent runs.
Clang get clang => _clang!;
Clang? _clang;

class LibraryImports {
  String get ffiLibraryPrefix => prefix(ffiImport);
  String get ffiPkgLibraryPrefix => prefix(ffiPkgImport);
  String get objcPkgPrefix => prefix(objcPkgImport);
  String get selfImportPrefix => prefix(selfImport);

  // Dedupe [lib] by name.
  LibraryImport canonicalize(LibraryImport lib) =>
      builtInLibraries[lib.name] ?? (_canonicalImports[lib.name] ??= lib);
  final _canonicalImports = <String, LibraryImport>{};

  // Mark an import as being used so that it can be assigned a prefix.
  void markUsed(LibraryImport lib) {
    assert(lib == canonicalize(lib));
    _used.add(lib);
  }

  Iterable<LibraryImport> get used => _used;

  final _used = <LibraryImport>{...builtInLibraries.values};

  // Call after all used imports have been marked by [markUsed]. Fills the
  // library prefixes used for codegen.
  void fillPrefixes() {
    final namer = UniqueNamer();

    for (final lib in _used) {
      _prefixes[lib] = namer.makeUnique(lib.name);
    }

    _prefixesFilled = true;
  }

  bool _prefixesFilled = false;
  final _prefixes = <LibraryImport, String>{};

  String prefix(LibraryImport lib) {
    assert(lib == canonicalize(lib));
    if (!_prefixesFilled) {
      // Before the prefixes have been filled, return a placeholder suitable for
      // debugging or hashing, but intentionally invalid as generated code.
      return '<${lib.name}>';
    }
    // If this null assert fails, it means that a library was used during code
    // generation that wasn't visited by MarkImportsVisitation, which is a bug.
    return _prefixes[lib]!;
  }
}
