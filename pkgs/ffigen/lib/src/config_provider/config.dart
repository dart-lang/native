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
  /// The configuration for header parsing of [FfiGenerator].
  final Headers headers;

  /// Configuration for enums.
  final Enums enums;

  /// Configuration for functions.
  final Functions functions;

  /// Configuration for globals.
  final Declarations globals;

  /// Configuration for macro constants.
  final Declarations macros;

  /// Configuration for structs.
  final Structs structs;

  /// Configuration for typedefs.
  final Typedefs typedefs;

  /// Configuration for unions.
  final Unions unions;

  /// Configuration for unnamed enum constants.
  final UnnamedEnums unnamedEnums;

  /// Objective-C specific configuration.
  ///
  /// If `null`, will only generate for C.
  final ObjectiveC? objectiveC;

  /// Integer types imported from other Dart files.
  // TODO: Should we move this under `integers: Integers(...)`?
  final List<ImportedType> importedIntegers;

  /// Types imported from other Dart files, specified via the
  /// unique-resource-identifer used in Clang.
  ///
  /// Applies to all kinds of definitions.
  // TODO: Can we add `usr` to `Definition` and serve the use case that way?
  final Map<String, ImportedType> importedTypesByUsr;

  /// Stores all the library imports specified by user including those for ffi
  /// and pkg_ffi.
  // TODO: Can we omit this and take it from all ImportedTypes?
  final List<LibraryImport> libraryImports;

  /// The configuration for outputting bindings.
  final Output output;

  /// If `Dart_Handle` should be mapped with Handle/Object.
  // TODO: Can we remove this?
  final bool useDartHandle;

  /// Path to the clang library.
  ///
  /// Only visible for YamlConfig plumbing.
  @Deprecated('Only visible for YamlConfig plumbing.')
  final Uri? libclangDylib;

  const FfiGenerator({
    this.headers = const Headers(),
    this.enums = Enums.excludeAll,
    this.functions = Functions.excludeAll,
    this.globals = Globals.excludeAll,
    this.macros = Macros.excludeAll,
    this.structs = Structs.excludeAll,
    this.typedefs = Typedefs.excludeAll,
    this.unions = Unions.excludeAll,
    this.unnamedEnums = UnnamedEnums.excludeAll,
    this.objectiveC,
    this.importedIntegers = const <ImportedType>[],
    this.importedTypesByUsr = const <String, ImportedType>{},
    this.libraryImports = const <LibraryImport>[],
    required this.output,
    this.useDartHandle = true,
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
  final bool Function(Uri header) include;

  static bool _includeDefault(Uri header) => true;

  /// CommandLine Arguments to pass to clang_compiler.
  final List<String>? compilerOptions;

  /// Where to ignore compiler warnings/errors in source header files.
  final bool ignoreSourceErrors;

  const Headers({
    this.entryPoints = const [],
    this.include = _includeDefault,
    this.compilerOptions,
    this.ignoreSourceErrors = false,
  });
}

/// Configuration for declarations.
final class Declarations {
  /// Checks if a name is allowed by a filter.
  final bool Function(Declaration declaration) include;

  /// Whether a member of a declaration should be included. Used for ObjC
  /// interface/protocol/category methods/properties.
  final bool Function(Declaration declaration, String member) includeMember;

  static bool _includeAllMembers(Declaration declaration, String member) =>
      true;

  /// Checks if the symbol address should be included for this name.
  final bool Function(Declaration declaration) includeSymbolAddress;

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

  const Declarations({
    this.include = _excludeAll,
    this.includeMember = _includeAllMembers,
    this.includeSymbolAddress = _excludeAll,
    this.rename = _useOriginalName,
    this.renameMember = _useMemberOriginalName,
  });
}

/// Configuration for enum declarations.
final class Enums extends Declarations {
  /// Whether to generate the given enum as a series of int constants, rather
  /// than a real Dart enum.
  final EnumStyle Function(Declaration declaration) style;

  static EnumStyle _styleDefault(Declaration declaration) => EnumStyle.dartEnum;

  /// Whether to silence warning for enum integer type mimicking.
  final bool silenceWarning;

  const Enums({
    super.include,
    super.includeMember,
    super.includeSymbolAddress,
    super.rename,
    super.renameMember,
    this.style = _styleDefault,
    this.silenceWarning = false,
  });

  static const excludeAll = Enums(include: _excludeAll);

  static const includeAll = Enums(include: _includeAll);

  static Enums includeSet(Set<String> names) =>
      Enums(include: (Declaration decl) => names.contains(decl.originalName));
}

/// Configuration for how to generate enums.
enum EnumStyle {
  /// Generate a real Dart enum.
  dartEnum,

  /// Generate the given enum as a series of int constants.
  ///
  /// Useful when enum values are also used as bit masks.
  intConstants,
}

/// Configuration for function declarations.
final class Functions extends Declarations {
  /// Whether to expose the function typedef for a given function.
  final bool Function(Declaration declaration) includeTypedef;

  static bool _includeTypedefDefault(Declaration declaration) => false;

  /// Whether the given function is a leaf function.
  final bool Function(Declaration declaration) isLeaf;

  static bool _isLeafDefault(Declaration declaration) => false;

  /// VarArg function handling.
  final Map<String, List<VarArgFunction>> varArgs;

  const Functions({
    super.include,
    super.includeMember,
    super.includeSymbolAddress,
    super.rename,
    super.renameMember,
    this.includeTypedef = _includeTypedefDefault,
    this.isLeaf = _isLeafDefault,
    this.varArgs = const <String, List<VarArgFunction>>{},
  });

  static const excludeAll = Functions(include: _excludeAll);

  static const includeAll = Functions(include: _includeAll);

  static Functions includeSet(Set<String> names) => Functions(
    include: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configuration for globals.
final class Globals extends Declarations {
  const Globals({super.rename, super.include, super.includeSymbolAddress});

  static const excludeAll = Globals(include: _excludeAll);

  static const includeAll = Globals(include: _includeAll);

  static Globals includeSet(Set<String> names) =>
      Globals(include: (Declaration decl) => names.contains(decl.originalName));
}

/// Configuration for macros.
final class Macros extends Declarations {
  const Macros({super.rename, super.include, super.includeSymbolAddress});

  static const excludeAll = Macros(include: _excludeAll);

  static const includeAll = Macros(include: _includeAll);

  static Macros includeSet(Set<String> names) =>
      Macros(include: (Declaration decl) => names.contains(decl.originalName));
}

/// Configuration for struct declarations.
final class Structs extends Declarations {
  /// Whether structs that are dependencies should be included.
  final CompoundDependencies dependencies;

  /// Structs imported from other Dart files.
  final List<ImportedType> imported;

  /// Whether, and how, to override struct packing for the given struct.
  final PackingValue? Function(Declaration declaration) packingOverride;

  static PackingValue? _packingOverrideDefault(Declaration declaration) => null;

  const Structs({
    super.include,
    super.includeMember,
    super.includeSymbolAddress,
    super.rename,
    super.renameMember,
    this.dependencies = CompoundDependencies.opaque,
    this.imported = const <ImportedType>[],
    this.packingOverride = _packingOverrideDefault,
  });

  static const excludeAll = Structs(include: _excludeAll);

  static const includeAll = Structs(include: _includeAll);

  static Structs includeSet(Set<String> names) =>
      Structs(include: (Declaration decl) => names.contains(decl.originalName));
}

/// Configuration for typedefs.
final class Typedefs extends Declarations {
  /// Typedefs imported from other Dart files.
  final List<ImportedType> imported;

  /// If enabled, unused typedefs will also be generated.
  final bool includeUnused;

  /// If typedef of supported types(int8_t) should be directly used.
  final bool useSupportedTypedefs;

  const Typedefs({
    super.rename,
    super.include,
    this.imported = const <ImportedType>[],
    this.includeUnused = false,
    this.useSupportedTypedefs = true,
  });

  static const Typedefs excludeAll = Typedefs(include: _excludeAll);

  static const Typedefs includeAll = Typedefs(include: _includeAll);

  static Typedefs includeSet(Set<String> names) => Typedefs(
    include: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configuration for union declarations.
final class Unions extends Declarations {
  /// Whether unions that are dependencies should be included.
  final CompoundDependencies dependencies;

  /// Unions imported from other Dart files.
  final List<ImportedType> imported;

  const Unions({
    super.include,
    super.includeMember,
    super.includeSymbolAddress,
    super.rename,
    super.renameMember,
    this.dependencies = CompoundDependencies.opaque,
    this.imported = const <ImportedType>[],
  });

  static const excludeAll = Unions(include: _excludeAll);

  static const includeAll = Unions(include: _includeAll);

  static Unions includeSet(Set<String> names) =>
      Unions(include: (Declaration decl) => names.contains(decl.originalName));
}

/// Configuration for unnamed enum constants.
final class UnnamedEnums extends Declarations {
  /// Whether to generate the given enum as a series of int constants, rather
  /// than a real Dart enum.
  final EnumStyle Function(Declaration declaration) style;

  static EnumStyle _styleDefault(Declaration declaration) => EnumStyle.dartEnum;

  const UnnamedEnums({
    super.include,
    super.includeMember,
    super.includeSymbolAddress,
    super.rename,
    super.renameMember,
    this.style = _styleDefault,
  });

  static const excludeAll = UnnamedEnums(include: _excludeAll);

  static const includeAll = UnnamedEnums(include: _includeAll);

  static UnnamedEnums includeSet(Set<String> names) => UnnamedEnums(
    include: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configuration for Objective-C.
final class ObjectiveC {
  /// Declaration filters for Objective-C categories.
  final Categories categories;

  /// Declaration filters for Objective-C interfaces.
  final Interfaces interfaces;

  /// Declaration filters for Objective-C protocols.
  final Protocols protocols;

  /// Undocumented option that changes code generation for package:objective_c.
  /// The main difference is whether NSObject etc are imported from
  /// package:objective_c (the default) or code genned like any other class.
  /// This is necessary because package:objective_c can't import NSObject from
  /// itself.
  @Deprecated('Only for internal use.')
  final bool generateForPackageObjectiveC;

  /// Minimum target versions for Objective-C APIs, per OS. APIs that were
  /// deprecated before this version will not be generated.
  final ExternalVersions externalVersions;

  const ObjectiveC({
    this.categories = Categories.excludeAll,
    this.interfaces = Interfaces.excludeAll,
    this.protocols = Protocols.excludeAll,
    this.externalVersions = const ExternalVersions(),
    @Deprecated('Only for internal use.')
    this.generateForPackageObjectiveC = false,
  });
}

/// Configuration for Objective-C categories.
final class Categories extends Declarations {
  /// If enabled, Objective-C categories that are not explicitly included by
  /// the [Declarations], but extend interfaces that are included,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included categories will not be generated at all.
  final bool includeTransitive;

  const Categories({
    super.include,
    super.includeMember,
    super.includeSymbolAddress,
    super.rename,
    super.renameMember,
    this.includeTransitive = true,
  });

  static const excludeAll = Categories(include: _excludeAll);

  static const includeAll = Categories(include: _includeAll);

  static Categories includeSet(Set<String> names) => Categories(
    include: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configuration for Objective-C interfaces.
final class Interfaces extends Declarations {
  /// If enabled, Objective-C interfaces that are not explicitly included by
  /// the [Declarations], but are transitively included by other bindings,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included interfaces will be generated as stubs instead.
  final bool includeTransitive;

  /// The module that the Objective-C interface belongs to.
  final String? Function(Declaration declaration) module;

  static String? _moduleDefault(Declaration declaration) => null;

  const Interfaces({
    super.include,
    super.includeMember,
    super.includeSymbolAddress,
    super.rename,
    super.renameMember,
    this.includeTransitive = false,
    this.module = _moduleDefault,
  });

  static const excludeAll = Interfaces(include: _excludeAll);

  static const includeAll = Interfaces(include: _includeAll);

  static Interfaces includeSet(Set<String> names) => Interfaces(
    include: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configuration for Objective-C protocols.
final class Protocols extends Declarations {
  /// If enabled, Objective-C protocols that are not explicitly included by
  /// the [Declarations], but are transitively included by other bindings,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included protocols will not be generated at all.
  final bool includeTransitive;

  /// The module that the Objective-C protocol belongs to.
  final String? Function(Declaration declaration) module;

  static String? _moduleDefault(Declaration declaration) => null;

  const Protocols({
    super.include,
    super.includeMember,
    super.includeSymbolAddress,
    super.rename,
    super.renameMember,
    this.includeTransitive = false,
    this.module = _moduleDefault,
  });

  static const excludeAll = Protocols(include: _excludeAll);

  static const includeAll = Protocols(include: _includeAll);

  static Protocols includeSet(Set<String> names) => Protocols(
    include: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configuration for outputting bindings.
final class Output {
  /// The output Dart file for the generated bindings.
  final Uri dartFile;

  /// The output Objective-C file for the generated Objective-C bindings.
  final Uri? objectiveCFile;

  Uri get _objectiveCFile =>
      objectiveCFile ?? Uri.file('${dartFile.toFilePath()}.m');

  /// The config for the symbol file.
  final SymbolFile? symbolFile;

  /// Whether to sort the generated bindings alphabetically.
  final bool sort;

  /// The type of comments to generate.
  final CommentType commentType;

  /// The preamble to add to the generated bindings.
  final String? preamble;

  /// Whether to format the generated bindings.
  final bool format;

  /// The style of bindings to generate.
  final BindingStyle style;

  Output({
    required this.dartFile,
    this.objectiveCFile,
    this.symbolFile,
    this.sort = false,
    this.commentType = const CommentType.def(),
    this.preamble,
    this.format = true,
    this.style = const NativeExternalBindings(),
  });
}

/// The style of `dart:ffi` bindings to generate.
///
/// Either static bindings ([NativeExternalBindings]) or dynamic bindings
/// ([DynamicLibraryBindings]).
sealed class BindingStyle {}

/// Generate bindings with [Native] external functions.
final class NativeExternalBindings implements BindingStyle {
  /// The asset id to use for the [Native] annotations.
  ///
  /// If omitted, it will not be generated.
  final String? assetId;

  /// The prefix for the generated Objective-C functions.
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
  ObjectiveC get _objectiveC => ffiGen.objectiveC ?? const ObjectiveC();
  bool get includeTransitiveObjCInterfaces =>
      _objectiveC.interfaces.includeTransitive;
  bool get includeTransitiveObjCProtocols =>
      _objectiveC.protocols.includeTransitive;
  bool get includeTransitiveObjCCategories =>
      _objectiveC.categories.includeTransitive;
  String? Function(Declaration declaration) get interfaceModule =>
      (declaration) => _objectiveC.interfaces.module(declaration);
  String? Function(Declaration declaration) get protocolModule =>
      (declaration) => _objectiveC.protocols.module(declaration);
  bool get generateForPackageObjectiveC =>
      // ignore: deprecated_member_use_from_same_package
      _objectiveC.generateForPackageObjectiveC;
  Categories get objcCategories => _objectiveC.categories;
  Interfaces get objcInterfaces => _objectiveC.interfaces;
  Protocols get objcProtocols => _objectiveC.protocols;
  ExternalVersions get externalVersions => _objectiveC.externalVersions;
  bool get useDartHandle => ffiGen.useDartHandle;
  Map<String, ImportedType> get importedTypesByUsr => ffiGen.importedTypesByUsr;
  String get wrapperName => switch (ffiGen.output.style) {
    final DynamicLibraryBindings e => e.wrapperName,
    final NativeExternalBindings e => e.wrapperName,
  };

  String? get wrapperDocComment => switch (ffiGen.output.style) {
    final DynamicLibraryBindings e => e.wrapperDocComment,
    _ => null,
  };

  FfiNativeConfig get ffiNativeConfig => FfiNativeConfig(
    enabled: ffiGen.output.style is NativeExternalBindings,
    assetId: switch (ffiGen.output.style) {
      final NativeExternalBindings e => e.assetId,
      _ => null,
    },
  );

  bool shouldIncludeHeader(Uri header) => ffiGen.headers.include(header);

  bool get ignoreSourceErrors => ffiGen.headers.ignoreSourceErrors;

  List<String>? get compilerOpts => ffiGen.headers.compilerOptions;

  List<Uri> get entryPoints => ffiGen.headers.entryPoints;

  Uri get output => ffiGen.output.dartFile;

  Uri get outputObjC => ffiGen.output._objectiveCFile;

  SymbolFile? get symbolFile => ffiGen.output.symbolFile;

  bool get sort => ffiGen.output.sort;

  CommentType get commentType => ffiGen.output.commentType;

  String? get preamble => ffiGen.output.preamble;

  bool get formatOutput => ffiGen.output.format;

  // Override declarative user spec with what FFIgen internals expect.
  Map<String, LibraryImport> get libraryImports =>
      Map<String, LibraryImport>.fromEntries(
        ffiGen.libraryImports.map(
          (import) => MapEntry<String, LibraryImport>(import.name, import),
        ),
      );

  // Override declarative user spec with what FFIgen internals expect.
  Map<String, ImportedType> get typedefTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        ffiGen.typedefs.imported.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  Map<String, ImportedType> get structTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        ffiGen.structs.imported.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  // Override declarative user spec with what FFIgen internals expect.
  Map<String, ImportedType> get unionTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        ffiGen.unions.imported.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  // Override declarative user spec with what FFIgen internals expect.
  Map<String, ImportedType> get importedIntegers =>
      Map<String, ImportedType>.fromEntries(
        ffiGen.importedIntegers.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  Language get language => objectiveC != null ? Language.objc : Language.c;
}

bool _excludeAll(Declaration declaration) => false;

bool _includeAll(Declaration d) => true;
