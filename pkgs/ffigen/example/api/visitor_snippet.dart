// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:ffigen/ffigen.dart';

// snippet-start#filter_visitor
final class FilterVisitor extends Visitor {
  FilterVisitor() : super.base();

  @override
  void visitFunc(Func node) {
    if (node.name.startsWith('_')) {
      node.isIncluded = false;
    }
  }
}
// snippet-end#filter_visitor

// snippet-start#rename_visitor
final class RenameVisitor extends Visitor {
  RenameVisitor() : super.base();

  @override
  void visitStruct(Struct node) {
    if (node.name == 'custom_type') {
      node.name = 'CustomType';
    }
  }
}
// snippet-end#rename_visitor

void closuresExample() {
  // snippet-start#filter_closure
  Visitor(
    func: (node) {
      if (node.name.startsWith('_')) {
        node.isIncluded = false;
      }
    },
  )
  // snippet-end#filter_closure
  ;

  // snippet-start#rename_closure
  Visitor(
    struct: (node) {
      if (node.name == 'custom_type') {
        node.name = 'CustomType';
      }
    },
  )
  // snippet-end#rename_closure
  ;
}
