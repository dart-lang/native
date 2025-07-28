// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

class ObjCCategory extends NoLookUpBinding with ObjCMethods {
  @override
  final Context context;
  final ObjCInterface parent;
  final ObjCInternalGlobal classObject;

  final protocols = <ObjCProtocol>[];

  ObjCCategory({
    super.usr,
    required String super.originalName,
    String? name,
    required this.parent,
    super.dartDoc,
    required this.context,
  }) : classObject = parent.classObject,
       super(name: name ?? originalName);

  void addProtocol(ObjCProtocol? proto) {
    if (proto != null) protocols.add(proto);
  }

  bool shouldCopyMethodToInterface(ObjCMethod method) {
    if (originalName.isEmpty) return true;
    return method.returnsInstanceType && !parent.isObjCImport;
  }

  @override
  bool get isObjCImport =>
      context.objCBuiltInFunctions.isBuiltInCategory(originalName);

  @override
  void sort() => sortMethods();

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    s.write('\n');
    s.write(makeDartDoc(dartDoc));
    s.write('''
extension $name on ${parent.getDartType(w)} {
${generateMethodBindings(w, parent)}
}

''');
    return BindingString(
      type: BindingStringType.objcCategory,
      string: s.toString(),
    );
  }

  @override
  String toString() => originalName;

  @override
  void visit(Visitation visitation) => visitation.visitObjCCategory(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(parent);
    visitor.visit(classObject);
    visitor.visitAll(protocols);
    visitMethods(visitor);
  }
}
