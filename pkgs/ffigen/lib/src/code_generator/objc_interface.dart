// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

// Class methods defined on NSObject that we don't want to copy to child objects
// by default.
const _excludedNSObjectClassMethods = {
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
  'setVersion:',
  'superclass',
  'version',
};

class ObjCInterface extends BindingType with ObjCMethods {
  ObjCInterface? superType;
  bool filled = false;

  final String lookupName;
  late final ObjCInternalGlobal _classObject;
  late final ObjCInternalGlobal _isKindOfClass;
  late final ObjCMsgSendFunc _isKindOfClassMsgSend;
  final _protocols = <ObjCProtocol>[];

  @override
  final ObjCBuiltInFunctions builtInFunctions;

  ObjCInterface({
    super.usr,
    required String super.originalName,
    String? name,
    String? lookupName,
    super.dartDoc,
    required this.builtInFunctions,
  })  : lookupName = lookupName ?? originalName,
        super(name: name ?? originalName);

  void addProtocol(ObjCProtocol proto) => _protocols.add(proto);
  bool get _isBuiltIn => builtInFunctions.isBuiltInInterface(originalName);

  @override
  BindingString toBindingString(Writer w) {
    if (_isBuiltIn) {
      return const BindingString(
          type: BindingStringType.objcInterface, string: '');
    }

    String paramsToString(List<Parameter> params) {
      final stringParams = <String>[
        for (final p in params)
          '${_getConvertedType(p.type, w, name)} ${p.name}',
      ];
      return '(${stringParams.join(", ")})';
    }

    final s = StringBuffer();
    s.write('\n');
    s.write(makeDartDoc(dartDoc ?? originalName));

    final methodNamer = createMethodRenamer(w);

    final rawObjType = PointerType(objCObjectType).getCType(w);
    final wrapObjType = ObjCBuiltInFunctions.objectBase.gen(w);

    final superTypeIsInPkgObjc = superType == null;

    // Class declaration.
    s.write('''class $name extends ${superType?.getDartType(w) ?? wrapObjType} {
  $name._($rawObjType pointer,
      {bool retain = false, bool release = false}) :
          ${superTypeIsInPkgObjc ? 'super' : 'super.castFromPointer'}
              (pointer, retain: retain, release: release);

  /// Constructs a [$name] that points to the same underlying object as [other].
  $name.castFrom($wrapObjType other) :
      this._(other.ref.pointer, retain: true, release: true);

  /// Constructs a [$name] that wraps the given raw object pointer.
  $name.castFromPointer($rawObjType other,
      {bool retain = false, bool release = false}) :
      this._(other, retain: retain, release: release);

  /// Returns whether [obj] is an instance of [$name].
  static bool isInstance($wrapObjType obj) {
    return ${_isKindOfClassMsgSend.invoke(
      w,
      'obj.ref.pointer',
      _isKindOfClass.name,
      [_classObject.name],
    )};
  }
''');

    // Methods.
    for (final m in methods) {
      final methodName = m.getDartMethodName(methodNamer);
      final isStatic = m.isClassMethod;

      final returnType = m.returnType;
      final returnTypeStr = _getConvertedType(returnType, w, name);
      final params = m.params;

      // The method declaration.
      s.write('\n  ');
      s.write(makeDartDoc(m.dartDoc ?? m.originalName));
      s.write('  ');
      if (isStatic) {
        s.write('static $returnTypeStr');

        switch (m.kind) {
          case ObjCMethodKind.method:
            // static returnType methodName(...)
            s.write(' $methodName');
            break;
          case ObjCMethodKind.propertyGetter:
            // static returnType getMethodName()
            s.write(' get');
            s.write(methodName[0].toUpperCase() + methodName.substring(1));
            break;
          case ObjCMethodKind.propertySetter:
            // static void setMethodName(...)
            s.write(' set');
            s.write(methodName[0].toUpperCase() + methodName.substring(1));
            break;
        }
        s.write(paramsToString(params));
      } else {
        switch (m.kind) {
          case ObjCMethodKind.method:
            // returnType methodName(...)
            s.write('$returnTypeStr $methodName');
            s.write(paramsToString(params));
            break;
          case ObjCMethodKind.propertyGetter:
            // returnType get methodName
            s.write('$returnTypeStr get $methodName');
            break;
          case ObjCMethodKind.propertySetter:
            // set methodName(...)
            s.write(' set $methodName');
            s.write(paramsToString(params));
            break;
        }
      }

      s.write(' {\n');

      // Implementation.
      final sel = m.selObject!.name;
      if (m.isOptional) {
        s.write('''
    if (!${ObjCBuiltInFunctions.respondsToSelector.gen(w)}(ref.pointer, $sel)) {
      throw ${ObjCBuiltInFunctions.unimplementedOptionalMethodException.gen(w)}(
          '$originalName', '${m.originalName}');
    }
''');
      }
      final convertReturn = m.kind != ObjCMethodKind.propertySetter &&
          !returnType.sameDartAndFfiDartType;

      final target = isStatic
          ? _classObject.name
          : convertDartTypeToFfiDartType(
              w,
              'this',
              objCRetain: m.consumesSelf,
              objCAutorelease: false,
            );
      final msgSendParams =
          m.params.map((p) => p.type.convertDartTypeToFfiDartType(
                w,
                p.name,
                objCRetain: p.objCConsumed,
                objCAutorelease: false,
              ));
      if (m.msgSend!.isStret) {
        assert(!convertReturn);
        final malloc = ObjCBuiltInFunctions.malloc.gen(w);
        final free = ObjCBuiltInFunctions.free.gen(w);
        final sizeOf = '${w.ffiLibraryPrefix}.sizeOf';
        final freeFnType =
            NativeFunc(FunctionType(returnType: voidType, parameters: [
          Parameter(
            type: PointerType(voidType),
            objCConsumed: false,
          )
        ])).getCType(w);
        final uint8Type = NativeType(SupportedNativeType.uint8).getCType(w);
        final finalizer =
            '${w.ffiLibraryPrefix}.Native.addressOf<$freeFnType>($free)';
        final invoke = m.msgSend!.invoke(w, target, sel, msgSendParams,
            structRetPtr: '_ptr');
        s.write('''
    final _ptr = $malloc($sizeOf<$returnTypeStr>()).cast<$returnTypeStr>();
    final _data = _ptr.cast<$uint8Type>().asTypedList(
        $sizeOf<$returnTypeStr>(), finalizer: $finalizer);
    $invoke;
    return ${w.ffiLibraryPrefix}.Struct.create<$returnTypeStr>(_data);
''');
      } else {
        if (returnType != voidType) {
          s.write('    ${convertReturn ? 'final _ret = ' : 'return '}');
        }
        s.write(m.msgSend!.invoke(w, target, sel, msgSendParams));
        s.write(';\n');
        if (convertReturn) {
          final result = returnType.convertFfiDartTypeToDartType(
            w,
            '_ret',
            objCRetain: !m.returnsRetained,
            objCEnclosingClass: name,
          );
          s.write('    return $result;');
        }
      }

      s.write('\n  }\n');
    }

    s.write('}\n\n');

    return BindingString(
        type: BindingStringType.objcInterface, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this) || _isBuiltIn) return;
    dependencies.add(this);

