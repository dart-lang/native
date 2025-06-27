// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart' as fg;

import 'util.dart';

/// Config options for swiftgen.
class SwiftGen {
  final Target target;
  final SwiftGenInput input;
  final Uri tempDir;
  final String? outputModule;

  /// Controls the way ffigen is invoked on the generated ObjC wrapper around
  /// the Swift API. The most important elements to specify are the outputs,
  /// and the API filtering/renaming options.
  ///
  /// Some options will be overriden by SwiftGen: language, entryPoints,
  /// compilerOpts, interfaceModule, protocolModule.
  final fg.Config ffigen;

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
