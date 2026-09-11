// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';

const preamble = '''
// Generated from jackson-core which is licensed under the Apache License 2.0.
// The following copyright from the original authors applies.
// See https://github.com/FasterXML/jackson-core/blob/2.14/LICENSE
//
// Copyright (c) 2007 - The Jackson Project Authors
// Licensed under the Apache License, Version 2.0 (the "License")
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
''';

JniGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Uri.directory('test/jackson_core_test/');
  return JniGenerator(
    input: Input(
      classes: [
        'com.fasterxml.jackson.core.JsonFactory',
        'com.fasterxml.jackson.core.JsonParser',
        'com.fasterxml.jackson.core.JsonToken',
      ],
      mavenDownloads: MavenDownloads(
        sourceDeps: ['com.fasterxml.jackson.core:jackson-core:2.13.4'],
        sourceDir: packageRoot.resolve('third_party/java/'),
        jarDir: packageRoot.resolve('third_party/jar/'),
      ),
    ),
    output: Output(
      dart: DartOutput(
        path:
            outputDir?.resolve('lib/') ??
            packageRoot.resolve('third_party/bindings/'),
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
