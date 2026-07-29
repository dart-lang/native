// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../code_generator.dart';
import '../ffigen.dart';
import '../public_ast/public_ast.dart' show Visitor;
import 'config_types.dart';

/// The generator that generates bindings for `dart:ffi` from C and Objective-C
/// headers.
// TODO: Add a code snippet example.
final class FfiGenerator {
  /// User custom visitors to modify/filter AST elements.
  final List<Visitor> visitors;

  /// The configuration for header parsing of [FfiGenerator].
  final Headers headers;

  /// Configuration for functions.
  final Functions functions;

  /// Configuration for integer types.
  final Integers integers;

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
    this.visitors = const [],
    this.headers = const Headers(),
    this.functions = const Functions(),
    this.integers = const Integers(),
    this.structs = const Structs(),
    this.cpp,
    this.typedefs = const Typedefs(),
    this.unions = const Unions(),
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
final class Functions {
  /// Map from function's original name to [VarArgFunction]s.
  ///
  /// Dart doesn't support variadic functions. Instead, variadic functions are
  /// handled by generating multiple versions of the same function, with
  /// different signatures. Each [VarArgFunction] represents one of those
  /// signatures.
  final Map<String, List<VarArgFunction>> varArgs;

  const Functions({
    this.varArgs = const <String, List<VarArgFunction>>{},
  });
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

/// Configuration for struct declarations.
final class Structs {
  /// Whether structs that are dependencies should be included.
  final CompoundDependencies dependencies;

  /// Structs imported from other Dart files.
  // TODO(https://github.com/dart-lang/native/issues/2595): Change type.
  @Deprecated(
    'This field will change type. See '
    'https://github.com/dart-lang/native/issues/2595.',
  )
  final List<ImportedType> imported;

  const Structs({
    this.dependencies = CompoundDependencies.opaque,
    @Deprecated(
      'This field will change type. See '
      'https://github.com/dart-lang/native/issues/2595.',
    )
    this.imported = const <ImportedType>[],
  });
}

/// Configuration for typedefs.
final class Typedefs {
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
    @Deprecated(
      'This field will change type. See '
      'https://github.com/dart-lang/native/issues/2595.',
    )
    this.imported = const <ImportedType>[],
    this.includeUnused = false,
    this.useSupportedTypedefs = true,
  });
}

/// Configuration for C++.
final class Cpp {
  const Cpp();
}

/// Configuration for union declarations.
final class Unions {
  /// Whether unions that are dependencies should be included.
  final CompoundDependencies dependencies;

  /// Unions imported from other Dart files.
  @Deprecated(
    'This field will change type. See '
    'https://github.com/dart-lang/native/issues/2595.',
  )
  final List<ImportedType> imported;

  const Unions({
    this.dependencies = CompoundDependencies.opaque,
    @Deprecated(
      'This field will change type. See '
      'https://github.com/dart-lang/native/issues/2595.',
    )
    this.imported = const <ImportedType>[],
  });
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
final class Categories {
  /// If enabled, Objective-C categories that are not explicitly included by
  /// the [Declarations], but extend interfaces that are included,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included categories will not be generated at all.
  final bool includeTransitive;

  const Categories({
    this.includeTransitive = true,
  });
}

/// Configuration for Objective-C interfaces.
final class Interfaces {
  /// If enabled, Objective-C interfaces that are not explicitly included by
  /// the [Declarations], but are transitively included by other bindings,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included interfaces will be generated as stubs instead.
  final bool includeTransitive;

  const Interfaces({
    this.includeTransitive = false,
  });
}

/// Configuration for Objective-C protocols.
final class Protocols {
  /// If enabled, Objective-C protocols that are not explicitly included by
  /// the [Declarations], but are transitively included by other bindings,
  /// will be code-genned as if they were included. If disabled, these
  /// transitively included protocols will not be generated at all.
  final bool includeTransitive;

  const Protocols({
    this.includeTransitive = false,
  });
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
