// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'ast.dart';

class FixOverriddenMethodsVisitation extends Visitation {
  @override
  void visitObjCInterface(ObjCInterface node) {
    node.visitChildren(visitor);
    _fixNullability(node);
    _fixMethodsVsProperties(node);
  }

  void _fixNullability(ObjCInterface node) {
    // ObjC ignores nullability when deciding if an override for an inherited
    // method is valid. But in Dart it's invalid to override a method and change
    // it's return type from non-null to nullable, or its arg type from nullable
    // to non-null. So in these cases we have to make the non-null type
    // nullable, to avoid Dart compile errors.
    for (var t = node.superType; t != null; t = t.superType) {
      for (final method in node.methods) {
        final superMethod = t.getMethod(method.originalName);
        if (superMethod != null &&
            !superMethod.isClassMethod &&
            !method.isClassMethod) {
          if (superMethod.returnType.typealiasType is! ObjCNullable &&
              method.returnType.typealiasType is ObjCNullable) {
            superMethod.returnType = ObjCNullable(superMethod.returnType);
          }
          final numArgs = method.params.length < superMethod.params.length
              ? method.params.length
              : superMethod.params.length;
          for (var i = 0; i < numArgs; ++i) {
            final param = method.params[i];
            final superParam = superMethod.params[i];
            if (superParam.type.typealiasType is ObjCNullable &&
                param.type.typealiasType is! ObjCNullable) {
              param.type = ObjCNullable(param.type);
            }
          }
        }
      }
    }
  }

  void _fixMethodsVsProperties(ObjCInterface node) {
    // In ObjC, supertypes and subtypes can have a method that's an ordinary
    // method in some classes of the heirarchy, and a property in others. This
    // isn't allowed in Dart, so we change all such conflicts to properties.
    // This change could cause more conflicts in the heirarchy, so first we walk
    // up to find the root of the subtree that has this method, then we walk
    // down the subtreee to change all conflicting methods to properties.
    for (final method in node.methods) {
      final (root, rootMethod) = _findRootWithMethod(node, method);
      if (method.isProperty == rootMethod.isProperty) continue;
      _convertAllSubtreeMethodsToProperties(root, rootMethod);
    }
  }

  (ObjCInterface, ObjCMethod) _findRootWithMethod(ObjCInterface node, ObjCMethod method) {
    ObjCInterface root = node;
    ObjCMethod rootMethod = method;
    for (ObjCInterface? t = node; t != null; t = t.superType) {
      final tMethod = t.getMethod(method.originalName);
      if (tMethod != null) {
        root = t;
        rootMethod = tMethod;
      }
    }
    return (root, rootMethod);
  }

  void _convertAllSubtreeMethodsToProperties(ObjCInterface node, ObjCMethod rootMethod) {
    ObjCMethod? method = node.getMethod(rootMethod.originalName);
    if (method != null && method.kind == ObjCMethodKind.method) {
      method.kind = ObjCMethodKind.propertyGetter;
    }
    for (final t in node.subtypes) {
      _convertAllSubtreeMethodsToProperties(t, rootMethod);
    }
  }
}
