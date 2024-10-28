// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../config_provider/config.dart' show Config;
import '../config_provider/config_types.dart' show Language;
import '../strings.dart' as strings;

import 'ast.dart';

class ListBindingsVisitation extends Visitation {
  final Config config;
  final Set<Binding> includes;
  final Set<Binding> transitives;
  final bindings = <Binding>[];

  ListBindingsVisitation(this.config, this.includes, this.transitives);

  void _add(Binding node) {
    node.visitChildren(visitor);
    bindings.add(node);
  }

  void _visitImpl(Binding node, bool includeTransitive) {
    if (node.isObjCImport) return;
    if (includes.contains(node) ||
        (includeTransitive && transitives.contains(node))) {
      _add(node);
    }
  }

  @override
  void visitBinding(Binding node) => _visitImpl(node, true);

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    // Protocols are not transitively included by default.
    _visitImpl(node, false);
  }

  @override
  void visitTypealias(Typealias node) {
    _visitImpl(node, config.includeUnusedTypedefs);

    // Objective C has some core typedefs that are important to keep.
    if (config.language == Language.objc &&
        node.originalName == strings.objcInstanceType) {
      _add(node);
    }
  }
}

class MarkBindingsVisitation extends Visitation {
  final Set<Binding> bindings;

  MarkBindingsVisitation(List<Binding> bindingsList)
      : bindings = {...bindingsList};

  @override
  void visitBinding(Binding node) {
    node.visitChildren(visitor);
    node.generateBindings = bindings.contains(node);
  }
}
