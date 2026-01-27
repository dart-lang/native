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
  final Globals globals;

  /// Configuration for integer types.
  final Integers integers;

  /// Configuration for macro constants.
  final Macros macros;

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

  /// The configuration for outputting bindings.
  final Output output;

  /// Types imported from other Dart files, specified via the
  /// unique-resource-identifer used in Clang.
  ///
  /// Applies to all kinds of definitions.
  // TODO(https://github.com/dart-lang/native/issues/2596): Remove this.
  @Deprecated(
    'Will be folded into imported fields of the various declarations. See '
    'https://github.com/dart-lang/native/issues/2596.',
  )
  final Map<String, ImportedType> importedTypesByUsr;

  /// Stores all the library imports specified by user including those for ffi
  /// and pkg_ffi.
  // TODO(https://github.com/dart-lang/native/issues/2597): Remove this.
  @Deprecated(
    'In the future, this shoud be inferred from ImportedTypes. See '
    'https://github.com/dart-lang/native/issues/2597.',
  )
  final List<LibraryImport> libraryImports;

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
    this.integers = const Integers(),
    this.macros = Macros.excludeAll,
    this.structs = Structs.excludeAll,
    this.typedefs = Typedefs.excludeAll,
    this.unions = Unions.excludeAll,
    this.unnamedEnums = UnnamedEnums.excludeAll,
    this.objectiveC,
    required this.output,
    @Deprecated(
      'Will be folded into imported fields of the various declarations. See '
      'https://github.com/dart-lang/native/issues/2596.',
    )
    this.importedTypesByUsr = const <String, ImportedType>{},
    @Deprecated(
      'In the future, this shoud be inferred from ImportedTypes. See '
      'https://github.com/dart-lang/native/issues/2597.',
    )
    this.libraryImports = const <LibraryImport>[],
    @Deprecated('Only visible for YamlConfig plumbing.') this.libclangDylib,
  });

  /// Run this generator.
  ///
  /// If provided, uses [logger] to output logs. Otherwise, uses a default
  /// logger that streams [Level.WARNING] to stdout and higher levels to stderr.
  void generate({Logger? logger, Uri? libclangDylib}) {
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

  /// Command line arguments to pass to clang_compiler.
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
  /// Whether to include the given declaration.
  ///
  /// ```dart
  /// // This includes `Foo`, and nothing else:
  /// include: (Declaration decl) => decl.originalName == 'Foo'
  /// ```
  final bool Function(Declaration declaration) include;

  /// A function to pass to [include] that excludes all declarations.
  static bool excludeAll(Declaration declaration) => false;

  /// A function to pass to [include] that includes all declarations.
  static bool includeAll(Declaration declaration) => true;

  /// Returns a function to pass to [include] that includes all declarations
  /// whose `originalName`s are in [names].
  static bool Function(Declaration) includeSet(Set<String> names) =>
      (Declaration decl) => names.contains(decl.originalName);

  /// Whether the member of the declaration should be included.
  ///
  /// Only used for [Categories], [Interfaces], and [Protocols] methods and
  /// properties. For Objective-C methods, this is the method selector, eg
  /// `"arrayWithObjects:count:"`.
  ///
  /// Note that using [includeMember] to include a member of a class doesn't
  /// affect whether the class is included. You'll also need to set [include]
  /// for the class (this will be fixed in a future version of the API).
  ///
  /// ```dart
  /// // This includes `Foo.bar`, and no other methods of `Foo`:
  /// includeMember: (Declaration declaration, String member) =>
  /// ```
  // TODO(https://github.com/dart-lang/native/issues/2770): Merge with include.
  final bool Function(Declaration declaration, String member) includeMember;

  /// A function to pass to [includeMember] that includes all members of all
  /// declarations.
  static bool includeAllMembers(Declaration declaration, String member) => true;

  /// A function to pass to [includeMember] that includes specific members.
  ///
  /// The map key is the declaration's `originalName`, and the value is the set
  /// of member names to include. If the declaration is not in the map, all its
  /// members are included.
  static bool Function(Declaration, String) includeMemberSet(
    Map<String, Set<String>> members,
  ) =>
      (Declaration decl, String member) =>
          members[decl.originalName]?.contains(member) ?? true;

  /// Whether the symbol address should be exposed for this declaration.
  ///
  /// The address is exposed as an FFI pointer.
  final bool Function(Declaration declaration) includeSymbolAddress;

  /// Returns a new name for the declaration, to replace its `originalName`.
  ///
  /// ```dart
  /// // This renames `Foo` to `Bar`, and nothing else:
  /// rename: (Declaration decl) =>
  ///     decl.originalName == 'Foo' ? 'Bar' : decl.originalName
  /// ```
  final String Function(Declaration declaration) rename;

  /// A function to pass to [rename] that doesn't rename the declaration.
  static String useOriginalName(Declaration declaration) =>
      declaration.originalName;

  /// A function to pass to [rename] that applies a rename map.
  ///
  /// The key of the map is the declaration's `originalName`, and the value is
  /// the new name to use. If the declaration is not in the map, it is not
  /// renamed.
  static String Function(Declaration) renameWithMap(
    Map<String, String> renames,
  ) =>
      (Declaration declaration) =>
          renames[declaration.originalName] ?? declaration.originalName;

  /// Returns a new name for the member of the declaration, to replace its
  /// `originalName`.
  ///
  /// Used for struct/union fields, enum elements, function params, and
  /// Objective-C interface/protocol/category methods/properties.
  ///
  /// ```dart
  /// // This renames `Foo.bar` to `Foo.baz`, and nothing else:
  /// rename: (Declaration decl, String member) {
  ///   if (decl.originalName == 'Foo' && member == 'baz') {
  ///     return 'baz';
  ///   }
  ///   return member;
  /// }
  /// ```
  final String Function(Declaration declaration, String member) renameMember;

  /// A function to pass to [renameMember] that doesn't rename the member.
  static String useMemberOriginalName(Declaration declaration, String member) =>
      member;

  /// A function to pass to [renameMember] that applies a rename map.
  ///
  /// The key of the map is the declaration's `originalName`, and the value is
  /// a map from member name to renamed member name. If the declaration is not
  /// in the map, or the member isn't in the declaration's map, the member is
  /// not renamed.
  static String Function(Declaration, String) renameMemberWithMap(
    Map<String, Map<String, String>> renames,
  ) =>
      (Declaration declaration, String member) =>
          renames[declaration.originalName]?[member] ?? member;

  const Declarations({
    this.include = excludeAll,
    this.includeMember = includeAllMembers,
    this.includeSymbolAddress = excludeAll,
    this.rename = useOriginalName,
    this.renameMember = useMemberOriginalName,
  });
}

