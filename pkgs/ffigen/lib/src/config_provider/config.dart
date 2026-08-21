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

  /// C++ specific configuration.
  ///
  /// If `null`, C++ class bindings will not be generated.
  ///
  /// **EXPERIMENTAL**: C++ support is experimental. This part of the API
  /// may change or be removed in a future version without a deprecation notice.
  final Cpp? cpp;

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
  ///   func: (node) {
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
  ///   struct: (node) {
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
    this.cpp,
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

/// Configuration for how to generate enums.
enum EnumStyle {
  /// Generate a real Dart enum.
  dartEnum,

  /// Generate the given enum as a series of int constants.
  ///
  /// Useful when enum values are also used as bit masks.
  intConstants,
}

/// Configuration for C++.
final class Cpp {
  const Cpp();
}

/// Configuration for Objective-C.
final class ObjectiveC {
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
    this.externalVersions = const ExternalVersions(),
    @Deprecated('Only for internal use.')
    this.generateForPackageObjectiveC = false,
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
