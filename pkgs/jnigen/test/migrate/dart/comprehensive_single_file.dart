// ignore_for_file: unused_import
import 'dart:io';

import 'package:jnigen/jnigen.dart';

const preamble = '''
// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''';

Future<void> main() async {
  final packageRoot = Uri.directory('example/pdfbox_plugin/');
  await JniGenerator(
    input: Input(
      classes: [
        'org.apache.pdfbox.pdmodel.PDDocument',
      ],
      backend: SummarizerBackend.asm,
      mavenDownloads: MavenDownloads(
        sourceDeps: [
          'org.apache.pdfbox:pdfbox:2.0.26',
        ],
        sourceDir: packageRoot.resolve('mvn_java/'),
        jarOnlyDeps: [
          'org.bouncycastle:bcmail-jdk15on:1.70',
          'org.bouncycastle:bcprov-jdk15on:1.70',
        ],
        jarDir: packageRoot.resolve('mvn_jar/'),
      ),
      androidSdk: AndroidSdk(
        addGradleDeps: true,
        androidExample: packageRoot.resolve('example/'),
      ),
    ),
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('generated.dart'),
        structure: OutputStructure.singleFile,
      ),
      preamble: preamble,
    ),
    imports: const SymbolImports(
      hide: [
        'java.lang.Object',
      ],
    ),
  ).generate();
}
