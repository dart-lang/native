// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import 'config_types.dart';

/// Provides configurations to other modules.
final class FfiGen {
  /// Input config filename, if any.
  final Uri? filename;

  /// Path to the clang library.
  final Uri? libclangDylib;

  /// Output file name.
  final Uri output;

  /// Output ObjC file name.
  final Uri? outputObjC;

  Uri get _outputObjC => outputObjC ?? Uri.file('${output.toFilePath()}.m');

  /// Symbol file config.
  final SymbolFile? symbolFile;

  /// Language that ffigen is consuming.
  final Language language;

  /// Path to headers. May not contain globs.
  final List<Uri> entryPoints;

  /// Whether to include a specific header. This exists in addition to
  /// [entryPoints] to allow filtering of transitively included headers.
  final bool Function(Uri header)? shouldIncludeHeader;

  bool _shouldIncludeHeader(Uri header) =>
      shouldIncludeHeader?.call(header) ?? true;

  /// CommandLine Arguments to pass to clang_compiler.
  final List<String>? compilerOpts;

  /// VarArg function handling.
  final Map<String, List<VarArgFunction>> varArgFunctions;

  /// Declaration filters for Functions.
  final DeclarationFilters? functionDecl;

  DeclarationFilters get _functionDecl =>
      functionDecl ?? DeclarationFilters.excludeAll;

  /// Declaration filters for Structs.
  final DeclarationFilters? structDecl;

  DeclarationFilters get _structDecl =>
      structDecl ?? DeclarationFilters.excludeAll;

  /// Declaration filters for Unions.
  final DeclarationFilters? unionDecl;

  DeclarationFilters get _unionDecl =>
      unionDecl ?? DeclarationFilters.excludeAll;

  /// Declaration filters for Enums.
  final DeclarationFilters? enumClassDecl;

  DeclarationFilters get _enumClassDecl =>
      enumClassDecl ?? DeclarationFilters.excludeAll;

  /// Declaration filters for Unnamed enum constants.
  final DeclarationFilters? unnamedEnumConstants;

  DeclarationFilters get _unnamedEnumConstants =>
      unnamedEnumConstants ?? DeclarationFilters.excludeAll;

  /// Declaration filters for Globals.
  final DeclarationFilters? globals;

  DeclarationFilters get _globals => globals ?? DeclarationFilters.excludeAll;

  /// Declaration filters for Macro constants.
  final DeclarationFilters? macroDecl;

  DeclarationFilters get _macroDecl =>
      macroDecl ?? DeclarationFilters.excludeAll;

  /// Declaration filters for Typedefs.
  final DeclarationFilters? typedefs;

  DeclarationFilters get _typedefs => typedefs ?? DeclarationFilters.excludeAll;

  /// Declaration filters for Objective C interfaces.
  final DeclarationFilters? objcInterfaces;

  DeclarationFilters get _objcInterfaces =>
      objcInterfaces ?? DeclarationFilters.excludeAll;

  /// Declaration filters for Objective C protocols.
  final DeclarationFilters? objcProtocols;

  DeclarationFilters get _objcProtocols =>
      objcProtocols ?? DeclarationFilters.excludeAll;

  /// Declaration filters for Objective C categories.
  final DeclarationFilters? objcCategories;

  DeclarationFilters get _objcCategories =>
      objcCategories ?? DeclarationFilters.excludeAll;

  /// If enabled, unused typedefs will also be generated.
  final bool includeUnusedTypedefs;

  /// If enabled, Objective C interfaces that are not explicitly included by
  /// the [DeclarationFilters], but are transitively included by other bindings,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included interfaces will be generated as stubs instead.
  final bool includeTransitiveObjCInterfaces;

  /// If enabled, Objective C protocols that are not explicitly included by
  /// the [DeclarationFilters], but are transitively included by other bindings,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included protocols will not be generated at all.
  final bool includeTransitiveObjCProtocols;

  /// If enabled, Objective C categories that are not explicitly included by
  /// the [DeclarationFilters], but extend interfaces that are included,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included categories will not be generated at all.
  final bool includeTransitiveObjCCategories;

