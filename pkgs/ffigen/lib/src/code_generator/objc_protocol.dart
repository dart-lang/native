// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

class ObjCProtocol extends NoLookUpBinding with ObjCMethods {
  final superProtos = <ObjCProtocol>[];
  final String lookupName;
  final ObjCBuiltInFunctions builtInFunctions;
  late final ObjCInternalGlobal _protocolPointer;

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

    final buildArgs = <String>[];
    final buildImplementations = StringBuffer();
    final methodFields = StringBuffer();

    final uniqueNamer = UniqueNamer({name, 'pointer'});

    for (final method in methods) {
      final methodName = method.getDartMethodName(uniqueNamer);
      final fieldName = methodName;
      final argName = methodName;
      final blockType = method.protocolBlock!.getDartType(w);

      if (method.isOptional) {
        buildArgs.add('$blockType? $argName');
      } else {
        buildArgs.add('required $blockType $argName');
      }

      buildImplementations.write('''
    builder.implementMethod($name.$fieldName, $argName);''');

      methodFields.write('''
    ${makeDartDoc(method.dartDoc)}
    static final $fieldName = $protoMethod(
      ${method.selObject!.name},
      $getSignature(
          ${_protocolPointer.name},
          ${method.selObject!.name},
          isRequired: ${method.isRequired},
          isInstance: ${method.isInstance},
      ),
      ($blockBase block) => block is $blockType,
    );
''');
    }

    final args = buildArgs.isEmpty ? '' : '{${buildArgs.join(', ')}}';
    final mainString = '''
${makeDartDoc(dartDoc)}
abstract final class $name {
  /// Builds an object that implements the $originalName protocol. To implement
  /// multiple protocols, use [addToBuilder] or [$protoBuilder] directly.
  static $objectBase implement($args) {
    final builder = $protoBuilder();
    $buildImplementations
    return builder.build();
  }

  /// Adds the implementation of the $originalName protocol to an existing
  /// [$protoBuilder].
  static void addToBuilder($protoBuilder builder, $args) {
    $buildImplementations
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

    _protocolPointer = ObjCInternalGlobal(
        '_proto_$originalName',
        (Writer w) =>
            '${ObjCBuiltInFunctions.getProtocol.gen(w)}("$lookupName")')
      ..addDependencies(dependencies);

    for (final superProto in superProtos) {
      superProto.addDependencies(dependencies);
    }

    addMethodDependencies(dependencies, needProtocolBlock: true);

    for (final superProto in superProtos) {
      _copyMethodsFromSuperType(superProto);
    }

    // Add dependencies for any methods that were added.
    addMethodDependencies(dependencies, needProtocolBlock: true);
  }

  void _copyMethodsFromSuperType(ObjCProtocol superProto) {
    if (builtInFunctions.isNSObject(superProto.originalName)) {
      // When writing a protocol that doesn't inherit from any other protocols,
      // it's typical to have it inherit from NSObject instead. But NSObject has
      // heaps of methods that users are very unlikely to want to implement, so
      // ignore it. If the user really wants to implement them they can use the
      // ObjCProtocolBuilder.
      return;
    }

    // Protocols have very different inheritance semantics than Dart classes.
    // So copy across all the methods explicitly, rather than trying to use Dart
    // inheritance to get them implicitly.
    for (final method in superProto.methods) {
      addMethod(method);
    }
  }

  @override
  String toString() => originalName;
}
