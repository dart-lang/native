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

  /// The configuration for outputting bindings.
  final Output output;

  /// Path to the clang library.
  @Deprecated('Only visible for YamlConfig plumbing.')
  final Uri? libclangDylib;

  /// Configuration for functions.
  final Functions functions;

  /// Configuration for structs.
  final Structs structs;

  /// Configuration for unions.
  final Unions unions;

  /// Configuration for enums.
  final Enums enums;

  /// Configuration for unnamed enum constants.
  final UnnamedEnums unnamedEnums;

  /// Configuration for globals.
  final Declarations globals;

  /// Configuration for macro constants.
  final Declarations macros;

  /// Configuration for typedefs.
  final Typedefs typedefs;

  /// Objective-C specific configuration.
  ///
  /// If `null`, will only generate for C.
  final ObjectiveC? objectiveC;

  /// Stores all the library imports specified by user including those for ffi
  /// and pkg_ffi.
  final List<LibraryImport> libraryImports;

  /// Stores all the symbol file maps name to ImportedType mappings specified by
  /// user.
  final Map<String, ImportedType> usrTypeMappings;

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

  const FfiGenerator({
    this.headers = const Headers(),
    required this.output,
    this.functions = Functions.excludeAll,
    this.structs = Structs.excludeAll,
    this.unions = Unions.excludeAll,
    this.enums = Enums.excludeAll,
    this.unnamedEnums = UnnamedEnums.excludeAll,
    this.globals = Globals.excludeAll,
    this.macros = Macros.excludeAll,
    this.typedefs = Typedefs.excludeAll,
    this.objectiveC,
    this.libraryImports = const <LibraryImport>[],
    this.usrTypeMappings = const <String, ImportedType>{},
    this.nativeTypeMappings = const <ImportedType>[],
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
  final BindingStyle bindingStyle;

  Output({
    required this.dartFile,
    this.objectiveCFile,
    this.symbolFile,
    this.sort = false,
    this.commentType = const CommentType.def(),
    this.preamble,
    this.format = true,
    this.bindingStyle = const NativeExternalBindings(),
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

/// Configuration for declarations.
final class Declarations {
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

  const Declarations({
    this.shouldInclude = _excludeAll,
    this.shouldIncludeSymbolAddress = _excludeAll,
    this.rename = _useOriginalName,
    this.renameMember = _useMemberOriginalName,
    this.shouldIncludeMember = _includeAllMembers,
  });

  static const excludeAll = Declarations();

  static const includeAll = Declarations(shouldInclude: _includeAll);

  static Declarations include(Set<String> names) => Declarations(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configuration for globals.
final class Globals extends Declarations {
  const Globals({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
  });

  static const excludeAll = Globals(shouldInclude: _excludeAll);

  static const includeAll = Globals(shouldInclude: _includeAll);

  static Globals include(Set<String> names) => Globals(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configures how Macros are handled.
final class Macros extends Declarations {
  const Macros({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
  });

  static const excludeAll = Macros(shouldInclude: _excludeAll);

  static const includeAll = Macros(shouldInclude: _includeAll);

  static Macros include(Set<String> names) => Macros(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configuration for Objective-C.
final class ObjectiveC {
  /// Declaration filters for Objective C interfaces.
  final ObjCInterfaces interfaces;

  /// Declaration filters for Objective C protocols.
  final ObjCProtocols protocols;

  /// Declaration filters for Objective C categories.
  final ObjCCategories categories;

  /// Undocumented option that changes code generation for package:objective_c.
  /// The main difference is whether NSObject etc are imported from
  /// package:objective_c (the default) or code genned like any other class.
  /// This is necessary because package:objective_c can't import NSObject from
  /// itself.
  @Deprecated('Only for internal use.')
  final bool generateForPackageObjectiveC;

  /// Minimum target versions for ObjC APIs, per OS. APIs that were deprecated
  /// before this version will not be generated.
  final ExternalVersions externalVersions;

  const ObjectiveC({
    this.interfaces = ObjCInterfaces.excludeAll,
    this.protocols = ObjCProtocols.excludeAll,
    this.categories = ObjCCategories.excludeAll,
    this.externalVersions = const ExternalVersions(),
    @Deprecated('Only for internal use.')
    this.generateForPackageObjectiveC = false,
  });
}

/// Configuration for function declarations.
final class Functions extends Declarations {
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

/// Configuration for enum declarations.
final class Enums extends Declarations {
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

/// Configuration for unnamed enum constants.
final class UnnamedEnums extends Declarations {
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

/// Configuration for struct declarations.
final class Structs extends Declarations {
  /// Whether structs that are dependencies should be included.
  final CompoundDependencies dependencies;

  /// Whether, and how, to override struct packing for the given struct.
  final PackingValue? Function(Declaration declaration) packingOverride;

  static PackingValue? _packingOverrideDefault(Declaration declaration) => null;

  /// Stores struct name to ImportedType mappings specified by user.
  final List<ImportedType> typeMappings;

  const Structs({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.dependencies = CompoundDependencies.full,
    this.packingOverride = _packingOverrideDefault,
    this.typeMappings = const <ImportedType>[],
  });

  static const excludeAll = Structs(shouldInclude: _excludeAll);

  static const includeAll = Structs(shouldInclude: _includeAll);

  static Structs include(Set<String> names) => Structs(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configuration for union declarations.
final class Unions extends Declarations {
  /// Whether unions that are dependencies should be included.
  final CompoundDependencies dependencies;

  /// Stores union name to ImportedType mappings specified by user.
  final List<ImportedType> typeMappings;

  const Unions({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.dependencies = CompoundDependencies.full,
    this.typeMappings = const <ImportedType>[],
  });

  static const excludeAll = Unions(shouldInclude: _excludeAll);

  static const includeAll = Unions(shouldInclude: _includeAll);

  static Unions include(Set<String> names) => Unions(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configuration for typedefs.
final class Typedefs extends Declarations {
  /// If typedef of supported types(int8_t) should be directly used.
  final bool useSupportedTypedefs;

  /// If enabled, unused typedefs will also be generated.
  final bool includeUnused;

  /// Stores typedef name to ImportedType mappings specified by user.
  final List<ImportedType> typeMappings;

  const Typedefs({
    super.rename,
    super.renameMember,
    super.shouldInclude,
    super.shouldIncludeMember,
    super.shouldIncludeSymbolAddress,
    this.useSupportedTypedefs = true,
    this.includeUnused = false,
    this.typeMappings = const <ImportedType>[],
  });

  static const Typedefs excludeAll = Typedefs(shouldInclude: _excludeAll);

  static const Typedefs includeAll = Typedefs(shouldInclude: _includeAll);

  static Typedefs include(Set<String> names) => Typedefs(
    shouldInclude: (Declaration decl) => names.contains(decl.originalName),
  );
}

/// Configuration for Objective-C interfaces.
final class ObjCInterfaces extends Declarations {
  /// If enabled, Objective C interfaces that are not explicitly included by
  /// the [Declarations], but are transitively included by other bindings,
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

/// Configuration for Objective-C protocols.
final class ObjCProtocols extends Declarations {
  /// If enabled, Objective C protocols that are not explicitly included by
  /// the [Declarations], but are transitively included by other bindings,
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

/// Configuration for Objective-C categories.
final class ObjCCategories extends Declarations {
  /// If enabled, Objective C categories that are not explicitly included by
  /// the [Declarations], but extend interfaces that are included,
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
  ObjCCategories get objcCategories => _objectiveC.categories;
  ObjCInterfaces get objcInterfaces => _objectiveC.interfaces;
  ObjCProtocols get objcProtocols => _objectiveC.protocols;
  ExternalVersions get externalVersions => _objectiveC.externalVersions;
  bool get useDartHandle => ffiGen.useDartHandle;
  Map<String, ImportedType> get usrTypeMappings => ffiGen.usrTypeMappings;
  String get wrapperName => switch (ffiGen.output.bindingStyle) {
    final DynamicLibraryBindings e => e.wrapperName,
    final NativeExternalBindings e => e.wrapperName,
  };

  String? get wrapperDocComment => switch (ffiGen.output.bindingStyle) {
    final DynamicLibraryBindings e => e.wrapperDocComment,
    _ => null,
  };

  FfiNativeConfig get ffiNativeConfig => FfiNativeConfig(
    enabled: ffiGen.output.bindingStyle is NativeExternalBindings,
    assetId: switch (ffiGen.output.bindingStyle) {
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
        ffiGen.typedefs.typeMappings.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  Map<String, ImportedType> get structTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        ffiGen.structs.typeMappings.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  // Override declarative user spec with what FFIgen internals expect.
  Map<String, ImportedType> get unionTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        ffiGen.unions.typeMappings.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  // Override declarative user spec with what FFIgen internals expect.
  Map<String, ImportedType> get nativeTypeMappings =>
      ffiGen._nativeTypeMappings;

  Language get language => objectiveC != null ? Language.objc : Language.c;
}
