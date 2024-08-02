// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'clang_bindings/clang_wrapper.dart' show Clang;

import 'utils.dart';

// /// Holds configurations.
// Config get config => _config;
// late Config _config;

/// Holds clang functions.
Clang get clang => _clang;
late Clang _clang;

// Cursor index.
CursorIndex get cursorIndex => _cursorIndex;
CursorIndex _cursorIndex = CursorIndex();

// // Tracks seen status for bindings
// BindingsIndex get bindingsIndex => _bindingsIndex;
// BindingsIndex _bindingsIndex = BindingsIndex();

/// Used for naming typedefs.
IncrementalNamer get incrementalNamer => _incrementalNamer;
IncrementalNamer _incrementalNamer = IncrementalNamer();

/// Saved macros, Key: prefixedName, Value originalName.
Map<String, Macro> get savedMacros => _savedMacros;
Map<String, Macro> _savedMacros = {};

/// Tracks if any source error/warning has occured which can potentially cause
/// invalid generated bindings.
bool hasSourceErrors = false;

// TODO
void initializeGlobals() {
  // _config = config;
  _clang = Clang();
  _incrementalNamer = IncrementalNamer();
  _savedMacros = {};
  // _unnamedEnumConstants = [];
  _cursorIndex = CursorIndex();
  // _bindingsIndex = BindingsIndex();
  // _objCBuiltInFunctions =
  //     ObjCBuiltInFunctions(config.generateForPackageObjectiveC);
  hasSourceErrors = false;
}