  /// Undocumented option that changes code generation for package:objective_c.
  /// The main difference is whether NSObject etc are imported from
  /// package:objective_c (the default) or code genned like any other class.
  /// This is necessary because package:objective_c can't import NSObject from
  /// itself.
  final bool generateForPackageObjectiveC;

  /// If generated bindings should be sorted alphabetically.
  final bool sort;

  /// If typedef of supported types(int8_t) should be directly used.
  final bool useSupportedTypedefs;

  /// Stores all the library imports specified by user including those for ffi
  /// and pkg_ffi.
  final List<LibraryImport> libraryImports;

  Map<String, LibraryImport> get _libraryImports =>
      Map<String, LibraryImport>.fromEntries(
        libraryImports.map(
          (import) => MapEntry<String, LibraryImport>(import.name, import),
        ),
      );

  /// Stores all the symbol file maps name to ImportedType mappings specified by
  /// user.
  final Map<String, ImportedType> usrTypeMappings;

  /// Stores typedef name to ImportedType mappings specified by user.
  final List<ImportedType> typedefTypeMappings;

  Map<String, ImportedType> get _typedefTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        typedefTypeMappings.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  /// Stores struct name to ImportedType mappings specified by user.
  final List<ImportedType> structTypeMappings;

  Map<String, ImportedType> get _structTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        structTypeMappings.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  /// Stores union name to ImportedType mappings specified by user.
  final List<ImportedType> unionTypeMappings;

  Map<String, ImportedType> get _unionTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        unionTypeMappings.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  /// Stores native int name to ImportedType mappings specified by user.
  final List<ImportedType> nativeTypeMappings;

  Map<String, ImportedType> get _nativeTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        nativeTypeMappings.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  /// Extracted Doc comment type.
  final CommentType commentType;

  /// Whether structs that are dependencies should be included.
  final CompoundDependencies structDependencies;

  /// Whether unions that are dependencies should be included.
  final CompoundDependencies unionDependencies;

  /// Whether, and how, to override struct packing for the given struct.
  final PackingValue? Function(Declaration declaration)? structPackingOverride;

  PackingValue? _structPackingOverride(Declaration declaration) =>
      structPackingOverride?.call(declaration);

  /// The module that the ObjC interface belongs to.
  final String? Function(Declaration declaration)? interfaceModule;

  String? _interfaceModule(Declaration declaration) =>
      interfaceModule?.call(declaration);

  /// The module that the ObjC protocol belongs to.
  final String? Function(Declaration declaration)? protocolModule;

  String? _protocolModule(Declaration declaration) =>
      protocolModule?.call(declaration);

  /// Name of the wrapper class.
  final String wrapperName;

  /// Doc comment for the wrapper class.
  final String? wrapperDocComment;

  /// Header of the generated bindings.
  final String? preamble;

  /// If `Dart_Handle` should be mapped with Handle/Object.
  final bool useDartHandle;

  /// Whether to silence warning for enum integer type mimicking.
  final bool silenceEnumWarning;

  /// Whether to expose the function typedef for a given function.
  final bool Function(Declaration declaration)? shouldExposeFunctionTypedef;

  bool _shouldExposeFunctionTypedef(Declaration declaration) =>
      shouldExposeFunctionTypedef?.call(declaration) ?? false;

  /// Whether the given function is a leaf function.
  final bool Function(Declaration declaration)? isLeafFunction;

  bool _isLeafFunction(Declaration declaration) =>
      isLeafFunction?.call(declaration) ?? false;

  /// Whether to generate the given enum as a series of int constants, rather
  /// than a real Dart enum.
  final bool Function(Declaration declaration)? enumShouldBeInt;

  bool _enumShouldBeInt(Declaration declaration) =>
      enumShouldBeInt?.call(declaration) ?? false;

  /// Whether to generate the given unnamed enum as a series of int constants,
  /// rather than a real Dart enum.
  final bool Function(Declaration declaration)? unnamedEnumsShouldBeInt;

