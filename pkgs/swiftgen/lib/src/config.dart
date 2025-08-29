// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart' as ffigen;
import 'package:swift2objc/swift2objc.dart' as swift2objc;

import 'util.dart';

/// Config options for swiftgen.
class SwiftGen {
  final Target target;
  final SwiftGenInput input;
  final Uri tempDir;
  final String? outputModule;
  final FfiGenConfig ffigen;

  SwiftGen({
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

  static Future<Target> host() async => Target(
    triple: await swift2objc.hostTarget,
    sdk: await swift2objc.hostSdk,
  );
}

/// Describes the inputs to the swiftgen pipeline.
abstract interface class SwiftGenInput {
  String get module;
  Iterable<Uri> get files;
  Iterable<String> get compileArgs;
}

/// Input swift files that are already annotated with @objc.
class ObjCCompatibleSwiftFileInput implements SwiftGenInput {
  @override
  final String module;

  @override
  final List<Uri> files;

  ObjCCompatibleSwiftFileInput({required this.module, required this.files});

  @override
  Iterable<String> get compileArgs => const <String>[];
}

/// Selected options from [ffigen.FfiGenerator].
class FfiGenConfig {
  /// [ffigen.FfiGenerator.output]
  final Uri output;

  final Uri outputObjC;

  final String? wrapperName;

  final String? wrapperDocComment;

  final String? preamble;

  /// [ffigen.FfiGenerator.functions]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.Functions? functionDecl;

  final ffigen.Structs? structDecl;

  /// [ffigen.FfiGenerator.unionDecl]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? unionDecl;

  final ffigen.Enums? enumClassDecl;

  /// [ffigen.FfiGenerator.unnamedEnumConstants]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.UnnamedEnums? unnamedEnumConstants;

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
