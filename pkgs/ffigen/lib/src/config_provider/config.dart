// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:logging/logging.dart';

import '../code_generator.dart';
import '../ffigen.dart';
import 'config_types.dart';

/// The generator that generates bindings for `dart:ffi` from C and Objective-C
/// headers.
// TODO: Add a code snippet example.
final class FfiGenerator {
  final BindingStyle bindingStyle;

  /// The configuration for header parsing of [FfiGenerator].
  final Headers headers;

  /// The configuration for outputting bindings.
  final Output output;

  /// Input config filename, if any.
  final Uri? filename;

  /// Path to the clang library.
  final Uri? libclangDylib;

  /// Language that ffigen is consuming.
  final Language language;

  /// Declaration filters for Functions.
  final Functions functions;

  /// Declaration filters for Structs.
  final Structs structs;

  /// Declaration filters for Unions.
  final Unions unions;

  /// Declaration filters for Enums.
  final Enums enums;

  /// Declaration filters for Unnamed enum constants.
  final UnnamedEnums unnamedEnumConstants;

  /// Declaration filters for Globals.
  final DeclarationFilters globals;

  /// Declaration filters for Macro constants.
  final DeclarationFilters macroDecl;

  /// Declaration filters for Typedefs.
  final Typedefs typedefs;

  /// Declaration filters for Objective C interfaces.
  final ObjCInterfaces objcInterfaces;

  /// Declaration filters for Objective C protocols.
  final ObjCProtocols objcProtocols;

  /// Declaration filters for Objective C categories.
  final ObjCCategories objcCategories;

  /// Undocumented option that changes code generation for package:objective_c.
  /// The main difference is whether NSObject etc are imported from
  /// package:objective_c (the default) or code genned like any other class.
  /// This is necessary because package:objective_c can't import NSObject from
  /// itself.
  final bool generateForPackageObjectiveC;

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

  /// If `Dart_Handle` should be mapped with Handle/Object.
  final bool useDartHandle;

  /// Minimum target versions for ObjC APIs, per OS. APIs that were deprecated
  /// before this version will not be generated.
  final ExternalVersions externalVersions;

  const FfiGenerator({
    this.bindingStyle = const NativeExternalBindings(),
    this.headers = const Headers(),
    required this.output,
    this.filename,
    this.language = Language.c,
    this.functions = Functions.excludeAll,
    this.structs = Structs.excludeAll,
    this.unions = Unions.excludeAll,
    this.enums = Enums.excludeAll,
    this.unnamedEnumConstants = UnnamedEnums.excludeAll,
    this.globals = DeclarationFilters.excludeAll,
    this.macroDecl = DeclarationFilters.excludeAll,
    this.typedefs = Typedefs.excludeAll,
    this.objcInterfaces = ObjCInterfaces.excludeAll,
    this.objcProtocols = ObjCProtocols.excludeAll,
    this.objcCategories = ObjCCategories.excludeAll,
    this.generateForPackageObjectiveC = false,
    this.libraryImports = const <LibraryImport>[],
    this.usrTypeMappings = const <String, ImportedType>{},
    this.typedefTypeMappings = const <ImportedType>[],
    this.structTypeMappings = const <ImportedType>[],
    this.unionTypeMappings = const <ImportedType>[],
    this.nativeTypeMappings = const <ImportedType>[],
    this.useDartHandle = true,
    this.externalVersions = const ExternalVersions(),
    @Deprecated('Only visible for YamlConfig plumbing.') this.libclangDylib,
  });

  /// Run this generator.
  void generate({required Logger? logger, Uri? libclangDylib}) {
    return FfiGenGenerator(
      this,
    ).generate(logger: logger, libclangDylib: libclangDylib);
  }
}

/// The configuration for header parsing of [FfiGenerator].
final class Headers {
  /// Path to headers. May not contain globs.
  final List<Uri> entryPoints;

  /// Whether to include a specific header. This exists in addition to
  /// [entryPoints] to allow filtering of transitively included headers.
  final bool Function(Uri header) shouldInclude;

  static bool _shouldIncludeDefault(Uri header) => true;

