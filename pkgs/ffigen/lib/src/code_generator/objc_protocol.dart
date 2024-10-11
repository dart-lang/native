// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../transform/ast.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

class ObjCProtocol extends NoLookUpBinding with ObjCMethods {
  final superProtocols = <ObjCProtocol>[];
  final String lookupName;
  ObjCInternalGlobal? _protocolPointer;

  @override
  final bool generateBindings;

  @override
  final ObjCBuiltInFunctions builtInFunctions;

  ObjCProtocol({
    super.usr,
    required String super.originalName,
    String? name,
    String? lookupName,
    super.dartDoc,
    required this.builtInFunctions,
    required this.generateBindings,
  })  : lookupName = lookupName ?? originalName,
        super(name: name ?? originalName) {
    if (generateBindings) {
      _protocolPointer = ObjCInternalGlobal(
          '_protocol_$originalName',
          (Writer w) =>
              '${ObjCBuiltInFunctions.getProtocol.gen(w)}("$lookupName")');
    }
  }

  @override
  void sort() => sortMethods();

  @override
  BindingString toBindingString(Writer w) {
    if (!generateBindings) {
      return const BindingString(
          type: BindingStringType.objcProtocol, string: '');
    }

    final protocolMethod = ObjCBuiltInFunctions.protocolMethod.gen(w);
    final protocolListenableMethod =
        ObjCBuiltInFunctions.protocolListenableMethod.gen(w);
    final protocolBuilder = ObjCBuiltInFunctions.protocolBuilder.gen(w);
    final objectBase = ObjCBuiltInFunctions.objectBase.gen(w);
    final getSignature = ObjCBuiltInFunctions.getProtocolMethodSignature.gen(w);

    final buildArgs = <String>[];
    final buildImplementations = StringBuffer();
    final buildListenerImplementations = StringBuffer();
    final methodFields = StringBuffer();

    final methodNamer = createMethodRenamer(w);

    var anyListeners = false;
    for (final method in methods) {
      final methodName = method.getDartMethodName(methodNamer);
      final fieldName = methodName;
      final argName = methodName;
      final block = method.protocolBlock!;
      final blockUtils = block.name;
      final methodClass =
          block.hasListener ? protocolListenableMethod : protocolMethod;

      // The function type omits the first arg of the block, which is unused.
      final func = FunctionType(returnType: block.returnType, parameters: [
        ...block.params.skip(1),
      ]);
      final funcType = func.getDartType(w, writeArgumentNames: false);

      if (method.isOptional) {
        buildArgs.add('$funcType? $argName');
      } else {
        buildArgs.add('required $funcType $argName');
      }

      final blockFirstArg = block.params[0].type.getDartType(w);
      final argsReceived = func.parameters
          .map((p) => '${p.type.getDartType(w)} ${p.name}')
          .join(', ');
      final argsPassed = func.parameters.map((p) => p.name).join(', ');
      final wrapper = '($blockFirstArg _, $argsReceived) => func($argsPassed)';

      var listenerBuilder = '';
      var maybeImplementAsListener = 'implement';
      if (block.hasListener) {
        listenerBuilder = '($funcType func) => $blockUtils.listener($wrapper),';
        maybeImplementAsListener = 'implementAsListener';
        anyListeners = true;
      }

      buildImplementations.write('''
    $name.$fieldName.implement(builder, $argName);''');
      buildListenerImplementations.write('''
    $name.$fieldName.$maybeImplementAsListener(builder, $argName);''');

      methodFields.write(makeDartDoc(method.dartDoc ?? method.originalName));
      methodFields.write('''static final $fieldName = $methodClass<$funcType>(
      ${method.selObject.name},
      $getSignature(
          ${_protocolPointer!.name},
          ${method.selObject.name},
          isRequired: ${method.isRequired},
          isInstanceMethod: ${method.isInstanceMethod},
      ),
      ($funcType func) => $blockUtils.fromFunction($wrapper),
      $listenerBuilder
    );
''');
    }

    final args = buildArgs.isEmpty ? '' : '{${buildArgs.join(', ')}}';
    final builders = '''
  /// Builds an object that implements the $originalName protocol. To implement
  /// multiple protocols, use [addToBuilder] or [$protocolBuilder] directly.
  static $objectBase implement($args) {
    final builder = $protocolBuilder();
    $buildImplementations
    return builder.build();
  }

  /// Adds the implementation of the $originalName protocol to an existing
  /// [$protocolBuilder].
  static void addToBuilder($protocolBuilder builder, $args) {
    $buildImplementations
  }
''';

    var listenerBuilders = '';
    if (anyListeners) {
      listenerBuilders = '''
  /// Builds an object that implements the $originalName protocol. To implement
  /// multiple protocols, use [addToBuilder] or [$protocolBuilder] directly. All
  /// methods that can be implemented as listeners will be.
  static $objectBase implementAsListener($args) {
    final builder = $protocolBuilder();
    $buildListenerImplementations
    return builder.build();
  }

  /// Adds the implementation of the $originalName protocol to an existing
  /// [$protocolBuilder]. All methods that can be implemented as listeners will
  /// be.
  static void addToBuilderAsListener($protocolBuilder builder, $args) {
    $buildListenerImplementations
  }
''';
    }

    final mainString = '''
${makeDartDoc(dartDoc ?? originalName)}abstract final class $name {
  $builders
  $listenerBuilders
  $methodFields
}
''';

    return BindingString(
        type: BindingStringType.objcProtocol, string: mainString);
  }

  void _copyMethodsFromSuperType(ObjCProtocol superProtocol) {
    if (ObjCBuiltInFunctions.isNSObject(superProtocol.originalName)) {
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
    for (final method in superProtocol.methods) {
      addMethod(method);
    }
  }

  @override
  String toString() => originalName;

  @override
  void transformChildren(Transformer transformer) {
    super.transformChildren(transformer);
    _protocolPointer = transformer.transformNullable(_protocolPointer);
    transformer.transformList(superProtocols);
    transformMethods(transformer);
  }
}
