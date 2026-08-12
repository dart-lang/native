// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../code_generator.dart';
import '../ffigen.dart';
import 'config_types.dart';
import 'public_ast.dart';

/// The generator that generates bindings for `dart:ffi` from C and Objective-C
/// headers.
// TODO: Add a code snippet example.
final class FfiGenerator {
  /// The configuration for header parsing of [FfiGenerator].
  final Input input;

  /// Configuration for enums.
  final Enums enums;

  /// Configuration for functions.
  final Functions functions;

  /// Configuration for globals.
  final Globals globals;

  /// Configuration for macro constants.
  final Macros macros;

  /// Configuration for structs.
  final Structs structs;

  /// C++ specific configuration.
  ///
  /// If `null`, C++ class bindings will not be generated.
  ///
  /// **EXPERIMENTAL**: C++ support is experimental. This part of the API
  /// may change or be removed in a future version without a deprecation notice.
  final Cpp? cpp;

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

  /// AST visitors to run on the generated bindings to perform transformations
  /// before Dart code generation occurs.
  ///
  /// Visitors are executed sequentially in the order they appear in this list.
  /// Each visitor can inspect or mutate AST node names and properties (such as
  /// renaming functions, parameters, struct fields, enum constants, etc.).
  ///
  /// ### Examples
  ///
  /// Filtering declarations:
  /// ```dart
  /// Visitor(
  ///   visitFunc: (node) {
  ///     if (node.name.startsWith('_')) {
  ///       node.isIncluded = false;
  ///     }
  ///   },
  /// )
  /// ```
  ///
  /// Renaming declarations:
  /// ```dart
  /// Visitor(
  ///   visitStruct: (node) {
  ///     if (node.name == 'custom_type') {
  ///       node.name = 'CustomType';
  ///     }
  ///   },
  /// )
  /// ```
  final List<Visitor> visitors;

  /// Returns an [ImportedType] if the given [Declaration] should be imported
  /// from another Dart library, or `null` otherwise.
  final ImportedType? Function(Declaration declaration) importType;

  static ImportedType? _defaultImportType(Declaration declaration) => null;

  /// Path to the clang library.
  ///
  /// Only visible for YamlConfig plumbing.
  @Deprecated('Only visible for YamlConfig plumbing.')
  final Uri? libclangDylib;

