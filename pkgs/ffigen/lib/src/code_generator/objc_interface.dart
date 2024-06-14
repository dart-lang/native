// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

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

final _logger = Logger('ffigen.code_generator.objc_interface');

class ObjCInterface extends BindingType {
  ObjCInterface? superType;
  final methods = <String, ObjCMethod>{};
  bool filled = false;

  final String lookupName;
  final ObjCBuiltInFunctions builtInFunctions;
  late final ObjCInternalGlobal _classObject;
  late final ObjCInternalGlobal _isKindOfClass;
  late final ObjCMsgSendFunc _isKindOfClassMsgSend;

  ObjCInterface({
    super.usr,
    required String super.originalName,
    String? name,
    String? lookupName,
    super.dartDoc,
    required this.builtInFunctions,
  })  : lookupName = lookupName ?? originalName,
        super(name: name ?? originalName);

  bool get _isBuiltIn => builtInFunctions.isBuiltInInterface(name);

  @override
  BindingString toBindingString(Writer w) {
    if (_isBuiltIn) {
      return BindingString(type: BindingStringType.objcInterface, string: '');
    }

    String paramsToString(List<ObjCMethodParam> params,
        {required bool isStatic}) {
      final List<String> stringParams = [];

      stringParams.addAll(
          params.map((p) => '${_getConvertedType(p.type, w, name)} ${p.name}'));
      return '(${stringParams.join(", ")})';
    }

    final s = StringBuffer();
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }

    final uniqueNamer =
        UniqueNamer({name, 'pointer'}, parent: w.topLevelUniqueNamer);

    final rawObjType = PointerType(objCObjectType).getCType(w);
    final wrapObjType = ObjCBuiltInFunctions.objectBase.gen(w);

    final superTypeIsInPkgObjc = superType == null;

