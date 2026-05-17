// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'scope.dart';
import 'utils.dart';
import 'writer.dart';

/// A method or constructor belonging to a C++ class.
class CppMethod extends AstNode {
  final String name;
  final String originalName;
  final Type returnType;
  final List<Parameter> parameters;
  final bool isConstant;
  final bool isStatic;

  CppMethod({
    required this.name,
    required this.originalName,
    required this.returnType,
    required this.parameters,
    required this.isConstant,
    this.isStatic = false,
  });

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(returnType);
    visitor.visitAll(parameters);
  }
}

/// A binding for a C++ class.
class CppClass extends BindingType with HasLocalScope {
  final Context context;
  final List<CppMethod> methods;
  final List<CppMethod> constructors;
  bool hasDestructor;
  final List<CompoundMember> fields;

  CppClass({
    super.usr,
    super.originalName,
    required super.name,
    super.dartDoc,
    required this.context,
    required this.methods,
    required this.constructors,
    required this.hasDestructor,
    required this.fields,
  });

  @override
  void visit(Visitation visitation) => visitation.visitCppClass(this);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final ffiPrefix = context.libs.prefix(ffiImport);

    s.write(makeDartDoc(dartDoc));
    s.write('class $name {\n');
    s.write('  // ignore: unused_field\n');
    s.write('  final $ffiPrefix.Pointer<$ffiPrefix.Void> _ptr;\n\n');
    s.write('  $name._(this._ptr);\n\n');
    for (final field in fields) {
      s.write('  // TODO: getter for field ${field.name}\n');
    }
    if (fields.isNotEmpty) s.write('\n');
    for (final method in methods) {
      s.write('  // TODO: method ${method.name}\n');
    }
    if (methods.isNotEmpty) s.write('\n');
    s.write('  void dispose() {\n');
    s.write('    // TODO: call ${name}_delete(_ptr);\n');
    s.write('  }\n');
    s.write('}\n');

    return BindingString(
      type: BindingStringType.cppClass,
      string: s.toString(),
    );
  }

  @override
  String getCType(Context context) => name;

  @override
  bool get sameFfiDartAndCType => true;

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(methods);
    visitor.visitAll(constructors);
    visitor.visitAll(fields);
    visitor.visit(ffiImport);
  }
}
