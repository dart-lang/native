// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart' as ffigen;
import 'package:swift2objc/swift2objc.dart' as swift2objc;

import 'util.dart';

/// Config options for swiftgen.
class SwiftGenerator {
  final Target target;
  final List<SwiftGenInput> inputs;
  final bool Function(swift2objc.Declaration declaration)? include;

  // TODO: Move these two to SwiftGenInput, and maybe rename that class.
  final String? objcSwiftPreamble;
  final Uri objcSwiftFile;

  final Uri tempDir;
  final String outputModule;
  final FfiGenConfig ffigen;

  SwiftGenerator({
    required this.target,
    required this.inputs,
    this.include,
    this.objcSwiftPreamble,
    required this.objcSwiftFile,
    Uri? tempDirectory,
    required this.outputModule,
    required this.ffigen,
  }) : tempDir = tempDirectory ?? createTempDirectory();
}

/// A target is a target triple string and an iOS/macOS SDK directory.
class Target {
  String triple;
  Uri sdk;

  Target({required this.triple, required this.sdk});

  static Future<Target> host() async => Target(
    triple: await swift2objc.hostTarget,
    sdk: await swift2objc.hostSdk,
  );
}

/// Describes the inputs to the swiftgen pipeline.
abstract interface class SwiftGenInput {
  swift2objc.InputConfig? get swift2ObjCConfig;
  Iterable<Uri> get files;
}

/// Input swift files that are already annotated with @objc.
class ObjCCompatibleSwiftFileInput implements SwiftGenInput {
  @override
  final List<Uri> files;

  @override
  swift2objc.InputConfig? get swift2ObjCConfig => null;

  ObjCCompatibleSwiftFileInput({required this.files});
}

class SwiftFileInput implements SwiftGenInput {
  final String module;

  @override
  final List<Uri> files;

  SwiftFileInput({required this.module, required this.files});

  @override
  swift2objc.InputConfig? get swift2ObjCConfig =>
      swift2objc.FilesInputConfig(files: files, generatedModuleName: module);
}

class SwiftModuleInput implements SwiftGenInput {
  final String module;

  SwiftModuleInput({required this.module});

  @override
  swift2objc.InputConfig? get swift2ObjCConfig =>
      swift2objc.ModuleInputConfig(module: module);

  @override
  Iterable<Uri> get files => const <Uri>[];
}

class JsonFileInput implements SwiftGenInput {
  final Uri jsonFile;

  JsonFileInput({required this.jsonFile});

  @override
  swift2objc.InputConfig? get swift2ObjCConfig =>
      swift2objc.JsonFileInputConfig(jsonFile: jsonFile);

  @override
  Iterable<Uri> get files => const <Uri>[];
}

/// Selected options from [ffigen.FfiGenerator].
class FfiGenConfig {
  /// [ffigen.FfiGenerator.output]
  final Uri output;

  /// [ffigen.FfiGenerator.outputObjC]
  final Uri outputObjC;

  /// [ffigen.FfiGenerator.wrapperName]
  /// Defaults to the swift module name.
  final String? wrapperName;

  /// [ffigen.FfiGenerator.wrapperDocComment]
  final String? wrapperDocComment;

  /// [ffigen.FfiGenerator.preamble]
  final String? preamble;

  /// [ffigen.FfiGenerator.functionDecl]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? functionDecl;

  /// [ffigen.FfiGenerator.structDecl]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? structDecl;

  /// [ffigen.FfiGenerator.unionDecl]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? unionDecl;

  /// [ffigen.FfiGenerator.enumClassDecl]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? enumClassDecl;

  /// [ffigen.FfiGenerator.unnamedEnumConstants]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? unnamedEnumConstants;

  /// [ffigen.FfiGenerator.globals]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? globals;

  /// [ffigen.FfiGenerator.macroDecl]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? macroDecl;

  /// [ffigen.FfiGenerator.typedefs]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? typedefs;

  /// [ffigen.FfiGenerator.objcInterfaces]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? objcInterfaces;

  /// [ffigen.FfiGenerator.objcProtocols]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? objcProtocols;

  /// [ffigen.FfiGenerator.objcCategories]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? objcCategories;

  /// [ffigen.FfiGenerator.externalVersions]
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
    this.objcCategories,
    this.externalVersions = const ffigen.ExternalVersions(),
  });
}
