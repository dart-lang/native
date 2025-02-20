// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/logging/logging.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

const testName = 'simple_package_test';
final testRoot = join('test', testName);
final javaPath = join(testRoot, 'java');

const preamble = '''
// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

''';

final javaPrefix = join('com', 'github', 'dart_lang', 'jnigen');

final javaFiles = [
  join(javaPrefix, 'annotations', 'Annotated.java'),
  join(javaPrefix, 'annotations', 'JsonSerializable.java'),
  join(javaPrefix, 'annotations', 'MyDataClass.java'),
  join(javaPrefix, 'annotations', 'NotNull.java'),
  join(javaPrefix, 'annotations', 'Nullable.java'),
  join(javaPrefix, 'simple_package', 'Example.java'),
  join(javaPrefix, 'simple_package', 'Exceptions.java'),
  join(javaPrefix, 'simple_package', 'Fields.java'),
  join(javaPrefix, 'pkg2', 'C2.java'),
  join(javaPrefix, 'pkg2', 'Example.java'),
  join(javaPrefix, 'enums', 'Colors.java'),
  join(javaPrefix, 'generics', 'MyStack.java'),
  join(javaPrefix, 'generics', 'MyMap.java'),
  join(javaPrefix, 'generics', 'GenericTypeParams.java'),
  join(javaPrefix, 'generics', 'GrandParent.java'),
  join(javaPrefix, 'generics', 'StringStack.java'),
  join(javaPrefix, 'generics', 'StringKeyedMap.java'),
  join(javaPrefix, 'generics', 'StringMap.java'),
  join(javaPrefix, 'generics', 'StringValuedMap.java'),
  join(javaPrefix, 'inheritance', 'BaseClass.java'),
  join(javaPrefix, 'inheritance', 'BaseInterface.java'),
  join(javaPrefix, 'inheritance', 'BaseGenericInterface.java'),
  join(javaPrefix, 'inheritance', 'DerivedInterface.java'),
  join(javaPrefix, 'inheritance', 'GenericDerivedClass.java'),
  join(javaPrefix, 'inheritance', 'SpecificDerivedClass.java'),
  join(javaPrefix, 'interfaces', 'GenericInterface.java'),
  join(javaPrefix, 'interfaces', 'InheritedFromMyInterface.java'),
  join(javaPrefix, 'interfaces', 'InheritedFromMyRunnable.java'),
  join(javaPrefix, 'interfaces', 'MyInterface.java'),
  join(javaPrefix, 'interfaces', 'MyInterfaceConsumer.java'),
  join(javaPrefix, 'interfaces', 'MyRunnable.java'),
  join(javaPrefix, 'interfaces', 'MyRunnableRunner.java'),
  join(javaPrefix, 'interfaces', 'StringConversionException.java'),
  join(javaPrefix, 'interfaces', 'StringConverter.java'),
  join(javaPrefix, 'interfaces', 'StringConverterConsumer.java'),
];

void compileJavaSources(String workingDir, List<String> files) async {
  final procRes = Process.runSync('javac', files, workingDirectory: workingDir);
  if (procRes.exitCode != 0) {
    log.fatal('javac exited with ${procRes.exitCode}\n'
        '${procRes.stderr}');
  }
}

Config getConfig({SummarizerBackend backend = SummarizerBackend.asm}) {
  compileJavaSources(javaPath, javaFiles);
  final dartWrappersRoot = Uri.directory(
    join(testRoot, 'bindings'),
  );
  final config = Config(
    sourcePath: [Uri.directory(javaPath)],
    classPath: [Uri.directory(javaPath)],
    summarizerOptions: SummarizerOptions(backend: backend),
    classes: [
      'com.github.dart_lang.jnigen.simple_package',
      'com.github.dart_lang.jnigen.pkg2',
      'com.github.dart_lang.jnigen.enums',
      'com.github.dart_lang.jnigen.generics',
      'com.github.dart_lang.jnigen.interfaces',
      'com.github.dart_lang.jnigen.inheritance',
      'com.github.dart_lang.jnigen.annotations',
    ],
    logLevel: Level.INFO,
    nonNullAnnotations: ['com.github.dart_lang.jnigen.annotations.NotNull'],
    nullableAnnotations: ['com.github.dart_lang.jnigen.annotations.Nullable'],
    customClassBody: {
      'com.github.dart_lang.jnigen.interfaces.MyInterface': r'''
  static core$_.Map<int, $MyInterface> get $impls => _$impls;
''',
      'com.github.dart_lang.jnigen.interfaces.MyRunnable': r'''
  static core$_.Map<int, $MyRunnable> get $impls => _$impls;
'''
    },
    outputConfig: OutputConfig(
      dartConfig: DartCodeOutputConfig(
        path: dartWrappersRoot.resolve('simple_package.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
    preamble: preamble,
  );
  return config;
}

void main() async {
  await generateJniBindings(getConfig());
}