    _classObject = ObjCInternalGlobal('_class_$originalName',
        (Writer w) => '${ObjCBuiltInFunctions.getClass.gen(w)}("$lookupName")')
      ..addDependencies(dependencies);
    _isKindOfClass = builtInFunctions.getSelObject('isKindOfClass:');
    _isKindOfClassMsgSend = builtInFunctions.getMsgSendFunc(BooleanType(), [
      Parameter(
        name: 'clazz',
        type: PointerType(objCObjectType),
        objCConsumed: false,
      )
    ]);

    addMethodDependencies(dependencies, needMsgSend: true);

    if (superType != null) {
      superType!.addDependencies(dependencies);
      _copyMethodsFromSuperType();
      _fixNullabilityOfOverriddenMethods();
    }

    for (final proto in _protocols) {
      proto.addDependencies(dependencies);
      for (final m in proto.methods) {
        addMethod(m);
      }
    }

    // Add dependencies for any methods that were added.
    addMethodDependencies(dependencies, needMsgSend: true);
  }

  void _copyMethodsFromSuperType() {
    // We need to copy certain methods from the super type:
    //  - Class methods, because Dart classes don't inherit static methods.
    //  - Methods that return instancetype, because the subclass's copy of the
    //    method needs to return the subclass, not the super class.
    //    Note: instancetype is only allowed as a return type, not an arg type.
    for (final m in superType!.methods) {
      if (m.isClassMethod &&
          !_excludedNSObjectClassMethods.contains(m.originalName)) {
        addMethod(m);
      } else if (ObjCBuiltInFunctions.isInstanceType(m.returnType)) {
        addMethod(m);
      }
    }
  }

  void _fixNullabilityOfOverriddenMethods() {
    // ObjC ignores nullability when deciding if an override for an inherited
    // method is valid. But in Dart it's invalid to override a method and change
    // it's return type from non-null to nullable, or its arg type from nullable
    // to non-null. So in these cases we have to make the non-null type
    // nullable, to avoid Dart compile errors.
    var superType_ = superType;
    while (superType_ != null) {
      for (final method in methods) {
        final superMethod = superType_.getMethod(method.originalName);
        if (superMethod != null &&
            !superMethod.isClassMethod &&
            !method.isClassMethod) {
          if (superMethod.returnType.typealiasType is! ObjCNullable &&
              method.returnType.typealiasType is ObjCNullable) {
            superMethod.returnType = ObjCNullable(superMethod.returnType);
          }
          final numArgs = method.params.length < superMethod.params.length
              ? method.params.length
              : superMethod.params.length;
          for (var i = 0; i < numArgs; ++i) {
            final param = method.params[i];
            final superParam = superMethod.params[i];
            if (superParam.type.typealiasType is ObjCNullable &&
                param.type.typealiasType is! ObjCNullable) {
              param.type = ObjCNullable(param.type);
            }
          }
        }
      }
      superType_ = superType_.superType;
    }
  }

  @override
  String getCType(Writer w) => PointerType(objCObjectType).getCType(w);

  @override
  String getDartType(Writer w) =>
      _isBuiltIn ? '${w.objcPkgPrefix}.$name' : name;

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

  static String generateGetId(
          String value, bool objCRetain, bool objCAutorelease) =>
      objCRetain
          ? (objCAutorelease
              ? '$value.ref.retainAndAutorelease()'
              : '$value.ref.retainAndReturnPointer()')
          : (objCAutorelease
              ? '$value.ref.autorelease()'
              : '$value.ref.pointer');

  @override
  String convertFfiDartTypeToDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) =>
      ObjCInterface.generateConstructor(getDartType(w), value, objCRetain);

  static String generateConstructor(
    String className,
    String value,
    bool objCRetain,
  ) {
    final ownershipFlags = 'retain: $objCRetain, release: true';
    return '$className.castFromPointer($value, $ownershipFlags)';
  }

  @override
  String? generateRetain(String value) => 'objc_retain($value)';

  String _getConvertedType(Type type, Writer w, String enclosingClass) {
    if (type is ObjCInstanceType) return enclosingClass;
    final baseType = type.typealiasType;
    if (baseType is ObjCNullable && baseType.child is ObjCInstanceType) {
      return '$enclosingClass?';
    }
    return type.getDartType(w);
  }
}
