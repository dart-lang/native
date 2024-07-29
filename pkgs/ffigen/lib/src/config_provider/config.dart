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

  /// Declaration config for Functions.
  Declaration get functionDecl;

  /// Declaration config for Structs.
  Declaration get structDecl;

  /// Declaration config for Unions.
  Declaration get unionDecl;

  /// Declaration config for Enums.
  Declaration get enumClassDecl;

  /// Declaration config for Unnamed enum constants.
  Declaration get unnamedEnumConstants;

  /// Declaration config for Globals.
  Declaration get globals;

  /// Declaration config for Macro constants.
  Declaration get macroDecl;

  /// Declaration config for Typedefs.
  Declaration get typedefs;

  /// Declaration config for Objective C interfaces.
  Declaration get objcInterfaces;

  /// Declaration config for Objective C protocols.
  Declaration get objcProtocols;

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
  PackingValue? structPackingOverride(String name);

  /// The module that the ObjC interface belongs to.
  String? interfaceModule(String interfaceName);

  /// The module that the ObjC protocol belongs to.
  String? protocolModule(String protocolName);

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
  bool shouldExposeFunctionTypedef(String name);

  /// Whether the given function is a leaf function.
  bool isLeafFunction(String name);

  /// Whether to generate the given enum as a series of int constants, rather
  /// than a real Dart enum.
  bool enumShouldBeInt(String name);

  /// Whether to generate the given unnamed enum as a series of int constants,
  /// rather than a real Dart enum.
  bool unnamedEnumsShouldBeInt(String name);

  /// Config options for @Native annotations.
  FfiNativeConfig get ffiNativeConfig;

  /// Where to ignore compiler warnings/errors in source header files.
  bool get ignoreSourceErrors;

  /// Whether to format the output file.
  bool get formatOutput;

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
    Declaration? functionDecl,
    Declaration? structDecl,
    Declaration? unionDecl,
    Declaration? enumClassDecl,
    Declaration? unnamedEnumConstants,
    Declaration? globals,
    Declaration? macroDecl,
    Declaration? typedefs,
    Declaration? objcInterfaces,
    Declaration? objcProtocols,
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
    PackingValue? Function(String name)? structPackingOverrideFunc,
    String? Function(String interfaceName)? interfaceModuleFunc,
    String? Function(String protocolName)? protocolModuleFunc,
    String wrapperName = 'NativeLibrary',
    String? wrapperDocComment,
    String? preamble,
    bool useDartHandle = true,
    bool silenceEnumWarning = false,
    bool Function(String name)? shouldExposeFunctionTypedefFunc,
    bool Function(String name)? isLeafFunctionFunc,
    bool Function(String name)? enumShouldBeIntFunc,
    bool Function(String name)? unnamedEnumsShouldBeIntFunc,
    FfiNativeConfig ffiNativeConfig = const FfiNativeConfig(enabled: false),
    bool ignoreSourceErrors = false,
    bool formatOutput = true,
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
        functionDecl: functionDecl ?? Declaration.excludeAll,
        structDecl: structDecl ?? Declaration.excludeAll,
        unionDecl: unionDecl ?? Declaration.excludeAll,
        enumClassDecl: enumClassDecl ?? Declaration.excludeAll,
        unnamedEnumConstants: unnamedEnumConstants ?? Declaration.excludeAll,
        globals: globals ?? Declaration.excludeAll,
        macroDecl: macroDecl ?? Declaration.excludeAll,
        typedefs: typedefs ?? Declaration.excludeAll,
        objcInterfaces: objcInterfaces ?? Declaration.excludeAll,
        objcProtocols: objcProtocols ?? Declaration.excludeAll,
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
      );
}

abstract interface class Declaration {
  /// Applies renaming and returns the result.
  String rename(String name);

  /// Applies member renaming and returns the result.
  String renameMember(String declaration, String member);

  /// Checks if a name is allowed by a filter.
  bool shouldInclude(String name);

  /// Checks if the symbol address should be included for this name.
  bool shouldIncludeSymbolAddress(String name);

  factory Declaration({
    String Function(String name)? rename,
    String Function(String declaration, String member)? renameMember,
    bool Function(String name)? shouldInclude,
    bool Function(String name)? shouldIncludeSymbolAddress,
  }) =>
      DeclarationImpl(
        renameFunc: rename ?? (name) => name,
        renameMemberFunc: renameMember ?? (_, member) => member,
        shouldIncludeFunc: shouldInclude ?? (_) => false,
        shouldIncludeSymbolAddressFunc:
            shouldIncludeSymbolAddress ?? (_) => false,
      );

  static final excludeAll = Declaration();
  static final includeAll = Declaration(shouldInclude: (_) => true);
}
