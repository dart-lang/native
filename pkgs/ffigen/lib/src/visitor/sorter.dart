// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import '../code_generator/binding.dart';
import '../code_generator/objc_category.dart';
import '../code_generator/objc_interface.dart';
import '../code_generator/objc_protocol.dart';
import 'ast.dart';

class SorterVisitation extends Visitation {
  final List<Binding> sorted;

  SorterVisitation(Iterable<Binding> bindings, String Function(Binding) sortKey)
    : sorted = bindings.toList()..sortBy(sortKey);

  static String nameSortKey(Binding binding) => binding.name;

  // Sorts by type then original name. The _lowPriorityTypes are sorted after
  // all other types.
  static String originalNameSortKey(Binding binding) =>
      '${_typeKey(binding)} ${binding.originalName}';
  static const _lowPriorityTypes = {'ObjCCategory', 'ObjCProtocol'};
  static String _typeKey(Object o) {
    final t = '${o.runtimeType}';
    // '~' comes after all valid Dart naming characters.
    if (_lowPriorityTypes.contains(t)) return '~$t';
    return t;
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    node.sortMethods();
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    node.sortMethods();
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    node.sortMethods();
  }
}
