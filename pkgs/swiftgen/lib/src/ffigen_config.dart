// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart' as fg;
import 'package:package_config/package_config.dart';

class FfiGenConfig implements fg.Config {
  final fg.Config _delegate;
  final List<Uri> _entryPoints;
  final List<String> _compileOpts;
  final String _outModule;

  FfiGenConfig(
    this._delegate,
    this._entryPoints,
    this._compileOpts,
    this._outModule,
  );

  @override
  Uri? get filename => _delegate.filename;

  @override
  PackageConfig? get packageConfig => _delegate.packageConfig;

  @override
  Uri get libclangDylib => _delegate.libclangDylib;

  @override
  Uri get output => _delegate.output;

  @override
  Uri get outputObjC => _delegate.outputObjC;

  @override
  fg.SymbolFile? get symbolFile => _delegate.symbolFile;

  @override
  fg.Language get language => fg.Language.objc;

  @override
  List<Uri> get entryPoints => _entryPoints;

  @override
  bool shouldIncludeHeader(Uri header) => _delegate.shouldIncludeHeader(header);

  @override
  List<String> get compilerOpts => _compileOpts;

  @override
  Map<String, List<fg.VarArgFunction>> get varArgFunctions =>
      _delegate.varArgFunctions;

  @override
  fg.DeclarationFilters get functionDecl => _delegate.functionDecl;

  @override
  fg.DeclarationFilters get structDecl => _delegate.structDecl;

  @override
  fg.DeclarationFilters get unionDecl => _delegate.unionDecl;

  @override
  fg.DeclarationFilters get enumClassDecl => _delegate.enumClassDecl;

  @override
  fg.DeclarationFilters get unnamedEnumConstants =>
      _delegate.unnamedEnumConstants;

  @override
  fg.DeclarationFilters get globals => _delegate.globals;

  @override
  fg.DeclarationFilters get macroDecl => _delegate.macroDecl;

  @override
  fg.DeclarationFilters get typedefs => _delegate.typedefs;

  @override
  fg.DeclarationFilters get objcInterfaces => _delegate.objcInterfaces;

  @override
  fg.DeclarationFilters get objcProtocols => _delegate.objcProtocols;

  @override
  fg.DeclarationFilters get objcCategories => _delegate.objcCategories;

  @override
  bool get includeUnusedTypedefs => _delegate.includeUnusedTypedefs;

  @override
  bool get includeTransitiveObjCInterfaces =>
      _delegate.includeTransitiveObjCInterfaces;

  @override
  bool get includeTransitiveObjCProtocols =>
      _delegate.includeTransitiveObjCProtocols;

  @override
  bool get includeTransitiveObjCCategories =>
      _delegate.includeTransitiveObjCCategories;

  @override
  bool get generateForPackageObjectiveC =>
      _delegate.generateForPackageObjectiveC;

  @override
  bool get sort => _delegate.sort;

  @override
  bool get useSupportedTypedefs => _delegate.useSupportedTypedefs;

  @override
  Map<String, fg.LibraryImport> get libraryImports => _delegate.libraryImports;

  @override
  Map<String, fg.ImportedType> get usrTypeMappings => _delegate.usrTypeMappings;

  @override
  Map<String, fg.ImportedType> get typedefTypeMappings =>
      _delegate.typedefTypeMappings;

  @override
  Map<String, fg.ImportedType> get structTypeMappings =>
      _delegate.structTypeMappings;

  @override
  Map<String, fg.ImportedType> get unionTypeMappings =>
      _delegate.unionTypeMappings;

  @override
  Map<String, fg.ImportedType> get nativeTypeMappings =>
      _delegate.nativeTypeMappings;

  @override
  fg.CommentType get commentType => _delegate.commentType;

  @override
  fg.CompoundDependencies get structDependencies =>
      _delegate.structDependencies;

  @override
  fg.CompoundDependencies get unionDependencies => _delegate.unionDependencies;

  @override
  fg.PackingValue? structPackingOverride(fg.Declaration declaration) =>
      _delegate.structPackingOverride(declaration);

  @override
  String? interfaceModule(fg.Declaration declaration) => _outModule;

  @override
  String? protocolModule(fg.Declaration declaration) => _outModule;

  @override
  String get wrapperName => _delegate.wrapperName;

  @override
  String? get wrapperDocComment => _delegate.wrapperDocComment;

  @override
  String? get preamble => _delegate.preamble;

  @override
  bool get useDartHandle => _delegate.useDartHandle;

  @override
  bool get silenceEnumWarning => _delegate.silenceEnumWarning;

  @override
  bool shouldExposeFunctionTypedef(fg.Declaration declaration) =>
      _delegate.shouldExposeFunctionTypedef(declaration);

  @override
  bool isLeafFunction(fg.Declaration declaration) =>
      _delegate.isLeafFunction(declaration);

  @override
  bool enumShouldBeInt(fg.Declaration declaration) =>
      _delegate.enumShouldBeInt(declaration);

  @override
  bool unnamedEnumsShouldBeInt(fg.Declaration declaration) =>
      _delegate.unnamedEnumsShouldBeInt(declaration);

  @override
  fg.FfiNativeConfig get ffiNativeConfig => _delegate.ffiNativeConfig;

  @override
  bool get ignoreSourceErrors => _delegate.ignoreSourceErrors;

  @override
  bool get formatOutput => _delegate.formatOutput;

  @override
  fg.ExternalVersions get externalVersions => _delegate.externalVersions;
}
