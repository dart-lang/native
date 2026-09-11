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

JniGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Uri.directory('example/notification_plugin/');
  return JniGenerator(
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
        path:
            outputDir?.resolve('generated.dart') ??
            packageRoot.resolve('lib/notifications.dart'),
        structure: OutputStructure.singleFile,
      ),
      preamble: preamble,
    ),
  );
}

Future<void> main(List<String> args) async {
  final outputDir = args.firstOrNull != null
      ? Uri.directory(args.first)
      : (Platform.environment['OUTPUT_DIR'] != null
            ? Uri.directory(Platform.environment['OUTPUT_DIR']!)
            : null);
  await getConfig(outputDir: outputDir).generate();
}