  bool _unnamedEnumsShouldBeInt(Declaration declaration) =>
      unnamedEnumsShouldBeInt?.call(declaration) ?? false;

  /// Config options for @Native annotations.
  final FfiNativeConfig ffiNativeConfig;

  /// Where to ignore compiler warnings/errors in source header files.
  final bool ignoreSourceErrors;

  /// Whether to format the output file.
  final bool formatOutput;

  /// Minimum target versions for ObjC APIs, per OS. APIs that were deprecated
  /// before this version will not be generated.
  final ExternalVersions externalVersions;

  FfiGen({
    this.filename,
    required this.output,
    this.outputObjC,
    this.symbolFile,
    this.language = Language.c,
    this.entryPoints = const <Uri>[],
    this.shouldIncludeHeader,
    this.compilerOpts,
    this.varArgFunctions = const <String, List<VarArgFunction>>{},
    this.functionDecl,
    this.structDecl,
    this.unionDecl,
    this.enumClassDecl,
    this.unnamedEnumConstants,
    this.globals,
    this.macroDecl,
    this.typedefs,
    this.objcInterfaces,
    this.objcProtocols,
    this.objcCategories,
    this.includeUnusedTypedefs = false,
    this.includeTransitiveObjCInterfaces = false,
    this.includeTransitiveObjCProtocols = false,
    this.includeTransitiveObjCCategories = true,
    this.generateForPackageObjectiveC = false,
    this.sort = false,
    this.useSupportedTypedefs = true,
    this.libraryImports = const <LibraryImport>[],
    this.usrTypeMappings = const <String, ImportedType>{},
    this.typedefTypeMappings = const <ImportedType>[],
    this.structTypeMappings = const <ImportedType>[],
    this.unionTypeMappings = const <ImportedType>[],
    this.nativeTypeMappings = const <ImportedType>[],
    this.commentType = const CommentType.def(),
    this.structDependencies = CompoundDependencies.full,
    this.unionDependencies = CompoundDependencies.full,
    this.structPackingOverride,
    this.interfaceModule,
    this.protocolModule,
    this.wrapperName = 'NativeLibrary',
    this.wrapperDocComment,
    this.preamble,
    this.useDartHandle = true,
    this.silenceEnumWarning = false,
    this.shouldExposeFunctionTypedef,
    this.isLeafFunction,
    this.enumShouldBeInt,
    this.unnamedEnumsShouldBeInt,
    this.ffiNativeConfig = const FfiNativeConfig(enabled: false),
    this.ignoreSourceErrors = false,
    this.formatOutput = true,
    this.externalVersions = const ExternalVersions(),
    @Deprecated('Only visible for YamlConfig plumbing.') this.libclangDylib,
  });
}

extension type Config(FfiGen ffiGen) implements FfiGen {
  bool shouldIncludeHeader(Uri header) => ffiGen._shouldIncludeHeader(header);

  Map<String, LibraryImport> get libraryImports => ffiGen._libraryImports;

  Map<String, ImportedType> get typedefTypeMappings =>
      ffiGen._typedefTypeMappings;

  Map<String, ImportedType> get structTypeMappings =>
      ffiGen._structTypeMappings;

  Map<String, ImportedType> get unionTypeMappings => ffiGen._unionTypeMappings;

  Map<String, ImportedType> get nativeTypeMappings =>
      ffiGen._nativeTypeMappings;

  Uri get outputObjC => ffiGen._outputObjC;

