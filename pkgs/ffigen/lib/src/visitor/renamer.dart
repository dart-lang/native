// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'ast.dart';

class TopLevelRenamerVisitation extends Visitation {
  final Context context;
  final _topLevelNamer = UniqueNamer();
  final _wrapperLevelNamer = UniqueNamer();
  final _objCNamer = UniqueNamer();

  TopLevelRenamerVisitation(this.context);

  void _renameName(Binding node) {
    final oldName = node.name;
    node.name = _topLevelNamer.makeUnique(node.name);
    if (oldName != node.name) {
      context.logger.warning(
        "Resolved name conflict: Declaration '$oldName' "
        "and has been renamed to '${node.name}'.",
      );
    }

    if (node.name.startsWith('_') && !node.isInternal) {
      context.logger.warning(
        "Generated declaration '${node.name}' starts with '_' "
        'and therefore will be private.',
      );
    }
  }

  @override
  void visitBinding(Binding node) {
    _renameName(node);
    node.visitChildren(visitor);
  }

  @override
  void visitGlobal(Global node) {
    _renameName(node);
    node.fillPointerName(_wrapperLevelNamer);
    node.visitChildren(visitor);
  }

  @override
  void visitObjCBlockWrapperFuncs(ObjCBlockWrapperFuncs node) {
    node.fillNativeNames(_objCNamer);
    node.visitChildren(visitor);
  }

  @override
  void visitObjCProtocolMethodTrampoline(ObjCProtocolMethodTrampoline node) {
    node.fillNativeName(_objCNamer);
    node.visitChildren(visitor);
  }

  @override
  void visitObjCBlock(ObjCBlock node) {
    _renameName(node);
    node.fillInternalNames(_topLevelNamer);
    node.visitChildren(visitor);
  }

  @override
  void visitTypealias(Typealias node) {
    _renameName(node);
    node.fillAliasNames(_topLevelNamer);
    node.visitChildren(visitor);
  }
}

class MemberRenamerVisitation extends Visitation {
  final Context context;

  MemberRenamerVisitation(this.context);

  @override
  void visitCompound(Compound node) {
    node.renameMembers();
    node.visitChildren(visitor);
  }

  @override
  void visitEnumClass(EnumClass node) {
    // TODO
    node.visitChildren(visitor);
  }

  @override
  void visitFunc(Func node) {
    // TODO
    node.visitChildren(visitor);
  }

  @override
  void visitFuncType(FuncType node) {
    // TODO
    node.visitChildren(visitor);
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    // TODO
    node.visitChildren(visitor);
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    // TODO
    node.visitChildren(visitor);
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    // TODO
    node.visitChildren(visitor);
  }
}
