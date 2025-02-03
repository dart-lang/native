// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

class ObjCProtocol extends BindingType with ObjCMethods {
  final superProtocols = <ObjCProtocol>[];
  final String lookupName;
  final ObjCInternalGlobal _protocolPointer;
  late final ObjCInternalGlobal _conformsTo;
  late final ObjCMsgSendFunc _conformsToMsgSend;

  // Filled by ListBindingsVisitation.
  bool generateAsStub = false;

  @override
  final ObjCBuiltInFunctions builtInFunctions;

  ObjCProtocol({
    super.usr,
    required String super.originalName,
    String? name,
    String? lookupName,
    super.dartDoc,
    required this.builtInFunctions,
  })  : lookupName = lookupName ?? originalName,
        _protocolPointer = ObjCInternalGlobal(
            '_protocol_$originalName',
            (Writer w) =>
                '${ObjCBuiltInFunctions.getProtocol.gen(w)}("$lookupName")'),
        super(
            name: builtInFunctions.getBuiltInProtocolName(originalName) ??
                name ??
                originalName) {
    _conformsTo = builtInFunctions.getSelObject('conformsToProtocol:');
    _conformsToMsgSend = builtInFunctions.getMsgSendFunc(BooleanType(), [
      Parameter(
        name: 'protocol',
        type: PointerType(objCProtocolType),
        objCConsumed: false,
      )
    ]);
  }

  @override
  bool get isObjCImport =>
      builtInFunctions.getBuiltInProtocolName(originalName) != null;

  @override
  void sort() => sortMethods();

  @override
  BindingString toBindingString(Writer w) {
    final protocolBase = ObjCBuiltInFunctions.protocolBase.gen(w);
    final protocolMethod = ObjCBuiltInFunctions.protocolMethod.gen(w);
    final protocolListenableMethod =
        ObjCBuiltInFunctions.protocolListenableMethod.gen(w);
    final protocolBuilder = ObjCBuiltInFunctions.protocolBuilder.gen(w);
    final objectBase = ObjCBuiltInFunctions.objectBase.gen(w);
    final rawObjType = PointerType(objCObjectType).getCType(w);
    final getSignature = ObjCBuiltInFunctions.getProtocolMethodSignature.gen(w);

    final s = StringBuffer();
    s.write('\n');
    if (generateAsStub) {
      s.write('''
/// WARNING: $name is a stub. To generate bindings for this class, include
/// $originalName in your config's objc-protocols list.
///
''');
    }
    s.write(makeDartDoc(dartDoc ?? originalName));

    final sp = superProtocols.map((p) => p.getDartType(w));
    final impls = superProtocols.isEmpty ? '' : 'implements ${sp.join(', ')}';
    s.write('''
interface class $name extends $protocolBase $impls{
  $name._($rawObjType pointer, {bool retain = false, bool release = false}) :
          super(pointer, retain: retain, release: release);

  /// Constructs a [$name] that points to the same underlying object as [other].
  $name.castFrom($objectBase other) :
      this._(other.ref.pointer, retain: true, release: true);

  /// Constructs a [$name] that wraps the given raw object pointer.
  $name.castFromPointer($rawObjType other,
      {bool retain = false, bool release = false}) :
      this._(other, retain: retain, release: release);

''');

    if (!generateAsStub) {
      final buildArgs = <String>[];
      final buildImplementations = StringBuffer();
      final buildListenerImplementations = StringBuffer();
      final buildBlockingImplementations = StringBuffer();
      final methodFields = StringBuffer();

      final methodNamer = createMethodRenamer(w);

      var anyListeners = false;
      for (final method in methods) {
        final methodName =
            method.getDartMethodName(methodNamer, usePropertyNaming: false);
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
        final wrapper =
            '($blockFirstArg _, $argsReceived) => func($argsPassed)';

        var listenerBuilders = '';
        var maybeImplementAsListener = 'implement';
        var maybeImplementAsBlocking = 'implement';
        if (block.hasListener) {
          listenerBuilders = '''
    ($funcType func) => $blockUtils.listener($wrapper),
    ($funcType func) => $blockUtils.blocking($wrapper),
''';
          maybeImplementAsListener = 'implementAsListener';
          maybeImplementAsBlocking = 'implementAsBlocking';
          anyListeners = true;
        }

        buildImplementations.write('''
    $name.$fieldName.implement(builder, $argName);''');
        buildListenerImplementations.write('''
    $name.$fieldName.$maybeImplementAsListener(builder, $argName);''');
        buildBlockingImplementations.write('''
    $name.$fieldName.$maybeImplementAsBlocking(builder, $argName);''');

        methodFields.write(makeDartDoc(method.dartDoc ?? method.originalName));
        methodFields.write('''static final $fieldName = $methodClass<$funcType>(
      ${_protocolPointer.name},
      ${method.selObject.name},
      $getSignature(
          ${_protocolPointer.name},
          ${method.selObject.name},
          isRequired: ${method.isRequired},
          isInstanceMethod: ${method.isInstanceMethod},
      ),
      ($funcType func) => $blockUtils.fromFunction($wrapper),
      $listenerBuilders
    );
''');
      }

      final args = buildArgs.isEmpty ? '' : '{${buildArgs.join(', ')}}';
      final builders = '''
  /// Builds an object that implements the $originalName protocol. To implement
  /// multiple protocols, use [addToBuilder] or [$protocolBuilder] directly.
  static $name implement($args) {
    final builder = $protocolBuilder();
    $buildImplementations
    return $name.castFrom(builder.build());
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
  static $name implementAsListener($args) {
    final builder = $protocolBuilder();
    $buildListenerImplementations
    return $name.castFrom(builder.build());
  }

  /// Adds the implementation of the $originalName protocol to an existing
  /// [$protocolBuilder]. All methods that can be implemented as listeners will
  /// be.
  static void addToBuilderAsListener($protocolBuilder builder, $args) {
    $buildListenerImplementations
  }

  /// Builds an object that implements the $originalName protocol. To implement
  /// multiple protocols, use [addToBuilder] or [$protocolBuilder] directly. All
  /// methods that can be implemented as blocking listeners will be.
  static $name implementAsBlocking($args) {
    final builder = $protocolBuilder();
    $buildBlockingImplementations
    return $name.castFrom(builder.build());
  }

  /// Adds the implementation of the $originalName protocol to an existing
  /// [$protocolBuilder]. All methods that can be implemented as blocking
  /// listeners will be.
  static void addToBuilderAsBlocking($protocolBuilder builder, $args) {
    $buildBlockingImplementations
  }
''';
      }

      s.write('''
  /// Returns whether [obj] is an instance of [$name].
  static bool conformsTo($objectBase obj) {
    return ${_conformsToMsgSend.invoke(
        w,
        'obj.ref.pointer',
        _conformsTo.name,
        [_protocolPointer.name],
      )};
  }

  $builders
  $listenerBuilders
  $methodFields
''');
    }
    s.write('''
}
''');