/// Configuration for enum declarations.
final class Enums extends Declarations {
  /// The [EnumStyle] to use for the given enum declaration.
  ///
  /// The `suggestedStyle` is a suggested [EnumStyle] based on the declaration
  /// of the enum, if any. For example, Objective-C enums declared using
  /// NS_OPTIONS are suggested to use [EnumStyle.intConstants].
  ///
  /// ```dart
  /// // This uses `intConstants` for `Foo`, and the default style otherwise:
  /// style: (Declaration decl, EnumStyle? suggestedStyle) {
  ///   if (decl.originalName == 'Foo') {
  ///     return EnumStyle.intConstants;
  ///   }
  ///   return suggestedStyle ?? EnumStyle.dartEnum;
  /// }
  /// ```
  final EnumStyle Function(Declaration declaration, EnumStyle? suggestedStyle)
  style;

  static EnumStyle _styleDefault(
    Declaration declaration,
    EnumStyle? suggestedStyle,
  ) => suggestedStyle ?? EnumStyle.dartEnum;

  /// Whether to silence warning for enum integer type mimicking.
  final bool silenceWarning;

  const Enums({
    super.include,
    super.rename,
    super.renameMember,
    this.style = _styleDefault,
    this.silenceWarning = false,
  });

  static const excludeAll = Enums(include: Declarations.excludeAll);

  static const includeAll = Enums(include: Declarations.includeAll);

  static Enums includeSet(Set<String> names) =>
      Enums(include: Declarations.includeSet(names));
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
  /// Whether to generate a typedef for a given function's native type.
  final bool Function(Declaration declaration) includeTypedef;

  static bool _includeTypedefDefault(Declaration declaration) => false;

  /// Whether the given function is a leaf function.
  ///
  /// This corresponds to the `isLeaf` parameter of FFI's `lookupFunction`.
  /// For more details, its documentation is here:
  /// https://api.dart.dev/dart-ffi/DynamicLibraryExtension/lookupFunction.html
  final bool Function(Declaration declaration) isLeaf;

  static bool _isLeafDefault(Declaration declaration) => false;

