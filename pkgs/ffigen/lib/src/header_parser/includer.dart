// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility functions to check whether a binding should be parsed or not
/// based on filters.
library;

import '../config_provider/config_types.dart';
import '../strings.dart' as strings;
import 'data.dart';

bool _shouldIncludeDecl(
    String usr,
    String name,
    bool Function(String) isSeenDecl,
    bool Function(String, bool) configIncludes) {
  if (isSeenDecl(usr) || name == '') {
    return false;
  } else if (config.usrTypeMappings.containsKey(usr)) {
    return false;
  } else if (configIncludes(name, config.excludeAllByDefault)) {
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeStruct(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenType, config.structDecl.shouldInclude);
}

bool shouldIncludeUnion(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenType, config.unionDecl.shouldInclude);
}

bool shouldIncludeFunc(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenFunc, config.functionDecl.shouldInclude);
}

bool shouldIncludeEnumClass(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenType, config.enumClassDecl.shouldInclude);
}

bool shouldIncludeUnnamedEnumConstant(String usr, String name) {
  return _shouldIncludeDecl(usr, name, bindingsIndex.isSeenUnnamedEnumConstant,
      config.unnamedEnumConstants.shouldInclude);
}

bool shouldIncludeGlobalVar(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenGlobalVar, config.globals.shouldInclude);
}

bool shouldIncludeMacro(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenMacro, config.macroDecl.shouldInclude);
}

bool shouldIncludeTypealias(String usr, String name) {
  // Objective C has some core typedefs that are important to keep.
  if (config.language == Language.objc && name == strings.objcInstanceType) {
    return true;
  }
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenType, config.typedefs.shouldInclude);
}

bool shouldIncludeObjCInterface(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenType, config.objcInterfaces.shouldInclude);
}

bool shouldIncludeObjCProtocol(String usr, String name) {
  return _shouldIncludeDecl(usr, name, bindingsIndex.isSeenObjCProtocol,
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
        sourceFile, config.headers.includeFilter.shouldInclude(sourceFile));
  }

  return bindingsIndex.getSeenHeaderStatus(sourceFile)!;
}
