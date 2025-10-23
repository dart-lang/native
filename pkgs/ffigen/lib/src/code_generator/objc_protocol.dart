// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../header_parser/sub_parsers/api_availability.dart';
import '../visitor/ast.dart';
import 'binding_string.dart';
import 'scope.dart';
import 'utils.dart';
import 'writer.dart';

class ObjCProtocol extends BindingType with ObjCMethods, HasLocalScope {
  @override
  final Context context;
  final superProtocols = <ObjCProtocol>[];
  final String lookupName;
  final ObjCInternalGlobal _protocolPointer;
  late final ObjCInternalGlobal _conformsTo;
  late final ObjCMsgSendFunc _conformsToMsgSend;
  final ApiAvailability apiAvailability;

  // Filled by ListBindingsVisitation.
  bool generateAsStub = false;

  ObjCProtocol({
    super.usr,
    required String super.originalName,
    String? name,
    String? lookupName,
    super.dartDoc,
    required this.apiAvailability,
    required this.context,
  }) : lookupName = lookupName ?? originalName,
       _protocolPointer = ObjCInternalGlobal(
         '_protocol_$originalName',
         () =>
             '${ObjCBuiltInFunctions.getProtocol.gen(context)}("$lookupName")',
       ),
       super(
         name:
             context.objCBuiltInFunctions.getBuiltInProtocolName(
               originalName,
             ) ??
             name ??
             originalName,
       ) {
    _conformsTo = context.objCBuiltInFunctions.getSelObject(
      'conformsToProtocol:',
    );
    _conformsToMsgSend = context.objCBuiltInFunctions
        .getMsgSendFunc(BooleanType(), [
          Parameter(
            name: 'protocol',
            type: PointerType(objCProtocolType),
            objCConsumed: false,
          ),
        ]);
  }

  @override
  bool get isObjCImport =>
      context.objCBuiltInFunctions.getBuiltInProtocolName(originalName) != null;

  bool get unavailable => apiAvailability.availability == Availability.none;

  @override
  BindingString toBindingString(Writer w) {
    final protocolClass = ObjCBuiltInFunctions.protocolClass.gen(context);
    final protocolBase = ObjCBuiltInFunctions.protocolBase.gen(context);
    final protocolMethod = ObjCBuiltInFunctions.protocolMethod.gen(context);
    final protocolListenableMethod = ObjCBuiltInFunctions
        .protocolListenableMethod
        .gen(context);
    final protocolBuilder = ObjCBuiltInFunctions.protocolBuilder.gen(context);
    final objectBase = ObjCBuiltInFunctions.objectBase.gen(context);
    final rawObjType = PointerType(objCObjectType).getCType(context);
    final getSignature = ObjCBuiltInFunctions.getProtocolMethodSignature.gen(
      context,
    );

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

    final sp = superProtocols.map((p) => p.getDartType(context));
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
      final msgSendInvoke = _conformsToMsgSend.invoke(
        context,
        'obj.ref.pointer',
        _conformsTo.name,
        [_protocolPointer.name],
      );

      s.write('''

  /// Returns whether [obj] is an instance of [$name].
  static bool conformsTo($objectBase obj) {
    return $msgSendInvoke;
  }
''');
    }

    s.write('''
}

''');

    if (!generateAsStub) {
      s.write('''
extension $name\$Methods on $name {
${generateInstanceMethodBindings(w, this)}
}

''');
    }

