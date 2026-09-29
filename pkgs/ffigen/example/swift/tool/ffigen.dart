// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Platform.script.resolve('../');
  // snippet-start#generator
  final generator = FfiGenerator(
    output: Output(
      dart: DartOutput(path: packageRoot.resolve('swift_api_bindings.dart')),
    ),
    objectiveC: const ObjectiveC(),
    input: Input(entryPoints: [packageRoot.resolve('third_party/swift_api.h')]),
    visitors: [
      Visitor(
        objCInterface: (node) {
          if (node.name == 'SwiftClass') {
            node.isIncluded = true;
            node.module = 'swift_module';
          }
        },
      ),
    ],
  );
  // snippet-end#generator
  return generator;
}

Future<void> main() async {
  await getConfig().generate();
}
