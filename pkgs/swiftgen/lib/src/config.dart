// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart' as ffigen;

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

  static Future<Target> host() => getHostTarget();
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

/// Selected options from [ffigen.Config].
class FfiGenConfig {
  /// [ffigen.Config.output]
  final Uri output;

  /// [ffigen.Config.outputObjC]
  final Uri outputObjC;

  /// [ffigen.Config.wrapperName]
  /// Defaults to the swift module name.
  final String? wrapperName;

  /// [ffigen.Config.wrapperDocComment]
  final String? wrapperDocComment;

  /// [ffigen.Config.preamble]
  final String? preamble;

  /// [ffigen.Config.functionDecl]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? functionDecl;

  /// [ffigen.Config.structDecl]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? structDecl;

  /// [ffigen.Config.unionDecl]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? unionDecl;

  /// [ffigen.Config.enumClassDecl]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? enumClassDecl;

  /// [ffigen.Config.unnamedEnumConstants]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? unnamedEnumConstants;

  /// [ffigen.Config.globals]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? globals;

  /// [ffigen.Config.macroDecl]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? macroDecl;

  /// [ffigen.Config.typedefs]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? typedefs;

  /// [ffigen.Config.objcInterfaces]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? objcInterfaces;

  /// [ffigen.Config.objcProtocols]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? objcProtocols;

  /// [ffigen.Config.objcCategories]
  /// Defaults to [ffigen.DeclarationFilters.excludeAll]
  final ffigen.DeclarationFilters? objcCategories;

  /// [ffigen.Config.externalVersions]
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
