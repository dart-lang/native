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

  bool get _isBuiltIn => builtInFunctions.isBuiltInInterface(originalName);

  @override
  BindingString toBindingString(Writer w) {
    if (_isBuiltIn) {
      return const BindingString(
          type: BindingStringType.objcInterface, string: '');
    }

    String paramsToString(List<ObjCMethodParam> params,
        {required bool isStatic}) {
      final stringParams = <String>[];

      stringParams.addAll(
          params.map((p) => '${_getConvertedType(p.type, w, name)} ${p.name}'));
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
      this._(other.pointer, retain: true, release: true);

  /// Constructs a [$name] that wraps the given raw object pointer.
  $name.castFromPointer($rawObjType other,
      {bool retain = false, bool release = false}) :
      this._(other, retain: retain, release: release);

  /// Returns whether [obj] is an instance of [$name].
  static bool isInstance($wrapObjType obj) {
    return ${_isKindOfClassMsgSend.invoke(
      w,
      'obj.pointer',
      _isKindOfClass.name,
      [_classObject.name],
    )};
  }
''');

    // Methods.
    for (final m in methods) {
      final methodName = m.getDartMethodName(methodNamer);
      final isStatic = m.isClassMethod;
      final isStret = m.msgSend!.isStret;

      var returnType = m.returnType;
      var params = m.params;
      if (isStret) {
        params = [ObjCMethodParam(PointerType(returnType), 'stret'), ...params];
        returnType = voidType;
      }

      // The method declaration.
      s.write('\n  ');
      s.write(makeDartDoc(m.dartDoc ?? m.originalName));
      s.write('  ');
      if (isStatic) {
        s.write('static ');
        s.write(_getConvertedType(returnType, w, name));

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
        s.write(paramsToString(params, isStatic: true));
      } else {
        switch (m.kind) {
          case ObjCMethodKind.method:
            // returnType methodName(...)
            s.write(_getConvertedType(returnType, w, name));
            s.write(' $methodName');
            s.write(paramsToString(params, isStatic: false));
            break;
          case ObjCMethodKind.propertyGetter:
            s.write(_getConvertedType(returnType, w, name));
            if (isStret) {
              // void getMethodName(Pointer<returnType> stret)
              s.write(' get');
              s.write(methodName[0].toUpperCase() + methodName.substring(1));
              s.write(paramsToString(params, isStatic: false));
            } else {
              // returnType get methodName
              s.write(' get $methodName');
            }
            break;
          case ObjCMethodKind.propertySetter:
            // set methodName(...)
            s.write(' set $methodName');
            s.write(paramsToString(params, isStatic: false));
            break;
        }
      }

      s.write(' {\n');

      // Implementation.
      final convertReturn = m.kind != ObjCMethodKind.propertySetter &&
          !returnType.sameDartAndFfiDartType;

      if (returnType != voidType) {
        s.write('    ${convertReturn ? 'final _ret = ' : 'return '}');
      }
      s.write(m.msgSend!.invoke(
          w,
          isStatic ? _classObject.name : 'this.pointer',
          m.selObject!.name,
          m.params.map((p) => p.type
              .convertDartTypeToFfiDartType(w, p.name, objCRetain: false)),
          structRetPtr: 'stret'));
      s.write(';\n');
      if (convertReturn) {
        final result = returnType.convertFfiDartTypeToDartType(
          w,
          '_ret',
          objCRetain: !m.isOwnedReturn,
          objCEnclosingClass: name,
        );
        s.write('    return $result;');
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
    _isKindOfClassMsgSend = builtInFunctions.getMsgSendFunc(
        BooleanType(), [ObjCMethodParam(PointerType(objCObjectType), 'clazz')]);

    addMethodDependencies(dependencies, needMsgSend: true);

    if (superType != null) {
      superType!.addDependencies(dependencies);
      _copyMethodsFromSuperType();
      _fixNullabilityOfOverriddenMethods();

      // Add dependencies for any methods that were added.
      addMethodDependencies(dependencies, needMsgSend: true);
    }

    builtInFunctions.addDependencies(dependencies);
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
  String getNativeType({String varName = ''}) => '$originalName* $varName';

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
  }) =>
      ObjCInterface.generateGetId(value, objCRetain);

  static String generateGetId(String value, bool objCRetain) =>
      objCRetain ? '$value.retainAndReturnPointer()' : '$value.pointer';

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
