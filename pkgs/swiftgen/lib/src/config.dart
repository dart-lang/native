// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Command {
  final String executable;
  final List<String> arguments;
  Command(this.executable, this.arguments);
}

abstract interface class ConfigInput {
  String get module;
  Command get symbolGraphCommand;
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
  Command get symbolGraphCommand => Command(
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

  final String target;
  final String sdk;

  SwiftModuleInput({
    required this.module,
    required this.target,
    required this.sdk,
  });

  @override
  Command get symbolGraphCommand => Command(
        'swift',
        [
          'symbolgraph-extract',
          '-module-name',
          module,
          '-target',
          target,
          '-sdk',
          sdk,
          '-output-dir',
          '.',
        ],
      );
}

class Config {
  // Input. Either a swift file or a module.
  final ConfigInput input;

  // Intermediates.
  final String objcSwiftFile;
  final String tempDir;

  // Output file.
  final String outputModule;
  final String outputDartFile;

  Config({
    required this.input,
    required this.objcSwiftFile,
    required this.tempDir,
    required this.outputModule,
    required this.outputDartFile,
  });
}
