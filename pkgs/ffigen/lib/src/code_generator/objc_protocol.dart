// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

class ObjCProtocol extends NoLookUpBinding with ObjCMethods {
  final superProtos = <ObjCProtocol>[];

  final String lookupName;
  final ObjCBuiltInFunctions builtInFunctions;

  ObjCProtocol({
    super.usr,
    required String super.originalName,
    String? name,
    String? lookupName,
    super.dartDoc,
    required this.builtInFunctions,
  })  : lookupName = lookupName ?? originalName,
        super(name: name ?? originalName);

  @override
  BindingString toBindingString(Writer w) {
    final protoMethod = ObjCBuiltInFunctions.protoMethod.gen(w);
    final protoBuilder = ObjCBuiltInFunctions.protoBuilder.gen(w);
    final dartProxy = ObjCBuiltInFunctions.dartProxy.gen(w);

    final methodArgs = 'args';
    final methodImplementations = 'impl';

    final mainString = '''
abstract final class $name {
  static $dartProxy build($methodArgs) {
    $methodImplementations;
  }

  static final someMethod = $protoMethod();
}
''';

    return BindingString(
        type: BindingStringType.objcProtocol, string: mainString);
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);
    print("Adding deps for $originalName : $superProtos");

    for (final superProto in superProtos) {
      superProto.addDependencies(dependencies);
    }

    addMethodDependencies(dependencies, builtInFunctions, needBlock: true);

    for (final superProto in superProtos) {
      _copyMethodsFromSuperType(superProto);
    }
  }

  void _copyMethodsFromSuperType(ObjCProtocol superProto) {
    if (builtInFunctions.isNSObject(superProto.originalName)) {
      // When writing a protocol that doesn't inherit from any other protocols,
      // it's typical to have it inherit from NSObject instead. But NSObject has
      // heaps of methods that users are very unlikely to want to implement.
      return;
    }

    // Protocols have very different inheritance semantics than Dart classes.
    // So copy across all the methods explicitly, rather than trying to use Dart
    // inheritance to get them implicitly.
    for (ObjCMethod method in superProto.methods) {
      addMethod(method);
    }
  }

  @override
  String toString() => originalName;
}
