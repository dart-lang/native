// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:package_config/package_config.dart';

import '../code_generator.dart';
import 'config_types.dart';

/// Provides configurations to other modules.
abstract interface class Config {
  /// Input filename.
  String? get filename;

  /// Package config.
  PackageConfig? get packageConfig;

  /// Location for llvm/lib folder.
  String get libclangDylib;

  /// Output file name.
  String get output;

  /// Output ObjC file name.
  String get outputObjC;

  /// Symbol file config.
  SymbolFile? get symbolFile;

  /// Language that ffigen is consuming.
  Language get language;

  /// Path to headers. May not contain globs.
  List<String> get entryPoints;

  /// Whether to include a specific header. This exists in addition to
  /// [entryPoints] to allow filtering of transitively included headers.
  bool shouldIncludeHeader(String header);

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
  int? structPackingOverride(String name);

  /// Apply module prefixes for ObjC interfaces.
  String applyInterfaceModulePrefix(String interfaceName);

  /// Apply module prefixes for ObjC protocols.
  String applyProtocolModulePrefix(String protocolName);

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
}
