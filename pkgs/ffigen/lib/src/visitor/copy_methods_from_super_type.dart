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
  'autorelease',
  'class',
  'conformsToProtocol:',
  'copyWithZone:',
  'dealloc',
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
  'release',
  'resolveClassMethod:',
  'resolveInstanceMethod:',
  'respondsToSelector:',
  'retain',
  'retainCount',
  'self',
  'setVersion:',
  'superclass',
  'version',
};

class CopyMethodsFromSuperTypesVisitation extends Visitation {
  @override
  void visitCppClass(CppClass node) {
    node.visitChildren(visitor);

    if (node.bases.isEmpty) return;

    if (node.bases.length == 1) {
      final existingSignatures = node.methods
          .map((m) => m.signatureKey())
          .toSet();
      _copyCppMethodsFromBase(node, node.bases.single, existingSignatures);
      return;
    }

    _copyCppMethodsFromMultipleBases(node);
  }

  void _copyCppMethodsFromBase(
    CppClass target,
    CppClass current,
    Set<String> existingSignatures,
  ) {
    for (final method in current.methods) {
      if (method.kind == CppMethodKind.constructor) continue;

      if (existingSignatures.add(method.signatureKey())) {
        target.copyMethod(method, current);
      }
    }

    for (final base in current.bases) {
      _copyCppMethodsFromBase(target, base, existingSignatures);
    }
  }

  void _copyCppMethodsFromMultipleBases(CppClass target) {
    final ownSignatures = target.methods.map((m) => m.signatureKey()).toSet();

    // Map: signatureKey -> (Map: directBase -> (declaringClass, method))
    final candidatesBySig =
        <
          String,
          Map<CppClass, ({CppClass declaringClass, CppMethod method})>
        >{};

    for (final base in target.bases) {
      final branchMethods = _collectMethodsFromBranch(base);
      for (final entry in branchMethods.entries) {
        final sig = entry.key;
        if (ownSignatures.contains(sig)) continue;
        candidatesBySig.putIfAbsent(sig, () => {})[base] = entry.value;
      }
    }

    for (final entry in candidatesBySig.entries) {
      final candidates = entry.value;

      if (candidates.length == 1) {
        final candidate = candidates.entries.single;
        target.copyMethod(candidate.value.method, candidate.key);
        continue;
      }

      // If all candidates originate from the exact same class, there is no
      // conflict.
      final firstDeclaring = candidates.values.first.declaringClass;
      final allSameDeclaring = candidates.values.every(
        (c) => c.declaringClass == firstDeclaring,
      );
      if (allSameDeclaring) {
        target.copyMethod(
          candidates.values.first.method,
          candidates.keys.first,
        );
        continue;
      }

      // Check dominance: A declaration in class D dominates class A if D is a
      // derived class of A.
      final nonDominated =
          <CppClass, ({CppClass declaringClass, CppMethod method})>{};
      for (final entry1 in candidates.entries) {
        final class1 = entry1.value.declaringClass;
        var isDominated = false;
        for (final entry2 in candidates.entries) {
          if (identical(entry1.key, entry2.key)) continue;
          final class2 = entry2.value.declaringClass;
          if (class1 != class2 && _isSubclassOf(class2, class1)) {
            isDominated = true;
            break;
          }
        }
        if (!isDominated) {
          nonDominated[entry1.key] = entry1.value;
        }
      }

      if (nonDominated.length == 1) {
        final dominating = nonDominated.entries.single;
        target.copyMethod(dominating.value.method, dominating.key);
      } else {
        // Ambiguous diamond inheritance: generate disambiguated copies for each
        // branch, and an ambiguous override that throws UnsupportedError.
        for (final nonDom in nonDominated.entries) {
          target.copyDisambiguatedMethod(nonDom.value.method, nonDom.key);
        }
        target.addAmbiguousMethod(
          candidates.values.first.method,
          nonDominated.keys.toList(),
        );
      }
    }
  }

  Map<String, ({CppClass declaringClass, CppMethod method})>
  _collectMethodsFromBranch(CppClass base) {
    final result = <String, ({CppClass declaringClass, CppMethod method})>{};
    final visited = <CppClass>{};
    void collect(CppClass current) {
      if (!visited.add(current)) return;
      for (final method in current.methods) {
        if (method.kind == CppMethodKind.constructor) continue;
        if (method.isAmbiguous) continue;
        final declaring = method.originatingClass ?? current;
        result.putIfAbsent(
          method.signatureKey(),
          () => (declaringClass: declaring, method: method),
        );
      }
      for (final b in current.bases) {
        collect(b);
      }
    }

    collect(base);
    return result;
  }

  bool _isSubclassOf(CppClass derived, CppClass ancestor) {
    if (derived == ancestor) return true;
    for (final b in derived.bases) {
      if (_isSubclassOf(b, ancestor)) return true;
    }
    return false;
  }

  @override
  void visitObjCInterface(ObjCInterface node) {
    node.visitChildren(visitor, typeGraphOnly: true);

    // We need to copy certain methods from the super type:
    //  - Class methods, because Dart classes don't inherit static methods.
    //  - Methods that return instancetype, because the subclass's copy of the
    //    method needs to return the subclass, not the super class.
    //    Note: instancetype is only allowed as a return type, not an arg type.
    final isNSObject = ObjCBuiltInFunctions.isNSObject(node.originalName);
    final superType = node.superType;
    if (superType != null) {
      for (final m in superType.methods) {
        if (isNSObject) {
          node.copyMethod(m);
        } else if (m.isClassMethod &&
            !_excludedNSObjectMethods.contains(m.originalName)) {
          node.copyMethod(m);
        } else if (ObjCBuiltInFunctions.isInstanceType(m.returnType)) {
          node.copyMethod(m);
        }
      }
    }
    // Copy all methods from all the interface's protocols.
    _copyMethodFromProtocols(node, node.protocols);

    // Copy methods from all the categories that extend this interface, if those
    // methods return instancetype, because the Dart inheritance rules don't
    // match the ObjC rules regarding instancetype.
    // Also copy all methods from any anonymous categories.
    for (final category in node.categories) {
      for (final m in category.methods) {
        if (category.shouldCopyMethodToInterface(m)) {
          node.copyMethod(m, originCategory: category);
        }
      }
    }
  }

  void _copyMethodFromProtocols(
    ObjCMethods node,
    List<ObjCProtocol> protocols,
  ) {
    // Copy all methods from all the protocols.
    for (final proto in protocols) {
      for (final m in proto.methods) {
        if (!_excludedNSObjectMethods.contains(m.originalName)) {
          node.copyMethod(m);
        }
      }
    }
  }

  @override
  void visitObjCCategory(ObjCCategory node) {
    node.visitChildren(visitor, typeGraphOnly: true);

    // Copy all methods from all the category's protocols.
    _copyMethodFromProtocols(node, node.protocols);
  }

  @override
  void visitObjCProtocol(ObjCProtocol node) {
    node.visitChildren(visitor, typeGraphOnly: true);

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
        node.copyMethod(method);
      }
    }
  }
}
