// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config/config.dart';
import '../elements/elements.dart';
import '../logging/logging.dart';
import 'visitor.dart';

extension on ClassMember {
  bool get isPrivate => !isPublic;
}

// TODO(https://github.com/dart-lang/native/issues/1164): Kotlin compiler
// appends the method name with a dash and a hash code when arguments contain
// inline classes. This is because inline classes do not have any runtime type
// and the typical operator overloading supported by JVM cannot work for them.
//
// Once we support inline classes, we can relax the following constraints.
final _validDartIdentifier = RegExp(r'^[a-zA-Z_$][a-zA-Z0-9_$]*$');

extension on String {
  bool get isInvalidDartIdentifier =>
      !_validDartIdentifier.hasMatch(this) &&
      this != '<init>' &&
      this != '<clinit>';
}

class Excluder extends Visitor<Classes, void> with TopLevelVisitor {
  @override
  final GenerationStage stage = GenerationStage.excluder;

  final Config config;

  const Excluder(this.config);

  @override
  void visit(Classes node) {
    node.decls.removeWhere((_, classDecl) {
      final excluded = classDecl.isPrivate ||
          classDecl.isExcluded ||
          !(config.exclude?.classes?.included(classDecl) ?? true);
      if (excluded) {
        log.fine('Excluded class ${classDecl.binaryName}');
      }
      if (classDecl.name.isInvalidDartIdentifier) {
        log.warning('Excluded class ${classDecl.binaryName}: the name is not a'
            ' valid Dart identifer');
        return true;
      }
      return excluded;
    });
    final classExcluder = _ClassExcluder(config);
    for (final classDecl in node.decls.values) {
      classDecl.accept(classExcluder);
    }
  }
}

class _ClassExcluder extends Visitor<ClassDecl, void> {
  final Config config;

  _ClassExcluder(this.config);

  @override
  void visit(ClassDecl node) {
    node.methods = node.methods.where((method) {
      final isExcluded = method.userDefinedIsExcluded;
      final isPrivate = method.isPrivate;
      final isAbstractCtor = method.isConstructor && node.isAbstract;
      final isBridgeMethod = method.isSynthetic && method.isBridge;
      final isExcludedInConfig =
          config.exclude?.methods?.included(node, method) ?? false;
      final excluded = isPrivate ||
          isAbstractCtor ||
          isBridgeMethod ||
          isExcludedInConfig ||
          isExcluded;
      if (excluded) {
        log.fine('Excluded method ${node.binaryName}#${method.name}');
      }
      if (method.name.isInvalidDartIdentifier) {
        log.warning(
            'Excluded method ${node.binaryName}#${method.name}: the name is not'
            ' a valid Dart identifer');
        return false;
      }
      return !excluded;
    }).toList();
    node.fields = node.fields.where((field) {
      final excluded = field.isExcluded ||
          (field.isPrivate &&
              (config.exclude?.fields?.included(node, field) ?? true));
      if (excluded) {
        log.fine('Excluded field ${node.binaryName}#${field.name}');
      }
      if (field.name.isInvalidDartIdentifier) {
        log.warning(
            'Excluded field ${node.binaryName}#${field.name}: the name is not'
            ' a valid Dart identifer');
        return false;
      }
      return !excluded;
    }).toList();
  }
}
