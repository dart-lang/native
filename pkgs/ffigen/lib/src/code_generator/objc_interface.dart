// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
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

class ObjCInterface extends BindingType with ObjCMethods, HasLocalScope {
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
      () => '${ObjCBuiltInFunctions.getClass.gen(context)}("$lookupName")',
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

  bool get unavailable => apiAvailability.availability == Availability.none;

  @override
  BindingString toBindingString(Writer w) {
    final context = w.context;
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
      ObjCBuiltInFunctions.checkOsVersion.gen(context),
      originalName,
    );
    final ctorBody = versionCheck == null ? ';' : ' { $versionCheck }';

    final rawObjType = PointerType(objCObjectType).getCType(context);
    final wrapObjType = ObjCBuiltInFunctions.objectBase.gen(context);
    final protos = [
      wrapObjType,
      ...[superType, ...protocols].nonNulls.map((p) => p.getDartType(context)),
    ];

    s.write('''
extension type $name.castFrom($wrapObjType _\$) implements ${protos.join(',')} {
  /// Constructs a [$name] that wraps the given raw object pointer.
  $name.castFromPointer($rawObjType other,
      {bool retain = false, bool release = false}) :
          _\$ = $wrapObjType(other, retain: retain, release: release)$ctorBody

${generateAsStub ? '' : _generateStaticMethods(w)}
}

''');

    if (!generateAsStub) {
      s.write('''
extension $name\$Methods on $name {
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
    final context = w.context;
    final wrapObjType = ObjCBuiltInFunctions.objectBase.gen(context);
    final s = StringBuffer();

    s.write('''
  /// Returns whether [obj] is an instance of [$name].
  static bool isInstance($wrapObjType obj) {
    return ${_isKindOfClassMsgSend.invoke(context, 'obj.ref.pointer', _isKindOfClass.name, [classObject.name])};
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
  $name() : this.castFrom(${newMethod.name}()._\$);
''');
    }

    return s.toString();
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
    Context context,
    String value, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) => ObjCInterface.generateConstructor(
    getDartType(context),
    value,
    objCRetain,
  );

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

  // Set typeGraphOnly to true to skip iterating methods and other children, and
  // just iterate the DAG of interfaces, categories, and protocols. This is
  // useful for visitors that need to ensure super types are visited first.
  @override
  void visitChildren(Visitor visitor, {bool typeGraphOnly = false}) {
    if (!typeGraphOnly) {
      super.visitChildren(visitor);
      visitor.visit(classObject);
      visitor.visit(_isKindOfClass);
      visitor.visit(_isKindOfClassMsgSend);
      visitMethods(visitor);
      visitor.visit(objcPkgImport);

      // In the type DAG, categories link to their parent interface, not the
      // other way around. So don't iterate these categories as part of the DAG.
      visitor.visitAll(categories);
    }

    visitor.visit(superType);
    visitor.visitAll(protocols);

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
