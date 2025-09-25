// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import 'ast.dart';

class FixOverriddenMethodsVisitation extends Visitation {
  final Context context;

  FixOverriddenMethodsVisitation(this.context);

  @override
  void visitObjCInterface(ObjCInterface node) {
    // Visit the supertype, then perform all AST mutations, then visit the other
    // children. That way we can be sure that the supertype's AST mutations have
    // been completed before this node's mutations (this is important for
    // _fixContravariantReturns).
    visitor.visit(node.superType);

    _fixMethodVariance(node);
    _fixMethodsVsProperties(node);
    _fixMethodSymbols(node);

    node.visitChildren(visitor);
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

  void _fixCoavariantArgs(
    ObjCInterface node,
    ObjCMethod method,
    ObjCInterface superType,
    ObjCMethod superMethod,
  ) {
    // In Dart, method arg types are contravariant, but ObjC allows them to be
    // covariant. So fix these cases by adding the `covariant` keyword to the
    // parameter.
    final logger = context.logger;
    final n = method.params.length;
    if (n != superMethod.params.length) {
      logger.severe(
        '${node.originalName} is a subtype of ${superType.originalName} but '
        'their ${method.originalName} methods have a different number of '
        'parameters',
      );
      return;
    }

    for (var i = 0; i < n; ++i) {
      final pt = method.params.elementAt(i).type;
      final st = superMethod.params.elementAt(i).type;

      if (st.isSubtypeOf(pt)) {
        // Contravariant param, nothing to fix.
        continue;
      }

      if (!pt.isSubtypeOf(st)) {
        // Types are unrelated, so this can't be sensibly fixed.
        logger.severe(
          '${node.originalName} is a subtype of ${superType.originalName} '
          'but their ${method.originalName} methods have a parameter at '
          'position ${i + 1} with an unrelated type',
        );
        return;
      }

      logger.info(
        'Set the parameter of '
        '${node.originalName}.${method.originalName} at position ${i + 1} to '
        'be covariant',
      );
      method.params.elementAt(i).isCovariant = true;
    }
  }

  void _fixMethodVariance(ObjCInterface node) {
    for (final method in node.methods) {
      if (method.isClassMethod) continue;
      final (superType, superMethod) = _findNearestWithMethod(node, method);
      if (superType != null && superMethod != null) {
        _fixContravariantReturns(node, method, superType, superMethod);
        _fixCoavariantArgs(node, method, superType, superMethod);
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
      if (superType != null && superMethod != null) {
        method.symbol = superMethod.symbol;
      }
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
