// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/elements/j_elements.dart' as j;

// These core classes each have multiple constructors, such as a constructor
// that converts a String to an Integer. We only want the constructor that takes
// the primitive type, otherwise the APIs get messy. Filter out all other
// constructors for these classes.
const Map<String, String> _constructorAllowList = {
  'Boolean': 'z',
  'Byte': 'b',
  'Character': 'c',
  'Double': 'd',
  'Float': 'f',
  'Integer': 'i',
  'Long': 'j',
  'Short': 's',
};

class Renamer extends j.Visitor {
  late j.ClassDecl _class;

  @override
  void visitClass(j.ClassDecl c) {
    _class = c;
    c.name = 'J${c.originalName}';
  }

  @override
  void visitMethod(j.Method m) {
    if (!m.isConstructor) return;
    final sig = _constructorAllowList[_class.originalName];
    if (sig == null) return;
    final lister = ListParams();
    m.accept(lister);
    m.isExcluded = !(lister.params.length == 1 && lister.params.first == sig);
  }
}

class ListParams extends j.Visitor {
  List<String> params = [];

  @override
  void visitParam(j.Param p) {
    params.add(p.originalName);
  }
}

Future<void> main() async {
  final classes = [
    'java.lang.Boolean',
    'java.lang.Byte',
    'java.lang.Character',
    'java.lang.Double',
    'java.lang.Float',
    'java.lang.Integer',
    'java.lang.Long',
    'java.lang.Number',
    'java.lang.Short',
    'java.lang.String',
    'java.util.ArrayList',
    'java.util.Collection',
    'java.util.HashMap',
    'java.util.HashSet',
    'java.util.Iterator',
    'java.util.List',
    'java.util.Map',
    'java.util.Set',
  ];
  const preamble = '''
// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: prefer_relative_imports''';

  final packageRoot = Platform.script.resolve('..');
  await generateJniBindings(
    Config(
      androidSdkConfig: AndroidSdkConfig(
        addGradleDeps: true,
        androidExample: packageRoot.resolve('example/').toFilePath(),
      ),
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: packageRoot.resolve('lib/src/core_bindings.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      classes: classes,
      hide: classes,
      preamble: preamble,
      visitors: [Renamer()],
    ),
  );
}
