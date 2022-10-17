// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/bindings/bindings.dart';
import 'package:jnigen/src/logging/logging.dart';
import 'package:jnigen/src/writers/bindings_writer.dart';

/// Resolver for single-file mapping of input classes.
class SingleFileResolver implements SymbolResolver {
  static const predefined = {
    'java.lang.String': 'jni.JniString',
  };
  Map<String, ClassDecl> inputClasses;
  SingleFileResolver(this.inputClasses);
  @override
  List<String> getImportStrings() {
    return [];
  }

  @override
  String? resolve(String binaryName) {
    if (predefined.containsKey(binaryName)) return predefined[binaryName];
    return inputClasses[binaryName]?.finalName;
  }
}

class SingleFileWriter extends BindingsWriter {
  SingleFileWriter(this.config);
  Config config;
  @override
  Future<void> writeBindings(List<ClassDecl> classes) async {
    final preamble = config.preamble;
    final Map<String, List<ClassDecl>> packages = {};
    final Map<String, ClassDecl> classesByName = {};

    for (var c in classes) {
      classesByName.putIfAbsent(c.binaryName, () => c);
      packages.putIfAbsent(c.packageName, () => <ClassDecl>[]);
      packages[c.packageName]!.add(c);
    }

    ApiPreprocessor.preprocessAll(classesByName, config, renameClasses: true);
    await writeCBindings(config, classes);
    final generator = CBasedDartBindingsGenerator(config);
    final file = File.fromUri(config.outputConfig.dartConfig.path);
    await file.create(recursive: true);
    final fileStream = file.openWrite();
    final resolver = SingleFileResolver(classesByName);

    // Have to generate bindings beforehand so that imports are all figured
    // out.
    final bindings = classesByName.values
        .map((decl) => generator.generateBindings(decl, resolver))
        .join("\n");

    fileStream
      ..writeln(preamble ?? '')
      ..writeln(generator.getPreImportBoilerplate())
      ..writeln(resolver.getImportStrings().join('\n'))
      ..writeln(generator.getPostImportBoilerplate())
      ..writeln(bindings);

    await fileStream.close();
    await runDartFormat(file.path);
    log.info('Completed');
    return;
  }
}
