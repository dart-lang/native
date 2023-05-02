// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:jnigen/jnigen.dart';

const testName = 'simple_package_test';
final testRoot = join('test', testName);
final javaPath = join(testRoot, 'java');

const preamble = '''
// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

''';

var javaPrefix = join('com', 'github', 'dart_lang', 'jnigen');

var javaFiles = [
  join(javaPrefix, 'simple_package', 'Example.java'),
  join(javaPrefix, 'pkg2', 'C2.java'),
  join(javaPrefix, 'pkg2', 'Example.java'),
  join(javaPrefix, 'generics', 'MyStack.java'),
  join(javaPrefix, 'generics', 'MyMap.java'),
  join(javaPrefix, 'generics', 'GrandParent.java'),
  join(javaPrefix, 'generics', 'StringStack.java'),
  join(javaPrefix, 'generics', 'StringValuedMap.java'),
  join(javaPrefix, 'generics', 'StringKeyedMap.java'),
  join(javaPrefix, 'annotations', 'JsonSerializable.java'),
  join(javaPrefix, 'annotations', 'MyDataClass.java'),
];

void compileJavaSources(String workingDir, List<String> files) async {
  final procRes = Process.runSync('javac', files, workingDirectory: workingDir);
  if (procRes.exitCode != 0) {
    throw "javac exited with ${procRes.exitCode}\n"
        "${procRes.stderr}";
  }
}

Config getConfig([BindingsType bindingsType = BindingsType.cBased]) {
  compileJavaSources(javaPath, javaFiles);
  final typeDir = bindingsType.getConfigString();
  final cWrapperDir = Uri.directory(join(testRoot, typeDir, "c_bindings"));
  final dartWrappersRoot = Uri.directory(
    join(testRoot, typeDir, "dart_bindings"),
  );
  final config = Config(
    sourcePath: [Uri.directory(javaPath)],
    classPath: [Uri.directory(javaPath)],
    classes: [
      'com.github.dart_lang.jnigen.simple_package',
      'com.github.dart_lang.jnigen.pkg2',
      'com.github.dart_lang.jnigen.generics',
      'com.github.dart_lang.jnigen.annotations',
    ],
    logLevel: Level.INFO,
    outputConfig: OutputConfig(
      bindingsType: bindingsType,
      cConfig: CCodeOutputConfig(
        path: cWrapperDir,
        libraryName: 'simple_package',
      ),
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
  await generateJniBindings(getConfig(BindingsType.cBased));
  await generateJniBindings(getConfig(BindingsType.dartOnly));
}
