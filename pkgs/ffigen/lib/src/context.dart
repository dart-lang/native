// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:logging/logging.dart';

import 'code_generator.dart' show Constant, ObjCBuiltInFunctions;
import 'config_provider/config.dart';
import 'config_provider/config_types.dart';
import 'config_provider/spec_utils.dart';
import 'header_parser/clang_bindings/clang_bindings.dart' show Clang;
import 'header_parser/utils.dart';

/// Wrapper around various ffigen-wide variables.
class Context {
  final Logger logger;

  final Config config;

  final CursorIndex cursorIndex;

  final BindingsIndex bindingsIndex = BindingsIndex();

  final IncrementalNamer incrementalNamer = IncrementalNamer();

  final Map<String, Macro> savedMacros = {};

  final List<Constant> unnamedEnumConstants = [];

  final ObjCBuiltInFunctions objCBuiltInFunctions;

  bool hasSourceErrors = false;

  Set<((String, int), (String, int))> reportedCommentRanges = {};

  late final compilerOpts = config.compilerOpts ?? defaultCompilerOpts(logger);

  Context(this.logger, FfiGen config, {Uri? libclangDylib})
    : config = Config(config),
      cursorIndex = CursorIndex(logger),
      objCBuiltInFunctions = ObjCBuiltInFunctions(
        config.wrapperName,
        config.generateForPackageObjectiveC,
      ) {
    final libclangDylibPath =
        config.libclangDylib?.toFilePath() ??
        libclangDylib?.toFilePath() ??
        findDylibAtDefaultLocations(logger);
    _clang ??= Clang(DynamicLibrary.open(libclangDylibPath));
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
