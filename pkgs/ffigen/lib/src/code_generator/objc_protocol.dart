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
  late final _protocolObject;

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
    final objectBase = ObjCBuiltInFunctions.objectBase.gen(w);
    final blockBase = ObjCBuiltInFunctions.blockBase.gen(w);
    final getSignature = ObjCBuiltInFunctions.getProtocolMethodSignature.gen(w);

    final buildMethodArgs = <String>[];
    final buildMethodImplementations = StringBuffer();
    final methodFields = StringBuffer();

    final uniqueNamer = UniqueNamer({name, 'pointer'});

    for (final method in methods) {
      final methodName = method.getDartMethodName(uniqueNamer);
      final fieldName = methodName;
      final argName = methodName;
      final blockType = method.protocolBlock!.getDartType(w);

      if (method.isOptional) {
        buildMethodArgs.add('$blockType? $argName');
      } else {
        buildMethodArgs.add('required $blockType $argName');
      }

      buildMethodImplementations.write('''
    builder.implementMethod($name.$fieldName, $argName);''');

      methodFields.write('''
    ${makeDartDoc(method.dartDoc)}
    static final $fieldName = $protoMethod(
      ${method.selObject!.name},
      $getSignature(
          ${_protocolObject.name},
          ${method.selObject!.name},
          isRequired: ${method.isRequired},
          isInstance: ${method.isInstance},
      ),
      ($blockBase block) => block is $blockType,
    );
''');
    }

    final mainString = '''
${makeDartDoc(dartDoc)}
abstract final class $name {
  /// Builds an object that implements the $originalName protocol. To implement
  /// multiple protocols, use [$protoBuilder].
  static $objectBase build({${buildMethodArgs.join(', ')}}) {
    final builder = $protoBuilder();
    $buildMethodImplementations
    return builder.build();
  }

  $methodFields
}
''';

    return BindingString(
        type: BindingStringType.objcProtocol, string: mainString);
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);

    _protocolObject = ObjCInternalGlobal('_proto_$originalName',
        (Writer w) => '${ObjCBuiltInFunctions.getProtocol.gen(w)}("$lookupName")')
      ..addDependencies(dependencies);

    for (final superProto in superProtos) {
      superProto.addDependencies(dependencies);
    }

    addMethodDependencies(dependencies, builtInFunctions, needProtocolBlock: true);

    for (final superProto in superProtos) {
      _copyMethodsFromSuperType(superProto);
    }
  }

  void _copyMethodsFromSuperType(ObjCProtocol superProto) {
    if (builtInFunctions.isNSObject(superProto.originalName)) {
      // When writing a protocol that doesn't inherit from any other protocols,
      // it's typical to have it inherit from NSObject instead. But NSObject has
      // heaps of methods that users are very unlikely to want to implement, so
      // ignore it. If the user really wants to implemnt them they can use the
      // ObjCProtocolBuilder.
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