  /// Map from function's original name to [VarArgFunction]s.
  ///
  /// Dart doesn't support variadic functions. Instead, variadic functions are
  /// handled by generating multiple versions of the same function, with
  /// different signatures. Each [VarArgFunction] represents one of those
  /// signatures.
  final Map<String, List<VarArgFunction>> varArgs;

  const Functions({
    super.include,
    super.includeSymbolAddress,
    super.rename,
    super.renameMember,
    this.includeTypedef = _includeTypedefDefault,
    this.isLeaf = _isLeafDefault,
    this.varArgs = const <String, List<VarArgFunction>>{},
  });

  static const excludeAll = Functions(include: Declarations.excludeAll);

  static const includeAll = Functions(include: Declarations.includeAll);

  static Functions includeSet(Set<String> names) =>
      Functions(include: Declarations.includeSet(names));
}

/// Configuration for globals.
final class Globals extends Declarations {
  const Globals({super.rename, super.include, super.includeSymbolAddress});

  static const excludeAll = Globals(include: Declarations.excludeAll);

  static const includeAll = Globals(include: Declarations.includeAll);

  static Globals includeSet(Set<String> names) =>
      Globals(include: Declarations.includeSet(names));
}

/// Configuration for integer types.
final class Integers {
  /// Integer types imported from other Dart files.
  // TODO(https://github.com/dart-lang/native/issues/2595): Change type.
  @Deprecated(
    'This field will change type. See '
    'https://github.com/dart-lang/native/issues/2595.',
  )
  final List<ImportedType> imported;

  const Integers({
    @Deprecated(
      'This field will change type. See '
      'https://github.com/dart-lang/native/issues/2595.',
    )
    this.imported = const <ImportedType>[],
  });
}

/// Configuration for macros.
final class Macros extends Declarations {
  const Macros({super.rename, super.include});

  static const excludeAll = Macros(include: Declarations.excludeAll);

  static const includeAll = Macros(include: Declarations.includeAll);

  static Macros includeSet(Set<String> names) =>
      Macros(include: Declarations.includeSet(names));
}

/// Configuration for struct declarations.
final class Structs extends Declarations {
  /// Whether structs that are dependencies should be included.
  final CompoundDependencies dependencies;

  /// Structs imported from other Dart files.
  // TODO(https://github.com/dart-lang/native/issues/2595): Change type.
  @Deprecated(
    'This field will change type. See '
    'https://github.com/dart-lang/native/issues/2595.',
  )
  final List<ImportedType> imported;

  /// Whether, and how, to override struct packing for the given struct.
  final PackingValue? Function(Declaration declaration) packingOverride;

  static PackingValue? _packingOverrideDefault(Declaration declaration) => null;

  const Structs({
    super.include,
    super.rename,
    super.renameMember,
    this.dependencies = CompoundDependencies.opaque,
    @Deprecated(
      'This field will change type. See '
      'https://github.com/dart-lang/native/issues/2595.',
    )
    this.imported = const <ImportedType>[],
    this.packingOverride = _packingOverrideDefault,
  });

  static const excludeAll = Structs(include: Declarations.excludeAll);

  static const includeAll = Structs(include: Declarations.includeAll);

  static Structs includeSet(Set<String> names) =>
      Structs(include: Declarations.includeSet(names));
}

/// Configuration for typedefs.
final class Typedefs extends Declarations {
  /// Typedefs imported from other Dart files.
  @Deprecated(
    'This field will change type. See '
    'https://github.com/dart-lang/native/issues/2595.',
  )
  final List<ImportedType> imported;

  /// If enabled, unused typedefs will also be generated.
  final bool includeUnused;

  /// If typedef of supported types(int8_t) should be directly used.
  final bool useSupportedTypedefs;

  const Typedefs({
    super.rename,
    super.include,
    @Deprecated(
      'This field will change type. See '
      'https://github.com/dart-lang/native/issues/2595.',
    )
    this.imported = const <ImportedType>[],
    this.includeUnused = false,
    this.useSupportedTypedefs = true,
  });

  static const Typedefs excludeAll = Typedefs(include: Declarations.excludeAll);

  static const Typedefs includeAll = Typedefs(include: Declarations.includeAll);

  static Typedefs includeSet(Set<String> names) =>
      Typedefs(include: Declarations.includeSet(names));
}

/// Configuration for union declarations.
final class Unions extends Declarations {
  /// Whether unions that are dependencies should be included.
  final CompoundDependencies dependencies;

