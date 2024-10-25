// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

class ObjCInterface extends BindingType with ObjCMethods {
  ObjCInterface? superType;
  bool filled = false;

  final String lookupName;
  late final ObjCInternalGlobal _classObject;
  late final ObjCInternalGlobal _isKindOfClass;
  late final ObjCMsgSendFunc _isKindOfClassMsgSend;
  final protocols = <ObjCProtocol>[];

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
        super(name: name ?? originalName) {
    _classObject = ObjCInternalGlobal('_class_$originalName',
        (Writer w) => '${ObjCBuiltInFunctions.getClass.gen(w)}("$lookupName")');
    _isKindOfClass = builtInFunctions.getSelObject('isKindOfClass:');
    _isKindOfClassMsgSend = builtInFunctions.getMsgSendFunc(BooleanType(), [
      Parameter(
        name: 'clazz',
        type: PointerType(objCObjectType),
        objCConsumed: false,
      )
    ]);
  }

  void addProtocol(ObjCProtocol proto) => protocols.add(proto);

  @override
  bool get isObjCImport => builtInFunctions.isBuiltInInterface(originalName);

  @override
  void sort() => sortMethods();

  @override
  BindingString toBindingString(Writer w) {
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
      final sel = m.selObject.name;
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
        final calloc = '${w.ffiPkgLibraryPrefix}.calloc';
        final sizeOf = '${w.ffiLibraryPrefix}.sizeOf';
        final uint8Type = NativeType(SupportedNativeType.uint8).getCType(w);
        final invoke = m.msgSend!
            .invoke(w, target, sel, msgSendParams, structRetPtr: '_ptr');
        s.write('''
    final _ptr = $calloc<$returnTypeStr>();
    $invoke;
    final _finalizable = _ptr.cast<$uint8Type>().asTypedList(
        $sizeOf<$returnTypeStr>(), finalizer: $calloc.nativeFree);
    return ${w.ffiLibraryPrefix}.Struct.create<$returnTypeStr>(_finalizable);
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

  @override
  void visit(Visitation visitation) => visitation.visitObjCInterface(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(superType);
    visitor.visit(_classObject);
    visitor.visit(_isKindOfClass);
    visitor.visit(_isKindOfClassMsgSend);
    visitor.visitAll(protocols);
    visitMethods(visitor);
  }
}
