// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';

const preamble = '''
// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''';

JniGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Uri.directory('test/simple_package_test/');
  return JniGenerator(
    input: Input(
      sourcePath: [packageRoot.resolve('java')],
      classPath: [packageRoot.resolve('java')],
      classes: [
        'com.github.dart_lang.jnigen.simple_package.Example',
        'com.github.dart_lang.jnigen.annotations.Annotated',
      ],
      extraArgs: ['-Xmaxerrs', '1000'],
      workingDirectory: packageRoot.resolve('.'),
      backend: SummarizerBackend.doclet,
      mavenDownloads: MavenDownloads(
        sourceDir: packageRoot.resolve('mvn_java/'),
        jarDir: packageRoot.resolve('mvn_jar/'),
      ),
      androidSdk: AndroidSdk(
        versions: [33, 34],
        sdkRoot: packageRoot.resolve('.'),
        androidExample: packageRoot.resolve('example/'),
      ),
    ),
    output: Output(
      dart: DartOutput(
        path: outputDir?.resolve('lib/') ?? packageRoot.resolve('lib/'),
        structure: OutputStructure.packageStructure,
      ),
      symbols: SymbolsOutput(packageRoot.resolve('symbols.yaml')),
      preamble: preamble,
    ),
    imports: SymbolImports(
      symbolFiles: [Uri.parse('package:jni/jni_symbols.yaml')],
      hide: ['java.lang.Object'],
    ),
    nullability: const NullabilityAnnotations(
      nonNull: ['com.github.dart_lang.jnigen.annotations.NotNull'],
      nullable: ['com.github.dart_lang.jnigen.annotations.Nullable'],
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
