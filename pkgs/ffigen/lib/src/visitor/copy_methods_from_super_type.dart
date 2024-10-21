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

    for (final proto in node.protocols) {
      for (final m in proto.methods) {
        if (isNSObject) {
          if (m.originalName == 'description' || m.originalName == 'hash') {
            // TODO(https://github.com/dart-lang/native/issues/1220): Remove
            // this special case. These methods only clash because they're
            // sometimes declared as getters and sometimes as normal methods.
          } else {
            node.addMethod(m);
          }
        } else if (!_excludedNSObjectMethods.contains(m.originalName)) {
          node.addMethod(m);
        }
      }
    }
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
