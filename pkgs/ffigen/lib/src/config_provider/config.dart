// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:package_config/package_config.dart';

import '../code_generator.dart';
import 'config_impl.dart';
import 'config_types.dart';
import 'spec_utils.dart';

/// Provides configurations to other modules.
abstract interface class Config {
  /// Input config filename, if any.
  Uri? get filename;

  /// Package config.
  PackageConfig? get packageConfig;

  /// Path to the clang library.
  Uri get libclangDylib;

  /// Output file name.
  Uri get output;

  /// Output ObjC file name.
  Uri get outputObjC;

  /// Symbol file config.
  SymbolFile? get symbolFile;

  /// Language that ffigen is consuming.
  Language get language;

  /// Path to headers. May not contain globs.
  List<Uri> get entryPoints;

  /// Whether to include a specific header. This exists in addition to
  /// [entryPoints] to allow filtering of transitively included headers.
  bool shouldIncludeHeader(Uri header);

  /// CommandLine Arguments to pass to clang_compiler.
  List<String> get compilerOpts;

  /// VarArg function handling.
  Map<String, List<VarArgFunction>> get varArgFunctions;

  /// Declaration filters for Functions.
  DeclarationFilters get functionDecl;

  /// Declaration filters for Structs.
  DeclarationFilters get structDecl;

  /// Declaration filters for Unions.
  DeclarationFilters get unionDecl;

  /// Declaration filters for Enums.
  DeclarationFilters get enumClassDecl;

  /// Declaration filters for Unnamed enum constants.
  DeclarationFilters get unnamedEnumConstants;

  /// Declaration filters for Globals.
  DeclarationFilters get globals;

  /// Declaration filters for Macro constants.
  DeclarationFilters get macroDecl;

  /// Declaration filters for Typedefs.
  DeclarationFilters get typedefs;

  /// Declaration filters for Objective C interfaces.
  DeclarationFilters get objcInterfaces;

  /// Declaration filters for Objective C protocols.
  DeclarationFilters get objcProtocols;

  /// If enabled, unused typedefs will also be generated.
  bool get includeUnusedTypedefs;

  /// Undocumented option that changes code generation for package:objective_c.
  /// The main difference is whether NSObject etc are imported from
  /// package:objective_c (the default) or code genned like any other class.
  /// This is necessary because package:objective_c can't import NSObject from
  /// itself.
  bool get generateForPackageObjectiveC;

  /// If generated bindings should be sorted alphabetically.
  bool get sort;

  /// If typedef of supported types(int8_t) should be directly used.
  bool get useSupportedTypedefs;

  /// Stores all the library imports specified by user including those for ffi
  /// and pkg_ffi.
  Map<String, LibraryImport> get libraryImports;

  /// Stores all the symbol file maps name to ImportedType mappings specified by
  /// user.
  Map<String, ImportedType> get usrTypeMappings;

  /// Stores typedef name to ImportedType mappings specified by user.
  Map<String, ImportedType> get typedefTypeMappings;

  /// Stores struct name to ImportedType mappings specified by user.
  Map<String, ImportedType> get structTypeMappings;

  /// Stores union name to ImportedType mappings specified by user.
  Map<String, ImportedType> get unionTypeMappings;

  /// Stores native int name to ImportedType mappings specified by user.
  Map<String, ImportedType> get nativeTypeMappings;

  /// Extracted Doc comment type.
  CommentType get commentType;

  /// Whether structs that are dependencies should be included.
  CompoundDependencies get structDependencies;

  /// Whether unions that are dependencies should be included.
  CompoundDependencies get unionDependencies;

  /// Whether, and how, to override struct packing for the given struct.
  PackingValue? structPackingOverride(Declaration declaration);

  /// The module that the ObjC interface belongs to.
  String? interfaceModule(Declaration declaration);

  /// The module that the ObjC protocol belongs to.
  String? protocolModule(Declaration declaration);

  /// Name of the wrapper class.
  String get wrapperName;

  /// Doc comment for the wrapper class.
  String? get wrapperDocComment;

  /// Header of the generated bindings.
  String? get preamble;

  /// If `Dart_Handle` should be mapped with Handle/Object.
  bool get useDartHandle;

  /// Whether to silence warning for enum integer type mimicking.
  bool get silenceEnumWarning;

  /// Whether to expose the function typedef for a given function.
  bool shouldExposeFunctionTypedef(Declaration declaration);