    return BindingString(
        type: BindingStringType.objcProtocol, string: s.toString());
  }

  @override
  BindingString? toObjCBindingString(Writer w) {
    final wrapName = builtInFunctions.wrapperName;
    final mainString = '''

Protocol* _${wrapName}_$originalName(void) { return @protocol($originalName); }
''';

    return BindingString(
        type: BindingStringType.objcProtocol, string: mainString);
  }

  @override
  String getCType(Writer w) => PointerType(objCObjectType).getCType(w);

  @override
  String getDartType(Writer w) =>
      isObjCImport ? '${w.objcPkgPrefix}.$name' : name;

  @override
  String getNativeType({String varName = ''}) => 'id $varName';

  @override
  String getObjCBlockSignatureType(Writer w) => getDartType(w);

  @override
  bool get sameFfiDartAndCType => true;

  @override
  bool get sameDartAndCType => false;

  @override
  bool get sameDartAndFfiDartType => false;

  @override
  String convertDartTypeToFfiDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) =>
      ObjCInterface.generateGetId(value, objCRetain, objCAutorelease);

  @override
  String convertFfiDartTypeToDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) =>
      ObjCInterface.generateConstructor(getDartType(w), value, objCRetain);

  @override
  String? generateRetain(String value) =>
      '(__bridge id)(__bridge_retained void*)($value)';

  bool _isSuperProtocolOf(ObjCProtocol protocol) {
    if (protocol == this) return true;
    for (final superProtocol in protocol.superProtocols) {
      if (_isSuperProtocolOf(superProtocol)) return true;
    }
    return false;
  }

  @override
  bool isSupertypeOf(Type other) {
    other = other.typealiasType;
    if (other is ObjCProtocol) {
      return _isSuperProtocolOf(other);
    } else if (other is ObjCInterface) {
      for (ObjCInterface? t = other; t != null; t = t.superType) {
        for (final protocol in t.protocols) {
          if (_isSuperProtocolOf(protocol)) return true;
        }
      }
    }
    return false;
  }

  @override
  String toString() => originalName;

  @override
  void visit(Visitation visitation) => visitation.visitObjCProtocol(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(_protocolPointer);
    visitor.visitAll(superProtocols);
    visitor.visit(_conformsTo);
    visitor.visit(_conformsToMsgSend);
    visitMethods(visitor);
  }
}
