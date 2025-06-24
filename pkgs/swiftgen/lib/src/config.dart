// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart' as ffigen;

import 'util.dart';

/// Config options for swiftgen.
class Config {
  final Target target;

  // Input files.
  final ConfigInput input;

  // Intermediates.
  final Uri tempDir;

  // Output file.
  final String? outputModule;
  final FfiGenConfig ffigen;

  Config({
    required this.target,
    required this.input,
    Uri? tempDirectory,
    this.outputModule,
    required this.ffigen,
  }) : tempDir = tempDirectory ?? createTempDirectory();
}

/// A target is a target triple string and an iOS/macOS SDK directory.
class Target {
  String triple;
  Uri sdk;

  Target({required this.triple, required this.sdk});

  static Future<Target> host() => getHostTarget();
}

/// Describes the inputs to the swiftgen pipeline.
abstract interface class ConfigInput {
  String get module;
  Iterable<Uri> get files;
  Iterable<String> get compileArgs;
}

/// Input swift files that are already annotated with @objc.
class ObjCCompatibleSwiftFileInput implements ConfigInput {
  @override
  final String module;

  @override
  final List<Uri> files;

  ObjCCompatibleSwiftFileInput({
    required this.module,
    required this.files,
  });

  @override
  Iterable<String> get compileArgs => const <String>[];
}

/// Selected options from the ffigen Config object.
class FfiGenConfig {
  /// Output file name.
  final Uri output;

  /// Output ObjC file name.
  final Uri outputObjC;

  /// Name of the wrapper class.
  final String? wrapperName;

  /// Doc comment for the wrapper class.
  final String? wrapperDocComment;

  /// Header of the generated bindings.
  final String? preamble;

  /// Declaration filters for Functions.
  final ffigen.DeclarationFilters? functionDecl;

  /// Declaration filters for Structs.
  final ffigen.DeclarationFilters? structDecl;

  /// Declaration filters for Unions.
  final ffigen.DeclarationFilters? unionDecl;

  /// Declaration filters for Enums.
  final ffigen.DeclarationFilters? enumClassDecl;

  /// Declaration filters for Unnamed enum constants.
  final ffigen.DeclarationFilters? unnamedEnumConstants;

  /// Declaration filters for Globals.
  final ffigen.DeclarationFilters? globals;

  /// Declaration filters for Macro constants.
  final ffigen.DeclarationFilters? macroDecl;

  /// Declaration filters for Typedefs.
  final ffigen.DeclarationFilters? typedefs;

  /// Declaration filters for Objective C interfaces.
  final ffigen.DeclarationFilters? objcInterfaces;

  /// Declaration filters for Objective C protocols.
  final ffigen.DeclarationFilters? objcProtocols;

  /// Minimum target versions for ObjC APIs, per OS. APIs that were deprecated
  /// before this version will not be generated.
  final ffigen.ExternalVersions externalVersions;

  FfiGenConfig({
    required this.output,
    required this.outputObjC,
    this.wrapperName,
    this.wrapperDocComment,
    this.preamble,
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
    this.externalVersions = const ffigen.ExternalVersions(),
  });
}
