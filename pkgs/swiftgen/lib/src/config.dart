// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Command {
  final String executable;
  final List<String> arguments;
  Command(this.executable, this.arguments);
}

class Target {
  String triple;
  Uri sdk;
  Target({required this.triple, required this.sdk});
}

abstract interface class ConfigInput {
  String get module;
  Command symbolGraphCommand(Target target);
}

class SwiftFileInput implements ConfigInput {
  @override
  final String module;

  final List<String> files;

  SwiftFileInput({
    required this.module,
    required this.files,
  });

  @override
  Command symbolGraphCommand(Target target) => Command(
        'swiftc',
        [
          ...files,
          '-module-name',
          module,
          '-emit-module',
          '-emit-symbol-graph',
          '-emit-symbol-graph-dir',
          '.',
        ],
      );
}

class SwiftModuleInput implements ConfigInput {
  @override
  final String module;

  SwiftModuleInput({
    required this.module,
  });

  @override
  Command symbolGraphCommand(Target target) => Command(
        'swift',
        [
          'symbolgraph-extract',
          '-module-name',
          module,
          '-target',
          target.triple,
          '-sdk',
          target.sdk.path,
          '-output-dir',
          '.',
        ],
      );
}

class Config {
  final Target target;

  // Input. Either a swift file or a module.
  final ConfigInput input;

  // Intermediates.
  final Uri objcSwiftFile;
  final Uri tempDir;

  // Output file.
  final String outputModule;
  final Uri outputDartFile;

  Config({
    required this.target,
    required this.input,
    required this.objcSwiftFile,
    required this.tempDir,
    required this.outputModule,
    required this.outputDartFile,
  });
}
