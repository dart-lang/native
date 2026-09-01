// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';

const preamble = '''
// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''';

void main() async {
  final packageRoot = Platform.script.resolve('../');
  final generator = JniGenerator(
    input: Input(
      sourcePath: [packageRoot.resolve('android/src/main/java')],
      classes: ['com.example.notification_plugin.Notifications'],
      androidSdk: AndroidSdk(
        addGradleDeps: true,
        androidExample: packageRoot.resolve('example/'),
      ),
    ),
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/notifications.dart'),
        structure: OutputStructure.singleFile,
      ),
      preamble: preamble,
    ),
  );
  await generator.generate();
}