  DeclarationFiltersConfig get functionDecl =>
      DeclarationFiltersConfig(ffiGen._functionDecl);
  DeclarationFiltersConfig get structDecl =>
      DeclarationFiltersConfig(ffiGen._structDecl);
  DeclarationFiltersConfig get unionDecl =>
      DeclarationFiltersConfig(ffiGen._unionDecl);
  DeclarationFiltersConfig get enumClassDecl =>
      DeclarationFiltersConfig(ffiGen._enumClassDecl);
  DeclarationFiltersConfig get unnamedEnumConstants =>
      DeclarationFiltersConfig(ffiGen._unnamedEnumConstants);
  DeclarationFiltersConfig get globals =>
      DeclarationFiltersConfig(ffiGen._globals);
  DeclarationFiltersConfig get macroDecl =>
      DeclarationFiltersConfig(ffiGen._macroDecl);
  DeclarationFiltersConfig get typedefs =>
      DeclarationFiltersConfig(ffiGen._typedefs);
  DeclarationFiltersConfig get objcInterfaces =>
      DeclarationFiltersConfig(ffiGen._objcInterfaces);
  DeclarationFiltersConfig get objcProtocols =>
      DeclarationFiltersConfig(ffiGen._objcProtocols);
  DeclarationFiltersConfig get objcCategories =>
      DeclarationFiltersConfig(ffiGen._objcCategories);

  PackingValue? structPackingOverride(Declaration declaration) =>
      ffiGen._structPackingOverride(declaration);

  String? interfaceModule(Declaration declaration) =>
      ffiGen._interfaceModule(declaration);

  String? protocolModule(Declaration declaration) =>
      ffiGen._protocolModule(declaration);

  bool shouldExposeFunctionTypedef(Declaration declaration) =>
      ffiGen._shouldExposeFunctionTypedef(declaration);

  bool isLeafFunction(Declaration declaration) =>
      ffiGen._isLeafFunction(declaration);

  bool enumShouldBeInt(Declaration declaration) =>
      ffiGen._enumShouldBeInt(declaration);

  bool unnamedEnumsShouldBeInt(Declaration declaration) =>
      ffiGen._unnamedEnumsShouldBeInt(declaration);
}

final class DeclarationFilters {
  /// Checks if a name is allowed by a filter.
  final bool Function(Declaration declaration)? shouldInclude;

  bool _shouldInclude(Declaration declaration) =>
      shouldInclude?.call(declaration) ?? false;

  /// Checks if the symbol address should be included for this name.
  final bool Function(Declaration declaration)? shouldIncludeSymbolAddress;

  bool _shouldIncludeSymbolAddress(Declaration declaration) =>
      shouldIncludeSymbolAddress?.call(declaration) ?? false;

  /// Applies renaming and returns the result.
  final String Function(Declaration declaration)? rename;

  String _rename(Declaration declaration) =>
      rename?.call(declaration) ?? declaration.originalName;

  /// Applies member renaming and returns the result. Used for struct/union
  /// fields, enum elements, function params, and ObjC
  /// interface/protocol/category methods/properties.
  final String Function(Declaration declaration, String member)? renameMember;

  String _renameMember(Declaration declaration, String member) =>
      renameMember?.call(declaration, member) ?? member;

  /// Whether a member of a declaration should be included. Used for ObjC
  /// interface/protocol/category methods/properties.
  final bool Function(Declaration declaration, String member)?
  shouldIncludeMember;

  bool _shouldIncludeMember(Declaration declaration, String member) =>
      shouldIncludeMember?.call(declaration, member) ?? true;

  const DeclarationFilters({
    this.shouldInclude,
    this.shouldIncludeSymbolAddress,
    this.rename,
    this.renameMember,
    this.shouldIncludeMember,
  });

  static const excludeAll = DeclarationFilters();
  static final includeAll = DeclarationFilters(shouldInclude: (_) => true);

  static DeclarationFilters include(Set<String> names) => DeclarationFilters(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

extension type DeclarationFiltersConfig(DeclarationFilters filters)
    implements DeclarationFilters {
  bool shouldInclude(Declaration declaration) =>
      filters._shouldInclude(declaration);

  bool shouldIncludeSymbolAddress(Declaration declaration) =>
      filters._shouldIncludeSymbolAddress(declaration);

  String rename(Declaration declaration) => filters._rename(declaration);

  String renameMember(Declaration declaration, String member) =>
      filters._renameMember(declaration, member);

  bool shouldIncludeMember(Declaration declaration, String member) =>
      filters._shouldIncludeMember(declaration, member);
}
