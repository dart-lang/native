// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config/config.dart';
import '../elements/elements.dart';
import '../logging/logging.dart';
import 'visitor.dart';

bool _isPrivate(ClassMember classMember) =>
    !classMember.isPublic && !classMember.isProtected;

class Excluder extends Visitor<Classes, void> {
  final Config config;

  const Excluder(this.config);

  @override
  void visit(Classes node) {
    node.decls.removeWhere((_, classDecl) {
      final excluded = _isPrivate(classDecl) ||
          !(config.exclude?.classes?.included(classDecl) ?? true);
      if (excluded) {
        log.fine('Excluded class ${classDecl.binaryName}');
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
      final included = !_isPrivate(method) &&
          !method.name.startsWith('_') &&
          method.name != '<clinit>' &&
          (config.exclude?.methods?.included(node, method) ?? true);
      if (!included) {
        log.fine('Excluded method ${node.binaryName}#${method.name}');
      }
      return included;
    }).toList();
    node.fields = node.fields.where((field) {
      final included = !_isPrivate(field) &&
          !field.name.startsWith('_') &&
          (config.exclude?.fields?.included(node, field) ?? true);
      if (!included) {
        log.fine('Excluded field ${node.binaryName}#${field.name}');
      }
      return included;
    }).toList();
  }
}