    if (!generateAsStub) {
      final builder = '$name\$Builder';
      s.write('''
  interface class $builder {
  ''');

      final buildArgs = <String>[];
      final buildImplementations = StringBuffer();
      final buildListenerImplementations = StringBuffer();
      final buildBlockingImplementations = StringBuffer();
      final methodFields = StringBuffer();

      var anyListeners = false;
      for (final method in methods) {
        final methodName = method.protocolMethodName!.name;
        final fieldName = methodName;
        final argName = methodName;
        final block = method.protocolBlock!;
        final blockUtils = block.name;
        final methodClass = block.hasListener
            ? protocolListenableMethod
            : protocolMethod;

        // The function type omits the first arg of the block, which is unused.
        final func = FunctionType(
          returnType: block.returnType,
          parameters: [...block.params.skip(1)],
        );
        final funcType = func.getDartType(context, writeArgumentNames: false);

        if (method.isOptional) {
          buildArgs.add('$funcType? $argName');
        } else {
          buildArgs.add('required $funcType $argName');
        }

        final blockFirstArg = block.params[0].type.getDartType(context);
        final argsReceived = func.parameters
            .map((p) => '${p.type.getDartType(context)} ${p.name}')
            .join(', ');
        final argsPassed = func.parameters.map((p) => p.name).join(', ');
        final wrapper =
            '($blockFirstArg _, $argsReceived) => func($argsPassed)';

        var listenerBuilders = '';
        var maybeImplementAsListener = 'implement';
        var maybeImplementAsBlocking = 'implement';
        if (block.hasListener) {
          listenerBuilders =
              '''
    ($funcType func) => $blockUtils.listener($wrapper),
    ($funcType func) => $blockUtils.blocking($wrapper),
''';
          maybeImplementAsListener = 'implementAsListener';
          maybeImplementAsBlocking = 'implementAsBlocking';
          anyListeners = true;
        }

        buildImplementations.write('''
    $builder.$fieldName.implement(builder, $argName);''');
        buildListenerImplementations.write('''
    $builder.$fieldName.$maybeImplementAsListener(builder, $argName);''');
        buildBlockingImplementations.write('''
    $builder.$fieldName.$maybeImplementAsBlocking(builder, $argName);''');

        methodFields.write(makeDartDoc(method.dartDoc ?? method.originalName));
        methodFields.write('''static final $fieldName = $methodClass<$funcType>(
      ${_protocolPointer.name},
      ${method.selObject.name},
      ${_trampolineAddress(block)},
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

      buildArgs.add('bool \$keepIsolateAlive = true');
      final args = '{${buildArgs.join(', ')}}';
      final builders =
          '''
  /// Returns the [$protocolClass] object for this protocol.
  static $protocolClass get \$protocol =>
      $protocolClass.castFromPointer(${_protocolPointer.name}.cast());

  /// Builds an object that implements the $originalName protocol. To implement
  /// multiple protocols, use [addToBuilder] or [$protocolBuilder] directly.
  ///
  /// If `\$keepIsolateAlive` is true, this protocol will keep this isolate
  /// alive until it is garbage collected by both Dart and ObjC.
  static $name implement($args) {
    final builder = $protocolBuilder(debugName: '$originalName');
    $buildImplementations
    builder.addProtocol(\$protocol);
    return $name.castFrom(builder.build(keepIsolateAlive: \$keepIsolateAlive));
  }

  /// Adds the implementation of the $originalName protocol to an existing
  /// [$protocolBuilder].
  ///
  /// Note: You cannot call this method after you have called `builder.build`.
  static void addToBuilder($protocolBuilder builder, $args) {
    $buildImplementations
    builder.addProtocol(\$protocol);
  }
''';

      var listenerBuilders = '';
      if (anyListeners) {
        listenerBuilders =
            '''
  /// Builds an object that implements the $originalName protocol. To implement
  /// multiple protocols, use [addToBuilder] or [$protocolBuilder] directly. All
  /// methods that can be implemented as listeners will be.
  ///
  /// If `\$keepIsolateAlive` is true, this protocol will keep this isolate
  /// alive until it is garbage collected by both Dart and ObjC.
  static $name implementAsListener($args) {
    final builder = $protocolBuilder(debugName: '$originalName');
    $buildListenerImplementations
    builder.addProtocol(\$protocol);
    return $name.castFrom(builder.build(keepIsolateAlive: \$keepIsolateAlive));
  }

  /// Adds the implementation of the $originalName protocol to an existing
  /// [$protocolBuilder]. All methods that can be implemented as listeners will
  /// be.
  ///
  /// Note: You cannot call this method after you have called `builder.build`.
  static void addToBuilderAsListener($protocolBuilder builder, $args) {
    $buildListenerImplementations
    builder.addProtocol(\$protocol);
  }

  /// Builds an object that implements the $originalName protocol. To implement
  /// multiple protocols, use [addToBuilder] or [$protocolBuilder] directly. All
  /// methods that can be implemented as blocking listeners will be.
  ///
  /// If `\$keepIsolateAlive` is true, this protocol will keep this isolate
  /// alive until it is garbage collected by both Dart and ObjC.
  static $name implementAsBlocking($args) {
    final builder = $protocolBuilder(debugName: '$originalName');
    $buildBlockingImplementations
    builder.addProtocol(\$protocol);
    return $name.castFrom(builder.build(keepIsolateAlive: \$keepIsolateAlive));
  }

  /// Adds the implementation of the $originalName protocol to an existing
  /// [$protocolBuilder]. All methods that can be implemented as blocking
  /// listeners will be.
  ///
  /// Note: You cannot call this method after you have called `builder.build`.
  static void addToBuilderAsBlocking($protocolBuilder builder, $args) {
    $buildBlockingImplementations
    builder.addProtocol(\$protocol);
  }
''';
      }

      s.write('''

  $builders
  $listenerBuilders
  $methodFields
}
''');
    }

    return BindingString(
      type: BindingStringType.objcProtocol,
      string: s.toString(),
    );
  }

  String _trampolineAddress(ObjCBlock block) {
    final func = block.protocolTrampoline!.func;
    final type = NativeFunc(
      func.functionType,
    ).getCType(context, writeArgumentNames: false);
    final ffiPrefix = context.libs.prefix(ffiImport);
    return '$ffiPrefix.Native.addressOf<$type>(${func.name}).cast()';
  }

  @override
  BindingString? toObjCBindingString(Writer w) {
    if (generateAsStub) return null;

    final wrapName = context.objCBuiltInFunctions.wrapperName;
    final mainString =
        '''

Protocol* _${wrapName}_$originalName(void) { return @protocol($originalName); }
''';

    return BindingString(
      type: BindingStringType.objcProtocol,
      string: mainString,
    );
  }

  @override
  String getCType(Context context) =>
      PointerType(objCObjectType).getCType(context);

  @override
  String getDartType(Context context) =>
      isObjCImport ? '${context.libs.prefix(objcPkgImport)}.$name' : name;

  @override
  String getNativeType({String varName = ''}) => 'id $varName';

  @override
  String getObjCBlockSignatureType(Context context) => getDartType(context);

  @override
  bool get sameFfiDartAndCType => true;

  @override
  bool get sameDartAndCType => false;

  @override
  bool get sameDartAndFfiDartType => false;

  @override
  String convertDartTypeToFfiDartType(
    Context context,
    String value, {
    required bool objCRetain,
    required bool objCAutorelease,
  }) => ObjCInterface.generateGetId(value, objCRetain, objCAutorelease);

  @override
  String convertFfiDartTypeToDartType(
    Context context,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) => ObjCInterface.generateConstructor(
    getDartType(context),
    value,
    objCRetain,
  );

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

  // Set typeGraphOnly to true to skip iterating methods and other children, and
  // just iterate the DAG of interfaces, categories, and protocols. This is
  // useful for visitors that need to ensure super types are visited first.
  @override
  void visitChildren(Visitor visitor, {bool typeGraphOnly = false}) {
    if (!typeGraphOnly) {
      super.visitChildren(visitor);
      visitor.visit(_protocolPointer);
      visitor.visit(_conformsTo);
      visitor.visit(_conformsToMsgSend);
      visitMethods(visitor);
      visitor.visit(ffiImport);
      visitor.visit(objcPkgImport);
    }
    visitor.visitAll(superProtocols);
  }
}
