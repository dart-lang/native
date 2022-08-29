// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni_gen/src/elements/elements.dart';
import 'package:jni_gen/src/config/config.dart';
import 'package:jni_gen/src/util/rename_conflict.dart';
import 'common.dart';

/// Preprocessor which fills information needed by both Dart and C generators.
class ApiPreprocessor {
  static void preprocessAll(Map<String, ClassDecl> classes, Config config) {
    for (var c in classes.values) {
      _preprocess(c, classes, config);
    }
  }

  static void _preprocess(
      ClassDecl decl, Map<String, ClassDecl> classes, Config config) {
    if (decl.isPreprocessed) return;
    if (!_isClassIncluded(decl, config)) {
      decl.isIncluded = false;
      stdout.writeln('exclude class ${decl.binaryName}');
      decl.isPreprocessed = true;
      return;
    }
    ClassDecl? superclass;
    if (decl.superclass != null && classes.containsKey(decl.superclass?.name)) {
      superclass = classes[decl.superclass!.name]!;
      _preprocess(superclass, classes, config);
      // again, un-consider superclass if it was excluded through config
      if (!superclass.isIncluded) {
        superclass = null;
      } else {
        decl.nameCounts.addAll(superclass.nameCounts);
      }
    }

    for (var field in decl.fields) {
      if (!_isFieldIncluded(decl, field, config)) {
        field.isIncluded = false;
        stderr.writeln('exclude ${decl.binaryName}#${field.name}');
        continue;
      }
      field.finalName = renameConflict(decl.nameCounts, field.name);
    }

    for (var method in decl.methods) {
      if (!_isMethodIncluded(decl, method, config)) {
        method.isIncluded = false;
        stderr.writeln('exclude method ${decl.binaryName}#${method.name}');
        continue;
      }
      var realName = method.name;
      if (isCtor(method)) {
        realName = 'ctor';
      }
      final sig = method.javaSig;
      // if method already in super class, assign its number, overriding it.
      final superNum = superclass?.methodNumsAfterRenaming[sig];
      if (superNum != null) {
        // don't rename if superNum == 0
        final superNumText = superNum == 0 ? '' : '$superNum';
        // well, unless the method name is a keyword & superNum == 0.
        // TODO(#29): this logic would better live in a dedicated renamer class.
        final methodName = superNum == 0 ? kwRename(realName) : realName;
        method.finalName = '$methodName$superNumText';
        decl.methodNumsAfterRenaming[sig] = superNum;
      } else {
        method.finalName = renameConflict(decl.nameCounts, realName);
        // TODO(#29): This is too much coupled with renameConflict impl.
        // see the above todo.
        decl.methodNumsAfterRenaming[sig] = decl.nameCounts[realName]! - 1;
      }
    }
    decl.isPreprocessed = true;
  }

  static bool _isFieldIncluded(ClassDecl decl, Field field, Config config) =>
      !field.name.startsWith('_') &&
      config.exclude?.fields?.included(decl, field) != false;
  static bool _isMethodIncluded(ClassDecl decl, Method method, Config config) =>
      !method.name.startsWith('_') &&
      config.exclude?.methods?.included(decl, method) != false;
  static bool _isClassIncluded(ClassDecl decl, Config config) =>
      config.exclude?.classes?.included(decl) != false;
}