  const FfiGenerator({
    this.input = const Input(),
    this.enums = const Enums(),
    this.functions = const Functions(),
    this.globals = const Globals(),
    this.macros = const Macros(),
    this.structs = const Structs(),
    this.cpp,
    this.typedefs = const Typedefs(),
    this.unions = const Unions(),
    this.unnamedEnums = const UnnamedEnums(),
    this.objectiveC,
    required this.output,
    this.visitors = const [],
    this.importType = _defaultImportType,
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
final class Input {
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

  const Input({
    this.entryPoints = const [],
    this.include = _includeDefault,
    this.compilerOptions,
    this.ignoreSourceErrors = false,
  });
}

/// Configuration for declarations.
final class Declarations {
  /// Whether the symbol address should be exposed for this declaration.
  ///
  /// The address is exposed as an FFI pointer.
  final bool Function(Declaration declaration) includeSymbolAddress;

  const Declarations({
    this.includeSymbolAddress = _includeSymbolAddressDefault,
  });

  static bool _includeSymbolAddressDefault(Declaration declaration) => false;
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

  const Enums({this.style = _styleDefault, this.silenceWarning = false});
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

  /// Whether to add the `@RecordUse()` annotation to the given function.
  ///
  /// Experimental: The record uses feature needs to be enabled as experiment.
  @experimental
  final bool Function(Declaration declaration) recordUse;

  static bool _recordUseDefault(Declaration declaration) => false;

  /// Map from function's original name to [VarArgFunction]s.
  ///
  /// Dart doesn't support variadic functions. Instead, variadic functions are
  /// handled by generating multiple versions of the same function, with
  /// different signatures. Each [VarArgFunction] represents one of those
  /// signatures.
  final Map<String, List<VarArgFunction>> varArgs;

  const Functions({
    super.includeSymbolAddress,
    this.includeTypedef = _includeTypedefDefault,
    this.isLeaf = _isLeafDefault,
    this.recordUse = _recordUseDefault,
    this.varArgs = const <String, List<VarArgFunction>>{},
  });
}

/// Configuration for globals.
final class Globals extends Declarations {
  const Globals({super.includeSymbolAddress});
}

/// Configuration for macros.
final class Macros extends Declarations {
  const Macros();
}

/// Configuration for struct declarations.
final class Structs extends Declarations {
  /// Whether structs that are dependencies should be included.
  final CompoundDependencies dependencies;

  /// Whether, and how, to override struct packing for the given struct.
  final PackingValue? Function(Declaration declaration) packingOverride;

  static PackingValue? _packingOverrideDefault(Declaration declaration) => null;

  const Structs({
    this.dependencies = CompoundDependencies.opaque,
    this.packingOverride = _packingOverrideDefault,
  });
}

/// Configuration for typedefs.
final class Typedefs extends Declarations {
  /// If enabled, unused typedefs will also be generated.
  final bool includeUnused;

  /// If enabled, supported typedefs (such as size_t, uint8_t, etc.) will be
  /// mapped to their supported types.
  final bool useSupportedTypedefs;

  const Typedefs({
    this.useSupportedTypedefs = true,
    this.includeUnused = false,
  });
}

/// Configuration for C++ class declarations.
final class CppClasses extends Declarations {
  const CppClasses();
}

/// Configuration for C++.
final class Cpp {
  /// Declaration filters for C++ classes.
  final CppClasses classes;

  const Cpp({this.classes = const CppClasses()});
}

/// Configuration for union declarations.
final class Unions extends Declarations {
  /// Whether unions that are dependencies should be included.
  final CompoundDependencies dependencies;

  const Unions({this.dependencies = CompoundDependencies.opaque});
}

/// Configuration for unnamed enum constants.
final class UnnamedEnums extends Declarations {
  const UnnamedEnums();
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
    this.categories = const Categories(),
    this.interfaces = const Interfaces(),
    this.protocols = const Protocols(),
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

  const Categories({this.includeTransitive = true});
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

  const Interfaces({this.includeTransitive = false, this.module = noModule});

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

  const Protocols({this.includeTransitive = false, this.module = noModule});

  static String? noModule(Declaration declaration) => null;
}

/// Configuration for outputting bindings.
final class Output {
  /// The output Dart file for the generated bindings.
  final Uri dartFile;

  /// The output Objective-C file for the generated Objective-C bindings.
  final Uri? objectiveCFile;

  Uri get objCFile => objectiveCFile ?? Uri.file('${dartFile.toFilePath()}.m');

  /// The output Cpp glue file for the generated Cpp class bindings.
  final Uri? cppFile;

  Uri get cppBindingsFile =>
      cppFile ?? Uri.file('${dartFile.toFilePath()}.cpp');

  /// The config for the symbol file.
  final SymbolFile? symbolFile;

  /// The type of comments to generate.
  final CommentType commentType;

  /// The preamble to add to the generated bindings.
  final String? preamble;

  /// Whether to format the generated bindings.
  final bool format;

  /// The style of bindings to generate.
  final BindingStyle style;

  /// The output Dart file for the `@RecordUse()` name-to-symbol mapping.
  ///
  /// Experimental: The record uses feature needs to be enabled as experiment.
  @experimental
  final Uri? recordUseMapping;

  Output({
    required this.dartFile,
    this.objectiveCFile,
    this.cppFile,
    this.symbolFile,
    this.commentType = const CommentType.def(),
    this.preamble,
    this.format = true,
    this.style = const NativeExternalBindings(),
    this.recordUseMapping,
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
