// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';

const preamble = '''
// Generated from Apache PDFBox library which is licensed under the Apache License 2.0.
// The following copyright from the original authors applies.
//
// Licensed to the Apache Software Foundation (ASF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.
// The ASF licenses this file to You under the Apache License, Version 2.0
// (the "License"); you may not use this file except in compliance with
// the License.  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
''';

JniGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Uri.directory('example/pdfbox_plugin/');
  return JniGenerator(
    input: Input(
      classes: [
        'org.apache.pdfbox.pdmodel.PDDocument',
        'org.apache.pdfbox.pdmodel.PDDocumentInformation',
        'org.apache.pdfbox.text.PDFTextStripper',
      ],
      mavenDownloads: MavenDownloads(
        sourceDeps: ['org.apache.pdfbox:pdfbox:2.0.26'],
        sourceDir: packageRoot.resolve('mvn_java/'),
        jarOnlyDeps: [
          'org.bouncycastle:bcmail-jdk15on:1.70',
          'org.bouncycastle:bcprov-jdk15on:1.70',
        ],
        jarDir: packageRoot.resolve('mvn_jar/'),
      ),
    ),
    output: Output(
      dart: DartOutput(
        path:
            outputDir?.resolve('lib/') ??
            packageRoot.resolve('lib/src/third_party/'),
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
