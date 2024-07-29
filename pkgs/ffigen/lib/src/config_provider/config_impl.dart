// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'config.dart';
import 'config_types.dart';

class ConfigImpl implements Config {
  @override
  final Uri? filename;

  @override
  final PackageConfig? packageConfig;

  @override
  final Uri libclangDylib;

  @override
  final Uri output;

  @override
  final Uri outputObjC;

  @override
  final SymbolFile? symbolFile;

  @override
  final Language language;

  @override
  final List<Uri> entryPoints;

  @override
  bool shouldIncludeHeader(Uri header) => shouldIncludeHeaderFunc(header);
  final bool Function(Uri header) shouldIncludeHeaderFunc;

  @override
  final List<String> compilerOpts;

  @override
  final Map<String, List<VarArgFunction>> varArgFunctions;

  @override
  final Declaration functionDecl;

  @override
  final Declaration structDecl;

  @override
  final Declaration unionDecl;

  @override
  final Declaration enumClassDecl;

  @override
  final Declaration unnamedEnumConstants;

  @override
  final Declaration globals;

  @override
  final Declaration macroDecl;

  @override
  final Declaration typedefs;

  @override
  final Declaration objcInterfaces;

  @override
  final Declaration objcProtocols;

  @override
  final bool includeUnusedTypedefs;

  @override
  final bool generateForPackageObjectiveC;

  @override
  final bool sort;

  @override
  final bool useSupportedTypedefs;

  @override
  final Map<String, LibraryImport> libraryImports;

  @override
  final Map<String, ImportedType> usrTypeMappings;

  @override
  final Map<String, ImportedType> typedefTypeMappings;

  @override
  final Map<String, ImportedType> structTypeMappings;

  @override
  final Map<String, ImportedType> unionTypeMappings;

  @override
  final Map<String, ImportedType> nativeTypeMappings;

  @override
  final CommentType commentType;

  @override
  final CompoundDependencies structDependencies;

  @override
  final CompoundDependencies unionDependencies;

  @override
  PackingValue? structPackingOverride(String name) =>
      structPackingOverrideFunc(name);
  final PackingValue? Function(String name) structPackingOverrideFunc;

  @override
  String applyInterfaceModulePrefix(String interfaceName) =>
      applyInterfaceModulePrefixFunc(interfaceName);
  final String Function(String interfaceName) applyInterfaceModulePrefixFunc;

  @override
  String applyProtocolModulePrefix(String protocolName) =>
      applyProtocolModulePrefixFunc(protocolName);
  final String Function(String protocolName) applyProtocolModulePrefixFunc;

  @override
  final String wrapperName;

  @override
  final String? wrapperDocComment;

  @override
  final String? preamble;

  @override
  final bool useDartHandle;

  @override
  final bool silenceEnumWarning;

  @override
  bool shouldExposeFunctionTypedef(String name) =>
      shouldExposeFunctionTypedefFunc(name);
  final bool Function(String name) shouldExposeFunctionTypedefFunc;

  @override
  bool isLeafFunction(String name) => isLeafFunctionFunc(name);
  final bool Function(String name) isLeafFunctionFunc;

  @override
  bool enumShouldBeInt(String name) => enumShouldBeIntFunc(name);
  final bool Function(String name) enumShouldBeIntFunc;

  @override
  bool unnamedEnumsShouldBeInt(String name) =>
      unnamedEnumsShouldBeIntFunc(name);
  final bool Function(String name) unnamedEnumsShouldBeIntFunc;

  @override
  final FfiNativeConfig ffiNativeConfig;

  @override
  final bool ignoreSourceErrors;

  @override
  final bool formatOutput;

  ConfigImpl({
    required this.filename,
    required this.packageConfig,
    required this.libclangDylib,
    required this.output,
    required this.outputObjC,
    required this.symbolFile,
    required this.language,
    required this.entryPoints,
    required this.shouldIncludeHeaderFunc,
    required this.compilerOpts,
    required this.varArgFunctions,
    required this.functionDecl,
    required this.structDecl,
    required this.unionDecl,
    required this.enumClassDecl,
    required this.unnamedEnumConstants,
    required this.globals,
    required this.macroDecl,
    required this.typedefs,
    required this.objcInterfaces,
    required this.objcProtocols,
    required this.includeUnusedTypedefs,
    required this.generateForPackageObjectiveC,
    required this.sort,
    required this.useSupportedTypedefs,
    required this.libraryImports,
    required this.usrTypeMappings,
    required this.typedefTypeMappings,
    required this.structTypeMappings,
    required this.unionTypeMappings,
    required this.nativeTypeMappings,
    required this.commentType,
    required this.structDependencies,
    required this.unionDependencies,
    required this.structPackingOverrideFunc,
    required this.applyInterfaceModulePrefixFunc,
    required this.applyProtocolModulePrefixFunc,
    required this.wrapperName,
    required this.wrapperDocComment,
    required this.preamble,
    required this.useDartHandle,
    required this.silenceEnumWarning,
    required this.shouldExposeFunctionTypedefFunc,
    required this.isLeafFunctionFunc,
    required this.enumShouldBeIntFunc,
    required this.unnamedEnumsShouldBeIntFunc,
    required this.ffiNativeConfig,
    required this.ignoreSourceErrors,
    required this.formatOutput,
  });
}

class DeclarationImpl implements Declaration {
  @override
  String rename(String name) => renameFunc(name);
  final String Function(String name) renameFunc;

  @override
  String renameMember(String declaration, String member) =>
      renameMemberFunc(declaration, member);
  final String Function(String declaration, String member) renameMemberFunc;

  @override
  bool shouldInclude(String name) => shouldIncludeFunc(name);
  final bool Function(String name) shouldIncludeFunc;

  @override
  bool shouldIncludeSymbolAddress(String name) =>
      shouldIncludeSymbolAddressFunc(name);
  final bool Function(String name) shouldIncludeSymbolAddressFunc;

  DeclarationImpl({
    required this.renameFunc,
    required this.renameMemberFunc,
    required this.shouldIncludeFunc,
    required this.shouldIncludeSymbolAddressFunc,
  });
}
