// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import 'ast.dart';

// Various fixups related to ObjC's inheritance being less strict than Dart's:
//  - ObjC isn't as strict about return type covariance and arg type
//    contravariance as Dart is.
//  - ObjC allows properties to override methods, but Dart doesn't allow getters
//    and setters to override methods.
// This visitation detects these cases and attemps to fix them. Also, it merges
// the Symbols of overridden methods so that the later renaming pass is
// consistent.
class FixOverriddenMethodsVisitation extends Visitation {
  final Context context;

  FixOverriddenMethodsVisitation(this.context);

  @override
  void visitObjCInterface(ObjCInterface node) {
    node.visitChildren(visitor, typeGraphOnly: true);

    _fixMethodVariance(node);
    _fixMethodsVsProperties(node);
    _fixMethodSymbols(node);
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    node.visitChildren(visitor, typeGraphOnly: true);
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    node.visitChildren(visitor, typeGraphOnly: true);
  }

  (ObjCInterface?, ObjCMethod?) _findNearestWithMethod(
    ObjCInterface node,
    ObjCMethod method,
  ) {
    for (var t = node.superType; t != null; t = t.superType) {
      final tMethod = t.getSimilarMethod(method);
      if (tMethod != null) {
        return (t, tMethod);
      }
    }
    return (null, null);
  }

  void _fixContravariantReturns(
    ObjCInterface node,
    ObjCMethod method,
    ObjCInterface superType,
    ObjCMethod superMethod,
  ) {
    // In Dart, method return types are covariant, but ObjC allows them to be
    // contravariant. So fix these cases by changing the supertype's return type
    // to match the subtype's return type.

    if (method.returnType.isSubtypeOf(superMethod.returnType)) {
      // Covariant return, nothing to fix.
      return;
    }

    if (!superMethod.returnType.isSubtypeOf(method.returnType)) {
      // Types are unrelated, so this can't be sensibly fixed.
      context.logger.severe(
        '${node.originalName} is a subtype of ${superType.originalName} but '
        'the return types of their ${method.originalName} methods are '
        'unrelated',
      );
      return;
    }

    superMethod.returnType = method.returnType;
    context.logger.info(
      'Changed the return type of '
      '${superType.originalName}.${superMethod.originalName} to '
      '${method.returnType} to match ${node.originalName}',
    );

    final (superSuperType, superSuperMethod) = _findNearestWithMethod(
      superType,
      superMethod,
    );
    if (superSuperType != null && superSuperMethod != null) {
      _fixContravariantReturns(node, method, superSuperType, superSuperMethod);
    }
  }

  void _fixMethodVariance(ObjCInterface node) {
    for (final method in node.methods) {
      if (method.isClassMethod) continue;
      final (superType, superMethod) = _findNearestWithMethod(node, method);
      if (superType != null && superMethod != null) {
        _fixContravariantReturns(node, method, superType, superMethod);
      }
    }
  }

  void _fixMethodsVsProperties(ObjCInterface node) {
    // In ObjC, supertypes and subtypes can have a method that's an ordinary
    // method in some classes of the heirarchy, and a property in others. This
    // isn't allowed in Dart, so we change all such conflicts to properties.
    // This change could cause more conflicts in the heirarchy, so first we walk
    // up to find the root of the subtree that has this method, then we walk
    // down the subtree to change all conflicting methods to properties.
    for (final method in node.methods) {
      if (method.isClassMethod) continue;
      final (root, rootMethod) = _findRootWithMethod(node, method);
      // If method and rootMethod are the same kind, then there's nothing to do.
      if ((method.kind == ObjCMethodKind.propertyGetter) ==
          (rootMethod.kind == ObjCMethodKind.propertyGetter)) {
        continue;
      }
      _convertAllSubtreeMethodsToProperties(root, rootMethod);
    }
  }

  void _fixMethodSymbols(ObjCInterface node) {
    // If a method overrides a super method, they should have the same name.
    for (final method in node.methods) {
      if (method.isClassMethod) continue;
      final (superType, superMethod) = _findRootWithMethod(node, method);
      method.symbol = superMethod.symbol;
    }
  }

  (ObjCInterface, ObjCMethod) _findRootWithMethod(
    ObjCInterface node,
    ObjCMethod method,
  ) {
    var root = node;
    var rootMethod = method;
    for (ObjCInterface? t = node; t != null; t = t.superType) {
      final tMethod = t.getSimilarMethod(method);
      if (tMethod != null) {
        root = t;
        rootMethod = tMethod;
      }
    }
    return (root, rootMethod);
  }

  void _convertAllSubtreeMethodsToProperties(
    ObjCInterface node,
    ObjCMethod rootMethod,
  ) {
    final method = node.getSimilarMethod(rootMethod);
    if (method != null && method.kind == ObjCMethodKind.method) {
      method.kind = ObjCMethodKind.propertyGetter;
      context.logger.info(
        'Converted ${node.originalName}.${method.originalName} to a getter',
      );
    }
    for (final t in node.subtypes) {
      _convertAllSubtreeMethodsToProperties(t, rootMethod);
    }
  }
}
