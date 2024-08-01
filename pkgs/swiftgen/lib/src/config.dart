// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/swift2objc.dart' as swift2objc;

class Target {
  String triple;
  Uri sdk;
  Target({required this.triple, required this.sdk});
}

abstract interface class ConfigInput {
  String get module;
  swift2objc.InputConfig asSwift2ObjCConfig(Target target);
}

class SwiftFileInput implements ConfigInput {
  @override
  final String module;

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
  final String outputModule;
  final Uri outputDartFile;

  Config({
    required this.target,
    required this.input,
    this.objcSwiftPreamble,
    required this.objcSwiftFile,
    required this.tempDir,
    required this.outputModule,
    required this.outputDartFile,
  });
}
