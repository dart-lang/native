// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config/config.dart';
import '../elements/elements.dart';
import '../logging/logging.dart';
import 'visitor.dart';

extension on ClassMember {
  bool get isPrivate => !isPublic;
  bool get hasPrivateName => name.startsWith('_');
}

class Excluder extends Visitor<Classes, void> {
  final Config config;

  const Excluder(this.config);

  @override
  void visit(Classes node) {
    node.decls.removeWhere((_, classDecl) {
      final excluded = classDecl.isPrivate ||
          classDecl.hasPrivateName ||
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
      final isPrivate = method.isPrivate;
      final hasPrivateName = method.hasPrivateName;
      final isAbstractCtor = method.isCtor && node.isAbstract;
      final isBridgeMethod = method.isSynthetic && method.isBridge;
      final isExcludedInConfig =
          config.exclude?.methods?.included(node, method) ?? false;
      final excluded = isPrivate ||
          hasPrivateName ||
          isAbstractCtor ||
          isBridgeMethod ||
          isExcludedInConfig;
      if (excluded) {
        log.fine('Excluded method ${node.binaryName}#${method.name}');
      }
      return !excluded;
    }).toList();
    node.fields = node.fields.where((field) {
      final excluded = field.isPrivate ||
          field.hasPrivateName &&
              (config.exclude?.fields?.included(node, field) ?? true);
      if (excluded) {
        log.fine('Excluded field ${node.binaryName}#${field.name}');
      }
      return !excluded;
    }).toList();
  }
}