  /// Unions imported from other Dart files.
  @Deprecated(
    'This field will change type. See '
    'https://github.com/dart-lang/native/issues/2595.',
  )
  final List<ImportedType> imported;

  const Unions({
    super.include,
    super.rename,
    super.renameMember,
    this.dependencies = CompoundDependencies.opaque,
    @Deprecated(
      'This field will change type. See '
      'https://github.com/dart-lang/native/issues/2595.',
    )
    this.imported = const <ImportedType>[],
  });

  static const excludeAll = Unions(include: Declarations.excludeAll);

  static const includeAll = Unions(include: Declarations.includeAll);

  static Unions includeSet(Set<String> names) =>
      Unions(include: Declarations.includeSet(names));
}

/// Configuration for unnamed enum constants.
final class UnnamedEnums extends Declarations {
  const UnnamedEnums({super.include, super.rename, super.renameMember});

  static const excludeAll = UnnamedEnums(include: Declarations.excludeAll);

  static const includeAll = UnnamedEnums(include: Declarations.includeAll);

  static UnnamedEnums includeSet(Set<String> names) =>
      UnnamedEnums(include: Declarations.includeSet(names));
}

/// Configuration for Objective-C.
final class ObjectiveC {
  /// Declaration filters for Objective-C categories.
  final Categories categories;

  /// Declaration filters for Objective-C interfaces.
  final Interfaces interfaces;

  /// Declaration filters for Objective-C protocols.
  final Protocols protocols;

  // Undocumented option that changes code generation for package:objective_c.
  // The main difference is whether NSObject etc are imported from
  // package:objective_c (the default) or code genned like any other class.
  // This is necessary because package:objective_c can't import NSObject from
  // itself.
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
    super.rename,
    super.renameMember,
    this.includeTransitive = true,
  });

  static const excludeAll = Categories(include: Declarations.excludeAll);

  static const includeAll = Categories(include: Declarations.includeAll);

  static Categories includeSet(Set<String> names) =>
      Categories(include: Declarations.includeSet(names));
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

  const Interfaces({
    super.include,
    super.includeMember,
    super.rename,
    super.renameMember,
    this.includeTransitive = false,
    this.module = noModule,
  });

  static const excludeAll = Interfaces(include: Declarations.excludeAll);

  static const includeAll = Interfaces(include: Declarations.includeAll);

  static Interfaces includeSet(Set<String> names) =>
      Interfaces(include: Declarations.includeSet(names));

  static String? noModule(Declaration declaration) => null;
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

  const Protocols({
    super.include,
    super.includeMember,
    super.rename,
    super.renameMember,
    this.includeTransitive = false,
    this.module = noModule,
  });

  static const excludeAll = Protocols(include: Declarations.excludeAll);

  static const includeAll = Protocols(include: Declarations.includeAll);

  static Protocols includeSet(Set<String> names) =>
      Protocols(include: Declarations.includeSet(names));

  static String? noModule(Declaration declaration) => null;
}

/// Configuration for outputting bindings.
final class Output {
  /// The output Dart file for the generated bindings.
  final Uri dartFile;

  /// The output Objective-C file for the generated Objective-C bindings.
  final Uri? objectiveCFile;

  Uri get objCFile => objectiveCFile ?? Uri.file('${dartFile.toFilePath()}.m');

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
    this.sort = true,
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

  const NativeExternalBindings({this.assetId});
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
  // ignore: deprecated_member_use_from_same_package
  Map<String, ImportedType> get importedTypesByUsr => ffiGen.importedTypesByUsr;

  // Override declarative user spec with what FFIgen internals expect.
  Map<String, ImportedType> get typedefTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        // ignore: deprecated_member_use_from_same_package
        ffiGen.typedefs.imported.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  Map<String, ImportedType> get structTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        // ignore: deprecated_member_use_from_same_package
        ffiGen.structs.imported.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  // Override declarative user spec with what FFIgen internals expect.
  Map<String, ImportedType> get unionTypeMappings =>
      Map<String, ImportedType>.fromEntries(
        // ignore: deprecated_member_use_from_same_package
        ffiGen.unions.imported.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );

  // Override declarative user spec with what FFIgen internals expect.
  Map<String, ImportedType> get importedIntegers =>
      Map<String, ImportedType>.fromEntries(
        // ignore: deprecated_member_use_from_same_package
        ffiGen.integers.imported.map(
          (import) => MapEntry<String, ImportedType>(import.nativeType, import),
        ),
      );
}
