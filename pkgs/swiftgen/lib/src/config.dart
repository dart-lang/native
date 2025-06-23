// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/swift2objc.dart' as swift2objc;
import 'package:ffigen/ffigen.dart' as ffigen;

import 'util.dart';

class Target {
  String triple;
  Uri sdk;

  Target({required this.triple, required this.sdk});

  static Future<Target> host() => getHostTarget();
}

abstract interface class ConfigInput {
  String get module;
  swift2objc.InputConfig asSwift2ObjCConfig(Target target);
  Iterable<Uri> get files;
  Iterable<String> get compileArgs;
}

class SwiftFileInput implements ConfigInput {
  @override
  final String module;

  @override
  final List<Uri> files;

  SwiftFileInput({
    required this.module,
    required this.files,
  });

  @override
  swift2objc.InputConfig asSwift2ObjCConfig(Target target) =>
      swift2objc.FilesInputConfig(
        files: files,
        generatedModuleName: module,
      );

  @override
  Iterable<String> get compileArgs => const <String>[];
}

class SwiftModuleInput implements ConfigInput {
  @override
  final String module;

  SwiftModuleInput({
    required this.module,
  });

  @override
  swift2objc.InputConfig asSwift2ObjCConfig(Target target) =>
      swift2objc.ModuleInputConfig(
        module: module,
        target: target.triple,
        sdk: target.sdk,
      );

  @override
  Iterable<Uri> get files => const <Uri>[];

  @override
  Iterable<String> get compileArgs => const <String>[];
}

class JsonFileInput implements ConfigInput {
  @override
  final String module;

  final Uri jsonFile;

  JsonFileInput({
    required this.module,
    required this.jsonFile,
  });

  @override
  swift2objc.InputConfig asSwift2ObjCConfig(Target target) =>
      swift2objc.JsonFileInputConfig(jsonFile: jsonFile);

  @override
  Iterable<Uri> get files => [];

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

class Config {
  final Target target;

  // Input. Either a swift file or a module.
  final ConfigInput input;

  // Intermediates.
  final String? objcSwiftPreamble;
  final Uri objcSwiftFile;
  final Uri tempDir;

  // Output file.
  final String? outputModule;
  final FfiGenConfig ffigen;

  Config({
    required this.target,
    required this.input,
    this.objcSwiftPreamble,
    required this.objcSwiftFile,
    required this.tempDir,
    this.outputModule,
    required this.ffigen,
  });
}