  /// CommandLine Arguments to pass to clang_compiler.
  final List<String>? compilerOpts;

  /// Where to ignore compiler warnings/errors in source header files.
  final bool ignoreSourceErrors;

  const Headers({
    this.entryPoints = const [],
    this.shouldInclude = _shouldIncludeDefault,
    this.compilerOpts,
    this.ignoreSourceErrors = false,
  });
}

final class Output {
  /// Output file name.
  final Uri dartFile;

  /// Output ObjC file name.
  final Uri? objectiveCFile;

  Uri get _objectiveCFile =>
      objectiveCFile ?? Uri.file('${dartFile.toFilePath()}.m');

  /// Symbol file config.
  final SymbolFile? symbolFile;

  /// If generated bindings should be sorted alphabetically.
  final bool sort;

  /// Extracted Doc comment type.
  final CommentType commentType;

  /// Header of the generated bindings.
  final String? preamble;

  /// Whether to format the output file.
  final bool format;

  Output({
    required this.dartFile,
    this.objectiveCFile,
    this.symbolFile,
    this.sort = false,
    this.commentType = const CommentType.def(),
    this.preamble,
    this.format = true,
  });
}

/// The style of `dart:ffi` bindings to generate.
///
/// Either static bindings ([NativeExternalBindings]) or dynamic bindings
///  ([DynamicLibraryBindings]).
sealed class BindingStyle {}

/// Generate bindings with [Native] external functions.
final class NativeExternalBindings implements BindingStyle {
  /// The asset id to use for the [Native] annotations.
  ///
  /// If omitted, it will not be generated.
  final String? assetId;

  /// Not the name of the wrapper class!
  // TODO(https://github.com/dart-lang/native/issues/2580): Can we get rid of
  // this?
  final String wrapperName;

  const NativeExternalBindings({
    this.assetId,
    this.wrapperName = 'NativeLibrary',
  });
}

/// Generate bindings which take a [DynamicLibrary] or [DynamicLibrary.lookup]
/// parameter.
///
/// Generates a wrapper class which takes takes a [DynamicLibrary] or lookup
/// function in its constructor.
///
/// To generate static bindings use [NativeExternalBindings].
final class DynamicLibraryBindings implements BindingStyle {
  /// Name of the wrapper class.
  final String wrapperName;

  /// Doc comment for the wrapper class.
  final String? wrapperDocComment;

  const DynamicLibraryBindings({
    this.wrapperName = 'NativeLibrary',
    this.wrapperDocComment,
  });
}

extension type Config(FfiGenerator ffiGen) implements FfiGenerator {
  bool get includeTransitiveObjCInterfaces =>
      ffiGen.objcInterfaces.includeTransitive;
  bool get includeTransitiveObjCProtocols =>
      ffiGen.objcProtocols.includeTransitive;
  bool get includeTransitiveObjCCategories =>
      ffiGen.objcCategories.includeTransitive;
  String? Function(Declaration declaration) get interfaceModule =>
      ffiGen.objcInterfaces.module;
  String? Function(Declaration declaration) get protocolModule =>
      ffiGen.objcProtocols.module;
  String get wrapperName => switch (bindingStyle) {
    final DynamicLibraryBindings e => e.wrapperName,
    final NativeExternalBindings e => e.wrapperName,
  };

  String? get wrapperDocComment => switch (bindingStyle) {
    final DynamicLibraryBindings e => e.wrapperDocComment,
    _ => null,
  };

  FfiNativeConfig get ffiNativeConfig => FfiNativeConfig(
    enabled: bindingStyle is NativeExternalBindings,
    assetId: switch (bindingStyle) {
      final NativeExternalBindings e => e.assetId,
      _ => null,
    },
  );

  bool shouldIncludeHeader(Uri header) => ffiGen.headers.shouldInclude(header);

  bool get ignoreSourceErrors => ffiGen.headers.ignoreSourceErrors;

  List<String>? get compilerOpts => ffiGen.headers.compilerOpts;

  List<Uri> get entryPoints => ffiGen.headers.entryPoints;

  Uri get output => ffiGen.output.dartFile;