  /// Whether the given function is a leaf function.
  bool isLeafFunction(Declaration declaration);

  /// Whether to generate the given enum as a series of int constants, rather
  /// than a real Dart enum.
  bool enumShouldBeInt(Declaration declaration);

  /// Whether to generate the given unnamed enum as a series of int constants,
  /// rather than a real Dart enum.
  bool unnamedEnumsShouldBeInt(Declaration declaration);

  /// Config options for @Native annotations.
  FfiNativeConfig get ffiNativeConfig;

  /// Where to ignore compiler warnings/errors in source header files.
  bool get ignoreSourceErrors;

  /// Whether to format the output file.
  bool get formatOutput;

  /// Minimum target versions for ObjC APIs, per OS. APIs that were deprecated
  /// before this version will not be generated.
  ObjCTargetVersion get objCMinTargetVersion;

  factory Config({
    Uri? filename,
    PackageConfig? packageConfig,
    Uri? libclangDylib,
    required Uri output,
    Uri? outputObjC,
    SymbolFile? symbolFile,
    Language language = Language.c,
    required List<Uri> entryPoints,
    bool Function(Uri header)? shouldIncludeHeaderFunc,
    List<String> compilerOpts = const <String>[],
    Map<String, List<VarArgFunction>> varArgFunctions =
        const <String, List<VarArgFunction>>{},
    DeclarationFilters? functionDecl,
    DeclarationFilters? structDecl,
    DeclarationFilters? unionDecl,
    DeclarationFilters? enumClassDecl,
    DeclarationFilters? unnamedEnumConstants,
    DeclarationFilters? globals,
    DeclarationFilters? macroDecl,
    DeclarationFilters? typedefs,
    DeclarationFilters? objcInterfaces,
    DeclarationFilters? objcProtocols,
    bool includeUnusedTypedefs = false,
    bool generateForPackageObjectiveC = false,
    bool sort = false,
    bool useSupportedTypedefs = true,
    List<LibraryImport> libraryImports = const <LibraryImport>[],
    List<ImportedType> usrTypeMappings = const <ImportedType>[],
    List<ImportedType> typedefTypeMappings = const <ImportedType>[],
    List<ImportedType> structTypeMappings = const <ImportedType>[],
    List<ImportedType> unionTypeMappings = const <ImportedType>[],
    List<ImportedType> nativeTypeMappings = const <ImportedType>[],
    CommentType? commentType,
    CompoundDependencies structDependencies = CompoundDependencies.full,
    CompoundDependencies unionDependencies = CompoundDependencies.full,
    PackingValue? Function(Declaration declaration)? structPackingOverrideFunc,
    String? Function(Declaration declaration)? interfaceModuleFunc,
    String? Function(Declaration declaration)? protocolModuleFunc,
    String wrapperName = 'NativeLibrary',
    String? wrapperDocComment,
    String? preamble,
    bool useDartHandle = true,
    bool silenceEnumWarning = false,
    bool Function(Declaration declaration)? shouldExposeFunctionTypedefFunc,
    bool Function(Declaration declaration)? isLeafFunctionFunc,
    bool Function(Declaration declaration)? enumShouldBeIntFunc,
    bool Function(Declaration declaration)? unnamedEnumsShouldBeIntFunc,
    FfiNativeConfig ffiNativeConfig = const FfiNativeConfig(enabled: false),
    bool ignoreSourceErrors = false,
    bool formatOutput = true,
    ObjCTargetVersion objCMinTargetVersion = const ObjCTargetVersion(),
  }) =>
      ConfigImpl(
        filename: filename == null ? null : Uri.file(filename.toFilePath()),
        packageConfig: packageConfig,
        libclangDylib: Uri.file(
            libclangDylib?.toFilePath() ?? findDylibAtDefaultLocations()),
        output: Uri.file(output.toFilePath()),
        outputObjC:
            Uri.file(outputObjC?.toFilePath() ?? '${output.toFilePath()}.m'),
        symbolFile: symbolFile,
        language: language,
        entryPoints: entryPoints,
        shouldIncludeHeaderFunc: shouldIncludeHeaderFunc ?? (_) => true,
        compilerOpts: compilerOpts,
        varArgFunctions: varArgFunctions,
        functionDecl: functionDecl ?? DeclarationFilters.excludeAll,
        structDecl: structDecl ?? DeclarationFilters.excludeAll,
        unionDecl: unionDecl ?? DeclarationFilters.excludeAll,
        enumClassDecl: enumClassDecl ?? DeclarationFilters.excludeAll,
        unnamedEnumConstants:
            unnamedEnumConstants ?? DeclarationFilters.excludeAll,
        globals: globals ?? DeclarationFilters.excludeAll,
        macroDecl: macroDecl ?? DeclarationFilters.excludeAll,
        typedefs: typedefs ?? DeclarationFilters.excludeAll,
        objcInterfaces: objcInterfaces ?? DeclarationFilters.excludeAll,
        objcProtocols: objcProtocols ?? DeclarationFilters.excludeAll,
        includeUnusedTypedefs: includeUnusedTypedefs,
        generateForPackageObjectiveC: generateForPackageObjectiveC,
        sort: sort,
        useSupportedTypedefs: useSupportedTypedefs,
        libraryImports: Map<String, LibraryImport>.fromEntries(
            libraryImports.map((import) =>
                MapEntry<String, LibraryImport>(import.name, import))),
        usrTypeMappings: Map<String, ImportedType>.fromEntries(
            usrTypeMappings.map((import) =>
                MapEntry<String, ImportedType>(import.nativeType, import))),
        typedefTypeMappings: Map<String, ImportedType>.fromEntries(
            typedefTypeMappings.map((import) =>
                MapEntry<String, ImportedType>(import.nativeType, import))),
        structTypeMappings: Map<String, ImportedType>.fromEntries(
            structTypeMappings.map((import) =>
                MapEntry<String, ImportedType>(import.nativeType, import))),
        unionTypeMappings: Map<String, ImportedType>.fromEntries(
            unionTypeMappings.map((import) =>
                MapEntry<String, ImportedType>(import.nativeType, import))),
        nativeTypeMappings: Map<String, ImportedType>.fromEntries(
            nativeTypeMappings.map((import) =>
                MapEntry<String, ImportedType>(import.nativeType, import))),
        commentType: commentType ?? CommentType.def(),
        structDependencies: structDependencies,
        unionDependencies: unionDependencies,
        structPackingOverrideFunc: structPackingOverrideFunc ?? (_) => null,
        interfaceModuleFunc: interfaceModuleFunc ?? (_) => null,
        protocolModuleFunc: protocolModuleFunc ?? (_) => null,
        wrapperName: wrapperName,
        wrapperDocComment: wrapperDocComment,
        preamble: preamble,
        useDartHandle: useDartHandle,
        silenceEnumWarning: silenceEnumWarning,
        shouldExposeFunctionTypedefFunc:
            shouldExposeFunctionTypedefFunc ?? (_) => false,
        isLeafFunctionFunc: isLeafFunctionFunc ?? (_) => false,
        enumShouldBeIntFunc: enumShouldBeIntFunc ?? (_) => false,
        unnamedEnumsShouldBeIntFunc:
            unnamedEnumsShouldBeIntFunc ?? (_) => false,
        ffiNativeConfig: ffiNativeConfig,
        ignoreSourceErrors: ignoreSourceErrors,
        formatOutput: formatOutput,
        objCMinTargetVersion: objCMinTargetVersion,
      );
}

abstract interface class DeclarationFilters {
  /// Checks if a name is allowed by a filter.
  bool shouldInclude(Declaration declaration);

  /// Checks if the symbol address should be included for this name.
  bool shouldIncludeSymbolAddress(Declaration declaration);

  /// Applies renaming and returns the result.
  String rename(Declaration declaration);

  /// Applies member renaming and returns the result.
  String renameMember(Declaration declaration, String member);

  factory DeclarationFilters({
    bool Function(Declaration declaration)? shouldInclude,
    bool Function(Declaration declaration)? shouldIncludeSymbolAddress,
    String Function(Declaration declaration)? rename,
    String Function(Declaration declaration, String member)? renameMember,
  }) =>
      DeclarationFiltersImpl(
        shouldIncludeFunc: shouldInclude ?? (_) => false,
        shouldIncludeSymbolAddressFunc:
            shouldIncludeSymbolAddress ?? (_) => false,
        renameFunc: rename ?? (declaration) => declaration.originalName,
        renameMemberFunc: renameMember ?? (_, member) => member,
      );

  static final excludeAll = DeclarationFilters();
  static final includeAll = DeclarationFilters(shouldInclude: (_) => true);
}
