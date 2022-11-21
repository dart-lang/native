// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/config/config.dart';
import 'package:jnigen/src/logging/logging.dart';
import 'package:jnigen/src/util/rename_conflict.dart';

import 'common.dart';

/// Preprocessor which fills information needed by both Dart and C generators.
abstract class ApiPreprocessor {
  static void preprocessAll(Map<String, ClassDecl> classes, Config config,
      {bool renameClasses = false}) {
    final classNameCounts = <String, int>{};
    for (final c in classes.values) {
      final className = getSimplifiedClassName(c.binaryName);
      c.uniqueName = renameConflict(classNameCounts, className);
      if (renameClasses) {
        c.finalName = c.uniqueName;
      } else {
        c.finalName = className;
      }
      _preprocess(c, classes, config);
    }
    // Adding type params of outer classes to the nested classes
    final visited = <ClassDecl>{};
    for (final c in classes.values) {
      _traverseAddTypeParams(visited, c);
    }
  }

  static void _preprocess(
      ClassDecl decl, Map<String, ClassDecl> classes, Config config) {
    if (decl.isPreprocessed) return;
    if (!_isClassIncluded(decl, config)) {
      decl.isIncluded = false;
      log.fine('exclude class ${decl.binaryName}');
      decl.isPreprocessed = true;
      return;
    }
    if (decl.parentName != null && classes.containsKey(decl.parentName!)) {
      decl.parent = classes[decl.parentName];
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
    log.finest('Superclass of ${decl.binaryName} resolved to '
        '${superclass?.binaryName}');
    for (var field in decl.fields) {
      if (!_isFieldIncluded(decl, field, config)) {
        field.isIncluded = false;
        log.fine('exclude ${decl.binaryName}#${field.name}');
        continue;
      }
      field.finalName = renameConflict(decl.nameCounts, field.name);
    }

    for (var method in decl.methods) {
      if (!_isMethodIncluded(decl, method, config)) {
        method.isIncluded = false;
        log.fine('exclude method ${decl.binaryName}#${method.name}');
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
        // TODO(#29): this logic would better live in a dedicated renamer class.
        // don't rename if superNum == 0
        // unless the method name is a keyword.
        final superNumText = superNum == 0 ? '' : '$superNum';
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
    log.fine('preprocessed ${decl.binaryName}');
  }

  /// Gathers all the type params from ancestors of a [ClassDecl] and store
  /// them in [allTypeParams].
  ///
  /// Class A is a parent of Class B when B is nested inside A.
  static void _traverseAddTypeParams(Set<ClassDecl> visited, ClassDecl decl) {
    if (visited.contains(decl)) {
      // The type params of its ancestors have already been added.
      return;
    }
    final allTypeParams = <TypeParam>[];
    if (decl.parent != null) {
      // Adding all type params of parent's ancestors to the parent.
      if (!visited.contains(decl.parent) && decl.parent != decl) {
        _traverseAddTypeParams(visited, decl.parent!);
      }
      // Adding the type params of ancestors if the class is not static.
      if (!decl.modifiers.contains('static')) {
        for (final typeParam in decl.parent!.allTypeParams) {
          if (!decl.allTypeParams.contains(typeParam)) {
            // Add only if it's not shadowing another type param.
            allTypeParams.add(typeParam);
          }
        }
      }
    }
    allTypeParams.addAll(decl.typeParams);
    decl.allTypeParams = allTypeParams;
    visited.add(decl);
  }

  static bool _isPublicOrProtected(Set<String> modifiers) =>
      modifiers.contains("public") || modifiers.contains("protected");

  static bool _isFieldIncluded(ClassDecl decl, Field field, Config config) =>
      _isPublicOrProtected(field.modifiers) &&
      !field.name.startsWith('_') &&
      config.exclude?.fields?.included(decl, field) != false;
  static bool _isMethodIncluded(ClassDecl decl, Method method, Config config) =>
      _isPublicOrProtected(method.modifiers) &&
      !method.name.startsWith('_') &&
      config.exclude?.methods?.included(decl, method) != false;
  static bool _isClassIncluded(ClassDecl decl, Config config) =>
      _isPublicOrProtected(decl.modifiers) &&
      config.exclude?.classes?.included(decl) != false;
}
