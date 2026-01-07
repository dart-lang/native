// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:logging/logging.dart';

import 'code_generator.dart';
import 'code_generator/scope.dart';
import 'config_provider/config.dart';
import 'config_provider/config_types.dart';
import 'config_provider/spec_utils.dart';
import 'header_parser/clang_bindings/clang_bindings.dart' show Clang;
import 'header_parser/utils.dart';

/// Wrapper around various FFIgen-wide variables.
class Context {
  final Logger logger;
  final Config config;
  final bindingsIndex = BindingsIndex();
  final savedMacros = <String, Macro>{};
  final unnamedEnumConstants = <Constant>[];
  late final ObjCBuiltInFunctions objCBuiltInFunctions;
  bool hasSourceErrors = false;
  final reportedCommentRanges = <((String, int), (String, int))>{};
  final libs = LibraryImports();
  late final compilerOpts =
      config.headers.compilerOptions ?? defaultCompilerOpts(logger);
  final Scope rootScope = Scope.createRoot('root');
  final Scope rootObjCScope = Scope.createRoot('objc_root');
  late final ExtraSymbols extraSymbols;

  Context(this.logger, FfiGenerator generator, {Uri? libclangDylib})
    : config = Config(generator) {
    objCBuiltInFunctions = ObjCBuiltInFunctions(
      this,
      // ignore: deprecated_member_use_from_same_package
      generator.objectiveC?.generateForPackageObjectiveC ?? false,
    );
    final libclangDylibPath =
        // ignore: deprecated_member_use_from_same_package
        generator.libclangDylib?.toFilePath() ??
        libclangDylib?.toFilePath() ??
        findDylibAtDefaultLocations(logger);
    _clang ??= Clang(DynamicLibrary.open(libclangDylibPath));
  }
}

/// The clang bindings.
//
// Ideally this would be in the Context, but the plumbing needed would be
// excessive. The point of putting globals in the Context is to allow multiple
// concurrent FFIgen runs without any risk of clobbering global state. The
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

  final _used = <LibraryImport>{};

  // Call after all used imports have been marked by [markUsed]. Creates Symbols
  // for all the library prefixes used for codegen.
  void createSymbols(Scope scope) {
    for (final lib in _used) {
      scope.add(_prefixes[lib] = Symbol(lib.name, SymbolKind.lib));
    }

    _prefixesFilled = true;
  }

  bool _prefixesFilled = false;
  final _prefixes = <LibraryImport, Symbol>{};

  String prefix(LibraryImport lib) {
    assert(lib == canonicalize(lib));
    if (!_prefixesFilled) {
      // Before the prefixes have been filled, return a placeholder suitable for
      // debugging or hashing, but intentionally invalid as generated code.
      return '<${lib.name}>';
    }
    // If this null assert fails, it means that a library was used during code
    // generation that wasn't visited by MarkImportsVisitation, which is a bug.
    return _prefixes[lib]!.name;
  }

  void forceFillForTesting() {
    _used.addAll(builtInLibraries.values);
    for (final lib in _used) {
      _prefixes[lib] = Symbol(lib.name, SymbolKind.lib)..forceFillForTesting();
    }
    _prefixesFilled = true;
  }
}

typedef ExtraSymbols = ({
  Symbol? wrapperClassName,
  Symbol? lookupFuncName,
  // TODO(https://github.com/dart-lang/native/issues/1259): Make this nullable.
  Symbol symbolAddressVariableName,
});
