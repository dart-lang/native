import '../../_core/interfaces/enum_declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';
import '../../_core/shared/referred_type.dart';
import '../compounds/protocol_declaration.dart';

class RawValueEnumDeclaration<T> implements EnumDeclaration, ObjCAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<RawValueEnumCase<T>> cases;

  @override
  List<GenericType> genericParams;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  @override
  bool hasObjCAnnotation;

  ReferredType rawValueType;

  RawValueEnumDeclaration({
    required this.id,
    required this.name,
    required this.cases,
    required this.genericParams,
    required this.conformedProtocols,
    required this.hasObjCAnnotation,
    required this.rawValueType,
  });
}

class RawValueEnumCase<T> implements EnumCase {
  @override
  String id;

  @override
  String name;

  T rawValue;

  RawValueEnumCase({
    required this.id,
    required this.name,
    required this.rawValue,
  });
}
