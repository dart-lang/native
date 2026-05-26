// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'local_variables.dart';
import 'scope.dart';
import 'utils.dart';
import 'writer.dart';

enum CppMethodKind { constructor, destructor, method }

/// A method or constructor belonging to a C++ class.
class CppMethod extends AstNode with HasLocalScope {
  final String name;
  final String originalName;
  final Type returnType;
  final List<Parameter> parameters;
  final bool isConstant;
  final bool isStatic;
  final CppMethodKind kind;

  CppMethod({
    required this.name,
    required this.originalName,
    required this.returnType,
    required this.parameters,
    required this.isConstant,
    this.isStatic = false,
    this.kind = CppMethodKind.method,
  });

  bool get isConstructor => kind == CppMethodKind.constructor;
  bool get isDestructor => kind == CppMethodKind.destructor;

  @override
  void visit(Visitation visitation) => visitation.visitCppMethod(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(returnType);
    visitor.visitAll(parameters);
  }
}

class CppMember extends CompoundMember {
  /// Whether this field is declared `const` in the C++ source.
  ///
  /// A const field can only have a getter generated; mutable fields get both
  /// a getter and a setter.
  final bool isConst;

  CppMember({
    super.originalName,
    required super.name,
    required super.type,
    super.dartDoc,
    required this.isConst,
  });
}

/// A binding for a C++ class.
class CppClass extends BindingType with HasLocalScope {
  final Context context;
  final List<CppMethod> methods;
  final List<CppMember> fields;

  CppClass({
    super.usr,
    super.originalName,
    required super.name,
    super.dartDoc,
    required this.context,
    required this.methods,
    required this.fields,
  });

  @override
  void visit(Visitation visitation) => visitation.visitCppClass(this);

  @override
  String convertDartTypeToFfiDartType(
    Context context,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
    required LocalVariables localVariables,
  }) => '$value._ptr';

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final ctx = w.context;
    final ffiPrefix = ctx.libs.prefix(ffiImport);

    final ptrVoid = '$ffiPrefix.Pointer<$ffiPrefix.Void>';

    final classMethods = methods
        .where((m) => m.kind == CppMethodKind.method)
        .toList();

    s.write(makeDartDoc(dartDoc));
    s.write('''
class $name {
  // ignore: unused_field
  final $ptrVoid _ptr;

  $name._(this._ptr);
''');

    for (final method in classMethods) {
      final glue = '_${name}_${method.name}';
      final dartReturn = method.returnType.getDartType(ctx);
      final dartParams = method.parameters
          .map((p) => '${p.type.getDartType(ctx)} ${p.name}')
          .join(', ');

      final callArgs = [
        if (!method.isStatic) '_ptr',
        ...method.parameters.map((p) => p.name),
      ].join(', ');

      final staticKeyword = method.isStatic ? 'static ' : '';
      s.write(
        '  $staticKeyword$dartReturn ${method.name}($dartParams)'
        ' => $glue($callArgs);\n',
      );
    }
    s.write('}\n');

    for (final method in classMethods) {
      final symbol = '${name}_${method.name}';
      final glue = '_$symbol';

      final cReturn = method.returnType.getCType(ctx);
      final cParams = [
        if (!method.isStatic) ptrVoid,
        ...method.parameters.map((p) => p.type.getCType(ctx)),
      ].join(', ');
      final cType = '$cReturn Function($cParams)';

      final ffiReturn = method.returnType.getFfiDartType(ctx);
      final ffiParams = [
        if (!method.isStatic) '$ptrVoid self',
        ...method.parameters.map(
          (p) => '${p.type.getFfiDartType(ctx)} ${p.name}',
        ),
      ].join(', ');

      s.write(
        makeNativeAnnotation(
          w,
          nativeType: cType,
          dartName: glue,
          nativeSymbolName: symbol,
        ),
      );
      s.write('\nexternal $ffiReturn $glue($ffiParams);\n\n');
    }

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
  bool get sameDartAndCType => false;

  @override
  bool get sameDartAndFfiDartType => false;

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(methods);
    visitor.visitAll(fields);
    visitor.visit(ffiImport);
  }
}
