// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';

import 'package:jnigen/jnigen.dart';

const preamble = '''
// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''';

JniGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Uri.directory('example/pdfbox_plugin/');
  return JniGenerator(
    input: Input(
      classes: ['org.apache.pdfbox.pdmodel.PDDocument'],
      backend: SummarizerBackend.asm,
      mavenDownloads: MavenDownloads(
        sourceDeps: ['org.apache.pdfbox:pdfbox:2.0.26'],
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
        path:
            outputDir?.resolve('generated.dart') ??
            packageRoot.resolve('generated.dart'),
        structure: OutputStructure.singleFile,
      ),
      preamble: preamble,
    ),
    imports: const SymbolImports(hide: ['java.lang.Object']),
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
