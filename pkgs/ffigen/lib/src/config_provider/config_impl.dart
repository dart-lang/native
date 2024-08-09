// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:package_config/package_config.dart';

import '../code_generator.dart';
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
  final DeclarationFilters functionDecl;

  @override
  final DeclarationFilters structDecl;

  @override
  final DeclarationFilters unionDecl;

  @override
  final DeclarationFilters enumClassDecl;

  @override
  final DeclarationFilters unnamedEnumConstants;

  @override
  final DeclarationFilters globals;

  @override
  final DeclarationFilters macroDecl;

  @override
  final DeclarationFilters typedefs;

  @override
  final DeclarationFilters objcInterfaces;

  @override
  final DeclarationFilters objcProtocols;

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
  PackingValue? structPackingOverride(Declaration declaration) =>
      structPackingOverrideFunc(declaration);
  final PackingValue? Function(Declaration declaration)
      structPackingOverrideFunc;

  @override
  String? interfaceModule(Declaration declaration) =>
      interfaceModuleFunc(declaration);
  final String? Function(Declaration declaration) interfaceModuleFunc;

  @override
  String? protocolModule(Declaration declaration) =>
      protocolModuleFunc(declaration);
  final String? Function(Declaration declaration) protocolModuleFunc;

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
  bool shouldExposeFunctionTypedef(Declaration declaration) =>
      shouldExposeFunctionTypedefFunc(declaration);
  final bool Function(Declaration declaration) shouldExposeFunctionTypedefFunc;

  @override
  bool isLeafFunction(Declaration declaration) =>
      isLeafFunctionFunc(declaration);
  final bool Function(Declaration declaration) isLeafFunctionFunc;

  @override
  bool enumShouldBeInt(Declaration declaration) =>
      enumShouldBeIntFunc(declaration);
  final bool Function(Declaration declaration) enumShouldBeIntFunc;

  @override
  bool unnamedEnumsShouldBeInt(Declaration declaration) =>
      unnamedEnumsShouldBeIntFunc(declaration);
  final bool Function(Declaration declaration) unnamedEnumsShouldBeIntFunc;

  @override
  final FfiNativeConfig ffiNativeConfig;

  @override
  final bool ignoreSourceErrors;

  @override
  final bool formatOutput;

  @override
  final ObjCTargetVersion objCMinTargetVersion;

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
    required this.interfaceModuleFunc,
    required this.protocolModuleFunc,
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
    required this.objCMinTargetVersion,
  });
}

class DeclarationFiltersImpl implements DeclarationFilters {
  @override
  String rename(Declaration declaration) => renameFunc(declaration);
  final String Function(Declaration declaration) renameFunc;

  @override
  String renameMember(Declaration declaration, String member) =>
      renameMemberFunc(declaration, member);
  final String Function(Declaration declaration, String member)
      renameMemberFunc;

  @override
  bool shouldInclude(Declaration declaration) => shouldIncludeFunc(declaration);
  final bool Function(Declaration declaration) shouldIncludeFunc;

  @override
  bool shouldIncludeSymbolAddress(Declaration declaration) =>
      shouldIncludeSymbolAddressFunc(declaration);
  final bool Function(Declaration declaration) shouldIncludeSymbolAddressFunc;

  DeclarationFiltersImpl({
    required this.renameFunc,
    required this.renameMemberFunc,
    required this.shouldIncludeFunc,
    required this.shouldIncludeSymbolAddressFunc,
  });
}