  Uri get outputObjC => ffiGen.output._objectiveCFile;

  SymbolFile? get symbolFile => ffiGen.output.symbolFile;

  bool get sort => ffiGen.output.sort;

  CommentType get commentType => ffiGen.output.commentType;

  String? get preamble => ffiGen.output.preamble;

  bool get formatOutput => ffiGen.output.format;

  Map<String, LibraryImport> get libraryImports => ffiGen._libraryImports;

  Map<String, ImportedType> get typedefTypeMappings =>
      ffiGen._typedefTypeMappings;

  Map<String, ImportedType> get structTypeMappings =>
      ffiGen._structTypeMappings;

  Map<String, ImportedType> get unionTypeMappings => ffiGen._unionTypeMappings;

  Map<String, ImportedType> get nativeTypeMappings =>
      ffiGen._nativeTypeMappings;
}

final class DeclarationFilters {
  /// Checks if a name is allowed by a filter.
  final bool Function(Declaration declaration) shouldInclude;

  /// Checks if the symbol address should be included for this name.
  final bool Function(Declaration declaration) shouldIncludeSymbolAddress;

  /// Applies renaming and returns the result.
  final String Function(Declaration declaration) rename;

  static String _useOriginalName(Declaration declaration) =>
      declaration.originalName;

  /// Applies member renaming and returns the result. Used for struct/union
  /// fields, enum elements, function params, and ObjC
  /// interface/protocol/category methods/properties.
  final String Function(Declaration declaration, String member) renameMember;

  static String _useMemberOriginalName(
    Declaration declaration,
    String member,
  ) => member;

  /// Whether a member of a declaration should be included. Used for ObjC
  /// interface/protocol/category methods/properties.
  final bool Function(Declaration declaration, String member)
  shouldIncludeMember;

  static bool _includeAllMembers(Declaration declaration, String member) =>
      true;

  const DeclarationFilters({
    this.shouldInclude = _excludeAll,
    this.shouldIncludeSymbolAddress = _excludeAll,
    this.rename = _useOriginalName,
    this.renameMember = _useMemberOriginalName,
    this.shouldIncludeMember = _includeAllMembers,
  });

  static const excludeAll = DeclarationFilters();

  static const includeAll = DeclarationFilters(shouldInclude: _includeAll);