    // Class declaration.
    s.write('''
class $name extends ${superType?.getDartType(w) ?? wrapObjType} {
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
    for (final m in methods.values) {
      final methodName = m._getDartMethodName(uniqueNamer);
      final isStatic = m.isClass;
      final isStret = m.msgSend!.isStret;

      var returnType = m.returnType;
      var params = m.params;
      if (isStret) {
        params = [ObjCMethodParam(PointerType(returnType), 'stret'), ...params];
        returnType = voidType;
      }

      // The method declaration.
      if (m.dartDoc != null) {
        s.write(makeDartDoc(m.dartDoc!));
      }

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
        if (superType?.methods[m.originalName]?.sameAs(m) ?? false) {
          s.write('@override\n  ');
        }
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

      s.write('  }\n\n');
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

    for (final m in methods.values) {
      m.addDependencies(dependencies, builtInFunctions);
    }

    if (superType != null) {
      superType!.addDependencies(dependencies);
      _copyMethodsFromSuperType();
      _fixNullabilityOfOverriddenMethods();
    }

    for (final m in methods.values) {
      m.addDependencies(dependencies, builtInFunctions);
    }

    builtInFunctions.addDependencies(dependencies);
  }

  void _copyMethodsFromSuperType() {
    // We need to copy certain methods from the super type:
    //  - Class methods, because Dart classes don't inherit static methods.
    //  - Methods that return instancetype, because the subclass's copy of the
    //    method needs to return the subclass, not the super class.
    //    Note: instancetype is only allowed as a return type, not an arg type.
    for (final m in superType!.methods.values) {
      if (m.isClass &&
          !_excludedNSObjectClassMethods.contains(m.originalName)) {
        addMethod(m);
      } else if (_isInstanceType(m.returnType)) {
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
      for (final method in methods.values) {
        final superMethod = superType_.methods[method.originalName];
        if (superMethod != null && !superMethod.isClass && !method.isClass) {
          if (superMethod.returnType.typealiasType is! ObjCNullable &&
              method.returnType.typealiasType is ObjCNullable) {
            superMethod.returnType = ObjCNullable(superMethod.returnType);
          }
          final numArgs = method.params.length < superMethod.params.length
              ? method.params.length
              : superMethod.params.length;
          for (int i = 0; i < numArgs; ++i) {
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

  static bool _isInstanceType(Type type) {
    if (type is ObjCInstanceType) return true;
    final baseType = type.typealiasType;
    return baseType is ObjCNullable && baseType.child is ObjCInstanceType;
  }

  ObjCMethod _maybeReplaceMethod(ObjCMethod? oldMethod, ObjCMethod newMethod) {
    if (oldMethod == null) return newMethod;

    // Typically we ignore duplicate methods. However, property setters and
    // getters are duplicated in the AST. One copy is marked with
    // ObjCMethodKind.propertyGetter/Setter. The other copy is missing
    // important information, and is a plain old instanceMethod. So if the
    // existing method is an instanceMethod, and the new one is a property,
    // override it.
    if (newMethod.isProperty && !oldMethod.isProperty) {
      return newMethod;
    } else if (!newMethod.isProperty && oldMethod.isProperty) {
      // Don't override, but also skip the same method check below.
      return oldMethod;
    }

    // Check the duplicate is the same method.
    if (!newMethod.sameAs(oldMethod)) {
      _logger.severe('Duplicate methods with different signatures: '
          '$originalName.${newMethod.originalName}');
      return newMethod;
    }

    // There's a bug in some Apple APIs where an init method that should return
    // instancetype has a duplicate definition that instead returns id. In that
    // case, use the one that returns instancetype. Note that since instancetype
    // is an alias of id, the sameAs check above passes.
    if (_isInstanceType(newMethod.returnType) &&
        !_isInstanceType(oldMethod.returnType)) {
      return newMethod;
    } else if (!_isInstanceType(newMethod.returnType) &&
        _isInstanceType(oldMethod.returnType)) {
      return oldMethod;
    }

    return newMethod;
  }

  void addMethod(ObjCMethod method) {
    methods[method.originalName] =
        _maybeReplaceMethod(methods[method.originalName], method);
  }

  @override
  String getCType(Writer w) => PointerType(objCObjectType).getCType(w);

  @override
  String getDartType(Writer w) =>
      _isBuiltIn ? '${w.objcPkgPrefix}.$name' : name;

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

  String _getConvertedType(Type type, Writer w, String enclosingClass) {
    if (type is ObjCInstanceType) return enclosingClass;
    final baseType = type.typealiasType;
    if (baseType is ObjCNullable && baseType.child is ObjCInstanceType) {
      return '$enclosingClass?';
    }
    return type.getDartType(w);
  }
}

enum ObjCMethodKind {
  method,
  propertyGetter,
  propertySetter,
}

class ObjCProperty {
  final String originalName;
  String? dartName;

  ObjCProperty(this.originalName);
}

class ObjCMethod {
  final String? dartDoc;
  final String originalName;
  final ObjCProperty? property;
  Type returnType;
  final List<ObjCMethodParam> params;
  final ObjCMethodKind kind;
  final bool isClass;
  bool returnsRetained = false;
  ObjCInternalGlobal? selObject;
  ObjCMsgSendFunc? msgSend;

  ObjCMethod({
    required this.originalName,
    this.property,
    this.dartDoc,
    required this.kind,
    required this.isClass,
    required this.returnType,
    List<ObjCMethodParam>? params_,
  }) : params = params_ ?? [];

  bool get isProperty =>
      kind == ObjCMethodKind.propertyGetter ||
      kind == ObjCMethodKind.propertySetter;

  void addDependencies(
      Set<Binding> dependencies, ObjCBuiltInFunctions builtInFunctions) {
    returnType.addDependencies(dependencies);
    for (final p in params) {
      p.type.addDependencies(dependencies);
    }
    selObject ??= builtInFunctions.getSelObject(originalName)
      ..addDependencies(dependencies);
    msgSend ??= builtInFunctions.getMsgSendFunc(returnType, params)
      ..addDependencies(dependencies);
  }

  String _getDartMethodName(UniqueNamer uniqueNamer) {
    if (property != null) {
      // A getter and a setter are allowed to have the same name, so we can't
      // just run the name through uniqueNamer. Instead they need to share
      // the dartName, which is run through uniqueNamer.
      if (property!.dartName == null) {
        property!.dartName = uniqueNamer.makeUnique(property!.originalName);
      }
      return property!.dartName!;
    }
    // Objective C methods can look like:
    // foo
    // foo:
    // foo:someArgName:
    // So replace all ':' with '_'.
    return uniqueNamer.makeUnique(originalName.replaceAll(":", "_"));
  }

  bool sameAs(ObjCMethod other) {
    if (originalName != other.originalName) return false;
    if (kind != other.kind) return false;
    if (isClass != other.isClass) return false;
    // msgSend is deduped by signature, so this check covers the signature.
    return msgSend == other.msgSend;
  }

  static final _copyRegExp = RegExp('[cC]opy');
  bool get isOwnedReturn =>
      returnsRetained ||
      originalName.startsWith('new') ||
      originalName.startsWith('alloc') ||
      originalName.contains(_copyRegExp);

  @override
  String toString() => '$returnType $originalName(${params.join(', ')})';
}

class ObjCMethodParam {
  Type type;
  final String name;
  ObjCMethodParam(this.type, this.name);

  @override
  String toString() => '$type $name';
}
