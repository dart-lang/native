// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni_gen/src/elements/elements.dart';
import 'package:jni_gen/src/config/wrapper_options.dart';
import 'package:jni_gen/src/util/rename_conflict.dart';
import 'common.dart';

/// Preprocessor which fills information needed by both Dart and C generators.
class ApiPreprocessor {
  ApiPreprocessor(this.classes, this.options);
  final Map<String, ClassDecl> classes;
  final WrapperOptions options;

  void preprocessAll() {
    for (var c in classes.values) {
      _preprocess(c);
    }
  }

  void _preprocess(ClassDecl decl) {
    if (decl.isPreprocessed) return;
    if (!_isClassIncluded(decl)) {
      decl.isIncluded = false;
      stdout.writeln('exclude class ${decl.binaryName}');
      decl.isPreprocessed = true;
      return;
    }
    ClassDecl? superclass;
    if (decl.superclass != null && classes.containsKey(decl.superclass?.name)) {
      superclass = classes[decl.superclass!.name]!;
      _preprocess(superclass);
      // again, un-consider superclass if it was excluded through config
      if (!superclass.isIncluded) {
        superclass = null;
      } else {
        decl.nameCounts.addAll(superclass.nameCounts);
      }
    }

    for (var field in decl.fields) {
      if (!_isFieldIncluded(decl, field)) {
        field.isIncluded = false;
        stderr.writeln('exclude ${decl.binaryName}#${field.name}');
        continue;
      }
      field.finalName = renameConflict(decl.nameCounts, field.name);
    }

    for (var method in decl.methods) {
      if (!_isMethodIncluded(decl, method)) {
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

  bool _isFieldIncluded(ClassDecl decl, Field field) =>
      options.fieldFilter?.included(decl, field) != false;
  bool _isMethodIncluded(ClassDecl decl, Method method) =>
      options.methodFilter?.included(decl, method) != false;
  bool _isClassIncluded(ClassDecl decl) =>
      options.classFilter?.included(decl) != false;
}
