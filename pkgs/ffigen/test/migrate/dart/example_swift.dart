// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../example/swift/');
  final dartPath = outputDir != null
      ? outputDir.resolve('swift_api_bindings.dart')
      : packageRoot.resolve('swift_api_bindings.dart');
  final objcPath = outputDir != null
      ? outputDir.resolve('swift_api_bindings.dart.m')
      : packageRoot.resolve('swift_api_bindings.dart.m');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      objectiveCFile: objcPath,
      style: const DynamicLibraryBindings(
        wrapperName: 'SwiftLibrary',
        wrapperDocComment: 'Bindings for swift_api.',
      ),
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''',
    ),
    input: Input(entryPoints: [packageRoot.resolve('third_party/swift_api.h')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) {
          node.isIncluded = node.originalName == 'SwiftClass';
          if (node.originalName == 'SwiftClass') {
            node.module = 'swift_module';
          }
        },
      ),
    ],
  );
}

Future<void> main(List<String> args) async {
  final outputDir = args.isNotEmpty
      ? Uri.directory(args.first)
      : Platform.environment['OUTPUT_DIR'] != null
      ? Uri.directory(Platform.environment['OUTPUT_DIR']!)
      : null;
  await getConfig(outputDir: outputDir).generate();
}
