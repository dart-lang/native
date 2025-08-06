// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../context.dart';
import '../header_parser/sub_parsers/api_availability.dart';
import '../visitor/ast.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

class ObjCInterface extends BindingType with ObjCMethods {
  @override
  final Context context;
  ObjCInterface? superType;
  bool filled = false;

  final String lookupName;
  late final ObjCInternalGlobal classObject;
  late final ObjCInternalGlobal _isKindOfClass;
  late final ObjCMsgSendFunc _isKindOfClassMsgSend;
  final protocols = <ObjCProtocol>[];
  final categories = <ObjCCategory>[];
  final subtypes = <ObjCInterface>[];
  final ApiAvailability apiAvailability;

  // Filled by ListBindingsVisitation.
  bool generateAsStub = false;

  ObjCInterface({
    super.usr,
    required String super.originalName,
    String? name,
    String? lookupName,
    super.dartDoc,
    required this.apiAvailability,
    required this.context,
  }) : lookupName = lookupName ?? originalName,
       super(
         name:
             context.objCBuiltInFunctions.getBuiltInInterfaceName(
               originalName,
             ) ??
             name ??
             originalName,
       ) {
    classObject = ObjCInternalGlobal(
      '_class_$originalName',
      (Writer w) => '${ObjCBuiltInFunctions.getClass.gen(w)}("$lookupName")',
    );
    _isKindOfClass = context.objCBuiltInFunctions.getSelObject(
      'isKindOfClass:',
    );
    _isKindOfClassMsgSend = context.objCBuiltInFunctions.getMsgSendFunc(
      BooleanType(),
      [
        Parameter(
          name: 'clazz',
          type: PointerType(objCObjectType),
          objCConsumed: false,
        ),
      ],
    );
  }

  void addProtocol(ObjCProtocol? proto) {
    if (proto != null) protocols.add(proto);
  }

  @override
  bool get isObjCImport =>
      context.objCBuiltInFunctions.getBuiltInInterfaceName(originalName) !=
      null;

  @override
  void sort() => sortMethods();

  bool get unavailable => apiAvailability.availability == Availability.none;

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    s.write('\n');
    if (generateAsStub) {
      s.write('''
/// WARNING: $name is a stub. To generate bindings for this class, include
/// $originalName in your config's objc-interfaces list.
///
''');
    }
    s.write(makeDartDoc(dartDoc));

    final versionCheck = apiAvailability.runtimeCheck(
      ObjCBuiltInFunctions.checkOsVersion.gen(w),
      originalName,
    );
    final ctorBody = versionCheck == null ? ';' : ' { $versionCheck }';

    final rawObjType = PointerType(objCObjectType).getCType(w);
    final wrapObjType = ObjCBuiltInFunctions.objectBase.gen(w);
    final protoImpl = protocols.isEmpty
        ? ''
        : 'implements ${protocols.map((p) => p.getDartType(w)).join(', ')} ';

    final superCtor = superType == null ? 'super' : 'super.castFromPointer';
    s.write('''
class $name extends ${superType?.getDartType(w) ?? wrapObjType} $protoImpl{
  $name._($rawObjType pointer, {bool retain = false, bool release = false}) :
      $superCtor(pointer, retain: retain, release: release)$ctorBody

  /// Constructs a [$name] that points to the same underlying object as [other].
  $name.castFrom($wrapObjType other) :
      this._(other.ref.pointer, retain: true, release: true);

  /// Constructs a [$name] that wraps the given raw object pointer.
  $name.castFromPointer($rawObjType other,
      {bool retain = false, bool release = false}) :
      this._(other, retain: retain, release: release);

${generateAsStub ? '' : _generateStaticMethods(w)}
}

''');

    if (!generateAsStub) {
      final extName = w.topLevelUniqueNamer.makeUnique('$name\$Methods');
      s.write('''
extension $extName on $name {
${generateInstanceMethodBindings(w, this)}
}

''');
    }

    return BindingString(
      type: BindingStringType.objcInterface,
      string: s.toString(),
    );
  }

  String _generateStaticMethods(Writer w) {
    final wrapObjType = ObjCBuiltInFunctions.objectBase.gen(w);
    final s = StringBuffer();

    s.write('''
  /// Returns whether [obj] is an instance of [$name].
  static bool isInstance($wrapObjType obj) {
    return ${_isKindOfClassMsgSend.invoke(w, 'obj.ref.pointer', _isKindOfClass.name, [classObject.name])};
  }
''');

    s.write(generateStaticMethodBindings(w, this));

    final newMethod = methods
        .where(
          (ObjCMethod m) =>
              m.isClassMethod &&
              m.family == ObjCMethodFamily.new_ &&
              m.params.isEmpty &&
              m.originalName == 'new',
        )
        .firstOrNull;
    if (newMethod != null && originalName != 'NSString') {
      s.write('''
  /// Returns a new instance of $name constructed with the default `new` method.
  factory $name() => ${newMethod.dartMethodName}();
''');
    }

    return s.toString();
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
  }) => ObjCInterface.generateGetId(value, objCRetain, objCAutorelease);

  static String generateGetId(
    String value,
    bool objCRetain,
    bool objCAutorelease,
  ) => objCRetain
      ? (objCAutorelease
            ? '$value.ref.retainAndAutorelease()'
            : '$value.ref.retainAndReturnPointer()')
      : (objCAutorelease ? '$value.ref.autorelease()' : '$value.ref.pointer');

  @override
  String convertFfiDartTypeToDartType(
    Writer w,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) => ObjCInterface.generateConstructor(getDartType(w), value, objCRetain);

  static String generateConstructor(
    String className,
    String value,
    bool objCRetain,
  ) {
    final ownershipFlags = 'retain: $objCRetain, release: true';
    return '$className.castFromPointer($value, $ownershipFlags)';
  }

  @override
  String? generateRetain(String value) =>
      '(__bridge id)(__bridge_retained void*)($value)';

  @override
  void visit(Visitation visitation) => visitation.visitObjCInterface(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(superType);
    visitor.visit(classObject);
    visitor.visit(_isKindOfClass);
    visitor.visit(_isKindOfClassMsgSend);
    visitor.visitAll(protocols);
    visitor.visitAll(categories);
    visitMethods(visitor);

    // Note: Don't visit subtypes here, because they shouldn't affect transitive
    // inclusion. Including an interface shouldn't auto-include all its
    // subtypes, even as stubs.
  }

  @override
  bool isSupertypeOf(Type other) {
    other = other.typealiasType;
    if (other is ObjCInterface) {
      for (ObjCInterface? t = other; t != null; t = t.superType) {
        if (t == this) return true;
      }
    }
    return false;
  }
}
