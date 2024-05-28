import 'referred_type.dart';

class Parameter {
  String name;
  String? internalName;
  ReferredType type;

  Parameter({
    required this.name,
    required this.internalName,
    required this.type,
  });
}