  static DeclarationFilters include(Set<String> names) => DeclarationFilters(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

final class Functions extends DeclarationFilters {
  /// VarArg function handling.
  final Map<String, List<VarArgFunction>> varArgs;

  /// Whether to expose the function typedef for a given function.
  final bool Function(Declaration declaration) exposeTypedef;

  static bool _exposeTypedefDefault(Declaration declaration) => false;

  /// Whether the given function is a leaf function.
  final bool Function(Declaration declaration) isLeaf;

  static bool _isLeafDefault(Declaration declaration) => false;

  const Functions({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.varArgs = const <String, List<VarArgFunction>>{},
    this.exposeTypedef = _exposeTypedefDefault,
    this.isLeaf = _isLeafDefault,
  });

  static const excludeAll = Functions(shouldInclude: _excludeAll);

  static const includeAll = Functions(shouldInclude: _includeAll);

  static Functions include(Set<String> names) => Functions(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

final class Enums extends DeclarationFilters {
  /// Whether to generate the given enum as a series of int constants, rather
  /// than a real Dart enum.
  final bool Function(Declaration declaration) shouldBeInt;

  static bool _shouldBeIntDefault(Declaration declaration) => false;

  /// Whether to silence warning for enum integer type mimicking.
  final bool silenceWarning;

  const Enums({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.shouldBeInt = _shouldBeIntDefault,
    this.silenceWarning = false,
  });

  static const excludeAll = Enums(shouldInclude: _excludeAll);

  static const includeAll = Enums(shouldInclude: _includeAll);

  static Enums include(Set<String> names) => Enums(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

final class UnnamedEnums extends DeclarationFilters {
  /// Whether to generate the given enum as a series of int constants, rather
  /// than a real Dart enum.
  final bool Function(Declaration declaration) shouldBeInt;

  static bool _shouldBeIntDefault(Declaration declaration) => false;

  const UnnamedEnums({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.shouldBeInt = _shouldBeIntDefault,
  });

  static const excludeAll = UnnamedEnums(shouldInclude: _excludeAll);

  static const includeAll = UnnamedEnums(shouldInclude: _includeAll);

  static UnnamedEnums include(Set<String> names) => UnnamedEnums(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

final class Structs extends DeclarationFilters {
  /// Whether structs that are dependencies should be included.
  final CompoundDependencies dependencies;

  /// Whether, and how, to override struct packing for the given struct.
  final PackingValue? Function(Declaration declaration) packingOverride;

  static PackingValue? _packingOverrideDefault(Declaration declaration) => null;

  const Structs({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.dependencies = CompoundDependencies.full,
    this.packingOverride = _packingOverrideDefault,
  });

  static const excludeAll = Structs(shouldInclude: _excludeAll);

  static const includeAll = Structs(shouldInclude: _includeAll);

  static Structs include(Set<String> names) => Structs(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

final class Unions extends DeclarationFilters {
  /// Whether unions that are dependencies should be included.
  final CompoundDependencies dependencies;

  const Unions({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.dependencies = CompoundDependencies.full,
  });

  static const excludeAll = Unions(shouldInclude: _excludeAll);

  static const includeAll = Unions(shouldInclude: _includeAll);

  static Unions include(Set<String> names) => Unions(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

final class Typedefs extends DeclarationFilters {
  /// If typedef of supported types(int8_t) should be directly used.
  final bool useSupportedTypedefs;

  /// If enabled, unused typedefs will also be generated.
  final bool includeUnused;

  const Typedefs({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.useSupportedTypedefs = true,
    this.includeUnused = false,
  });

  static const Typedefs excludeAll = Typedefs(shouldInclude: _excludeAll);

  static const Typedefs includeAll = Typedefs(shouldInclude: _includeAll);

  static Typedefs include(Set<String> names) => Typedefs(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

final class ObjCInterfaces extends DeclarationFilters {
  /// If enabled, Objective C interfaces that are not explicitly included by
  /// the [DeclarationFilters], but are transitively included by other bindings,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included interfaces will be generated as stubs instead.
  final bool includeTransitive;

  /// The module that the ObjC interface belongs to.
  final String? Function(Declaration declaration) module;

  static String? _moduleDefault(Declaration declaration) => null;

  const ObjCInterfaces({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.includeTransitive = false,
    this.module = _moduleDefault,
  });

  static const excludeAll = ObjCInterfaces(shouldInclude: _excludeAll);

  static const includeAll = ObjCInterfaces(shouldInclude: _includeAll);

  static ObjCInterfaces include(Set<String> names) => ObjCInterfaces(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

final class ObjCProtocols extends DeclarationFilters {
  /// If enabled, Objective C protocols that are not explicitly included by
  /// the [DeclarationFilters], but are transitively included by other bindings,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included protocols will not be generated at all.
  final bool includeTransitive;

  /// The module that the ObjC protocol belongs to.
  final String? Function(Declaration declaration) module;

  static String? _moduleDefault(Declaration declaration) => null;

  const ObjCProtocols({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.includeTransitive = false,
    this.module = _moduleDefault,
  });

  static const excludeAll = ObjCProtocols(shouldInclude: _excludeAll);

  static const includeAll = ObjCProtocols(shouldInclude: _includeAll);

  static ObjCProtocols include(Set<String> names) => ObjCProtocols(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

final class ObjCCategories extends DeclarationFilters {
  /// If enabled, Objective C categories that are not explicitly included by
  /// the [DeclarationFilters], but extend interfaces that are included,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included categories will not be generated at all.
  final bool includeTransitive;

  const ObjCCategories({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.includeTransitive = true,
  });

  static const excludeAll = ObjCCategories(shouldInclude: _excludeAll);

  static const includeAll = ObjCCategories(shouldInclude: _includeAll);

  static ObjCCategories include(Set<String> names) => ObjCCategories(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

bool _excludeAll(Declaration declaration) => false;

bool _includeAll(Declaration d) => true;
