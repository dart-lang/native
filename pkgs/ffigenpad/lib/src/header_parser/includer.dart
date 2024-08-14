// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility functions to check whether a binding should be parsed or not
/// based on filters.
library;

import '../config_provider/config_types.dart';
import '../strings.dart' as strings;
import 'data.dart';

bool _shouldIncludeDecl(
    Declaration declaration,
    bool Function(String) isSeenDecl,
    bool Function(Declaration) configIncludes) {
  if (isSeenDecl(declaration.usr) || declaration.originalName == '') {
    return false;
  } else if (config.usrTypeMappings.containsKey(declaration.usr)) {
    return false;
  } else if (configIncludes(declaration)) {
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeStruct(Declaration declaration) {
  return _shouldIncludeDecl(
      declaration, bindingsIndex.isSeenType, config.structDecl.shouldInclude);
}

bool shouldIncludeUnion(Declaration declaration) {
  return _shouldIncludeDecl(
      declaration, bindingsIndex.isSeenType, config.unionDecl.shouldInclude);
}

bool shouldIncludeFunc(Declaration declaration) {
  return _shouldIncludeDecl(
      declaration, bindingsIndex.isSeenFunc, config.functionDecl.shouldInclude);
}

bool shouldIncludeEnumClass(Declaration declaration) {
  return _shouldIncludeDecl(declaration, bindingsIndex.isSeenType,
      config.enumClassDecl.shouldInclude);
}

bool shouldIncludeUnnamedEnumConstant(Declaration declaration) {
  return _shouldIncludeDecl(
      declaration,
      bindingsIndex.isSeenUnnamedEnumConstant,
      config.unnamedEnumConstants.shouldInclude);
}

bool shouldIncludeGlobalVar(Declaration declaration) {
  return _shouldIncludeDecl(
      declaration, bindingsIndex.isSeenGlobalVar, config.globals.shouldInclude);
}

bool shouldIncludeMacro(Declaration declaration) {
  return _shouldIncludeDecl(
      declaration, bindingsIndex.isSeenMacro, config.macroDecl.shouldInclude);
}

bool shouldIncludeTypealias(Declaration declaration) {
  // Objective C has some core typedefs that are important to keep.
  if (config.language == Language.objc &&
      declaration.originalName == strings.objcInstanceType) {
    return true;
  }
  return _shouldIncludeDecl(
      declaration, bindingsIndex.isSeenType, config.typedefs.shouldInclude);
}

bool shouldIncludeObjCInterface(Declaration declaration) {
  return _shouldIncludeDecl(declaration, bindingsIndex.isSeenType,
      config.objcInterfaces.shouldInclude);
}

bool shouldIncludeObjCProtocol(Declaration declaration) {
  return _shouldIncludeDecl(declaration, bindingsIndex.isSeenObjCProtocol,
      config.objcProtocols.shouldInclude);
}

/// True if a cursor should be included based on headers config, used on root
/// declarations.
bool shouldIncludeRootCursor(String sourceFile) {
  // Handle empty string in case of system headers or macros.
  if (sourceFile.isEmpty) {
    return false;
  }

  // Add header to seen if it's not.
  if (!bindingsIndex.isSeenHeader(sourceFile)) {
    bindingsIndex.addHeaderToSeen(
        sourceFile, config.shouldIncludeHeader(Uri.file(sourceFile)));
  }

  return bindingsIndex.getSeenHeaderStatus(sourceFile)!;
}
