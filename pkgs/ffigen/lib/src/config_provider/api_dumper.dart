// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'public_ast.dart';

/// A visitor that dumps all visited AST nodes in a concise, greppable format.
///
/// Output format examples:
/// ```text
/// Func(originalName, USR)
/// Param(paramName, Func(originalName, USR))
/// Struct(originalName, USR)
/// Field(fieldName, Struct(originalName, USR))
/// ObjCInterface(originalName, USR)
/// ObjCMethod(selector, ObjCInterface(originalName, USR))
/// ```
final class ApiDumperVisitor extends Visitor {
  final StringSink _sink;

  /// Creates an [ApiDumperVisitor] that writes to [sink] (defaults to
  /// [stdout]).
  ApiDumperVisitor([StringSink? sink]) : _sink = sink ?? stdout, super.base();

  /// Dumps all [nodes] and returns the formatted output string.
  static String dump(Iterable<AstNode> nodes) {
    final buffer = StringBuffer();
    final visitor = ApiDumperVisitor(buffer);
    visitor.visitAll(nodes);
    return buffer.toString();
  }

  static String _declString(DeclNode decl) =>
      '${decl.runtimeType}(${decl.originalName}, ${decl.usr})';

  static String _visitObjCInterface(ObjCInterface node) => _declString(node);

  static String _visitObjCCategory(ObjCCategory node) =>
      'ObjCCategory(${node.originalName}, ${node.usr}, '
      '${_visitObjCInterface(node.interface)})';

  static String _objCMethodParent(DeclNode node) => switch (node) {
    final ObjCInterface i => _visitObjCInterface(i),
    final ObjCCategory c => _visitObjCCategory(c),
    _ => _declString(node),
  };

  static String _paramParent(NamedNode node) => switch (node) {
    final DeclNode d => _declString(d),
    final ObjCMethod m =>
      'ObjCMethod(${m.selector}, ${_objCMethodParent(m.parent)})',
    final CppMethod c =>
      'CppMethod(${c.originalName}, ${_declString(c.parent)})',
    _ => '${node.runtimeType}(${node.originalName})',
  };

  @override
  void visitFunc(Func node) {
    _sink.writeln(_declString(node));
  }

  @override
  void visitStruct(Struct node) {
    _sink.writeln(_declString(node));
  }

  @override
  void visitUnion(Union node) {
    _sink.writeln(_declString(node));
  }

  @override
  void visitEnum(EnumClass node) {
    _sink.writeln(_declString(node));
  }

  @override
  void visitGlobal(Global node) {
    _sink.writeln(_declString(node));
  }

  @override
  void visitMacro(MacroConstant node) {
    _sink.writeln(_declString(node));
  }

  @override
  void visitTypealias(Typealias node) {
    _sink.writeln(_declString(node));
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    _sink.writeln(_visitObjCInterface(node));
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    _sink.writeln(_declString(node));
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    _sink.writeln(_visitObjCCategory(node));
  }

  @override
  void visitCppClass(CppClass node) {
    _sink.writeln(_declString(node));
  }

  @override
  void visitField(Field node) {
    _sink.writeln('Field(${node.originalName}, ${_declString(node.parent)})');
  }

  @override
  void visitEnumConstant(EnumConstant node) {
    _sink.writeln(
      'EnumConstant(${node.originalName}, ${_declString(node.parent)})',
    );
  }

  @override
  void visitUnnamedEnumConstant(UnnamedEnumConstant node) {
    _sink.writeln(_declString(node));
  }

  @override
  void visitParam(Param node) {
    _sink.writeln('Param(${node.originalName}, ${_paramParent(node.parent)})');
  }

  @override
  void visitObjCMethod(ObjCMethod node) {
    _sink.writeln(
      'ObjCMethod(${node.selector}, ${_objCMethodParent(node.parent)})',
    );
  }

  @override
  void visitCppMethod(CppMethod node) {
    _sink.writeln(
      'CppMethod(${node.originalName}, ${_declString(node.parent)})',
    );
  }
}
