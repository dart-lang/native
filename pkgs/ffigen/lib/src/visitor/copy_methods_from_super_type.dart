// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'ast.dart';

// Methods defined on NSObject that we don't want to copy to child objects,
// because they're unlikely to be used, and pollute the bindings. Note: Many of
// these are still accessible via inheritance from NSObject.
const _excludedNSObjectMethods = {
  'allocWithZone:',
  'class',
  'conformsToProtocol:',
  'copyWithZone:',
  'debugDescription',
  'description',
  'hash',
  'initialize',
  'instanceMethodForSelector:',
  'instanceMethodSignatureForSelector:',
  'instancesRespondToSelector:',
  'isSubclassOfClass:',
  'load',
  'mutableCopyWithZone:',
  'poseAsClass:',
  'resolveClassMethod:',
  'resolveInstanceMethod:',
  'respondsToSelector:',
  'setVersion:',
  'superclass',
  'version',
};

class CopyMethodsFromSuperTypesVisitation extends Visitation {
  @override
  void visitObjCInterface(ObjCInterface node) {
    node.visitChildren(visitor);

    final isNSObject = ObjCBuiltInFunctions.isNSObject(node.originalName);

    // We need to copy certain methods from the super type:
    //  - Class methods, because Dart classes don't inherit static methods.
    //  - Methods that return instancetype, because the subclass's copy of the
    //    method needs to return the subclass, not the super class.
    //    Note: instancetype is only allowed as a return type, not an arg type.
    final superType = node.superType;
    if (superType != null) {
      for (final m in superType.methods) {
        if (isNSObject) {
          node.addMethod(m);
        } else if (m.isClassMethod &&
            !_excludedNSObjectMethods.contains(m.originalName)) {
          node.addMethod(m);
        } else if (ObjCBuiltInFunctions.isInstanceType(m.returnType)) {
          node.addMethod(m);
        }
      }
    }

    // Copy all methods from all the interface's protocols.
    _copyMethodFromProtocols(node, node.protocols, node.addMethod);

    // Copy methods from all the categories that extend this interface, if those
    // methods return instancetype, because the Dart inheritance rules don't
    // match the ObjC rules regarding instancetype.
    // Also copy all methods from any anonymous categories.
    // NOTE: The methods are copied regardless of whether the category is
    // included by the config filters, since this method copying visit happens
    // before the filtering visit. This is technically a bug, but it's unlikely
    // to bother anyone, and the fix would be complicated. So we'll ignore it
    // for now.
    for (final category in node.categories) {
      for (final m in category.methods) {
        if (category.shouldCopyMethodToInterface(m)) {
          node.addMethod(m);
        }
      }
    }
  }

  void _copyMethodFromProtocols(Binding node, List<ObjCProtocol> protocols,
      void Function(ObjCMethod) addMethod) {
    // Copy all methods from all the protocols.
    final isNSObject = ObjCBuiltInFunctions.isNSObject(node.originalName);
    for (final proto in protocols) {
      for (final m in proto.methods) {
        if (isNSObject) {
          addMethod(m);
        } else if (!_excludedNSObjectMethods.contains(m.originalName)) {
          addMethod(m);
        }
      }
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    node.visitChildren(visitor);

    // Copy all methods from all the category's protocols.
    _copyMethodFromProtocols(node, node.protocols, node.addMethod);
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    node.visitChildren(visitor);

    for (final superProtocol in node.superProtocols) {
      if (ObjCBuiltInFunctions.isNSObject(superProtocol.originalName)) {
        // When writing a protocol that doesn't inherit from any other
        // protocols, it's typical to have it inherit from NSObject instead. But
        // NSObject has heaps of methods that users are very unlikely to want to
        // implement, so ignore it. If the user really wants to implement them
        // they can use the ObjCProtocolBuilder.
        continue;
      }

      // Protocols have very different inheritance semantics than Dart classes.
      // So copy across all the methods explicitly, rather than trying to use
      // Dart inheritance to get them implicitly.
      for (final method in superProtocol.methods) {
        node.addMethod(method);
      }
    }
  }
}
