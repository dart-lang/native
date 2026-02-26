// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../../config.dart';
import '../../../_core/interfaces/availability.dart';
import '../../../_core/interfaces/declaration.dart';
import '../../../_core/interfaces/objc_annotatable.dart';
import '../../../_core/shared/parameter.dart';
import '../../../_core/shared/referred_type.dart';
import '../../../ast_node.dart';
import 'property_declaration.dart';

/// Describes a subscript declaration for a Swift compound entity
class SubscriptDeclaration extends AstNode
    implements Declaration, ObjCAnnotatable {
  @override
  String id;

  @override
  String name = 'subscript';

  @override
  InputConfig? source;

  @override
  final int? lineNumber;

  @override
  List<AvailabilityInfo> availability;

  @override
  bool hasObjCAnnotation;

  ReferredType returnType;

  List<Parameter> params;

  bool throws;

  bool async;

  bool mutating;

  bool hasSetter;

  PropertyStatements? getter;
  PropertyStatements? setter;

  bool isStatic;

  SubscriptDeclaration({
    required this.id,
    required this.source,
    required this.availability,
    required this.returnType,
    required this.params,
    this.lineNumber,
    this.hasSetter = false,
    this.hasObjCAnnotation = false,
    this.getter,
    this.setter,
    this.isStatic = false,
    this.throws = false,
    this.async = false,
    this.mutating = false,
  });

  @override
  void visit(Visitation visitation) =>
      visitation.visitSubscriptDeclaration(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(params);
    visitor.visit(returnType);
  }
}
