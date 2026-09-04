// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Platform.script.resolve('../');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: packageRoot.resolve('swift_api_bindings.dart')),
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''',
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
}

Future<void> main() async {
  await getConfig().generate();
}
