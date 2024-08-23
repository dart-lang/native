// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart' show Constant, ObjCBuiltInFunctions;
import '../config_provider.dart' show Config;
import 'clang_bindings/clang_wrapper.dart' show Clang;

import 'utils.dart';

// /// Holds configurations.
Config get config => _config;
late Config _config;

/// Holds clang functions.
Clang get clang => _clang;
Clang _clang = Clang();

// Cursor index.
CursorIndex get cursorIndex => _cursorIndex;
CursorIndex _cursorIndex = CursorIndex();

// // Tracks seen status for bindings
BindingsIndex get bindingsIndex => _bindingsIndex;
BindingsIndex _bindingsIndex = BindingsIndex();

/// Used for naming typedefs.
IncrementalNamer get incrementalNamer => _incrementalNamer;
IncrementalNamer _incrementalNamer = IncrementalNamer();

/// Saved macros, Key: prefixedName, Value originalName.
Map<String, Macro> get savedMacros => _savedMacros;
Map<String, Macro> _savedMacros = {};

/// Saved unnamed EnumConstants.
List<Constant> get unnamedEnumConstants => _unnamedEnumConstants;
List<Constant> _unnamedEnumConstants = [];

/// Built in functions used by the Objective C bindings.
ObjCBuiltInFunctions get objCBuiltInFunctions => _objCBuiltInFunctions;
late ObjCBuiltInFunctions _objCBuiltInFunctions;

/// Tracks if any source error/warning has occured which can potentially cause
/// invalid generated bindings.
bool hasSourceErrors = false;

void initializeGlobals({required Config config}) {
  _config = config;
  _clang = Clang();
  _incrementalNamer = IncrementalNamer();
  _savedMacros = {};
  _unnamedEnumConstants = [];
  _cursorIndex = CursorIndex();
  _bindingsIndex = BindingsIndex();
  _objCBuiltInFunctions =
      ObjCBuiltInFunctions(config.generateForPackageObjectiveC);
  hasSourceErrors = false;
}