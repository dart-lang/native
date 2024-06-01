import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/paramable.dart';
import '../../_core/shared/parameter.dart';
import '../../_core/shared/referred_type.dart';

class Globals {
  List<GlobalFunction> functions;
  List<GlobalValue> values;

  Globals({
    required this.functions,
    required this.values,
  });
}

class GlobalFunction implements Declaration, Paramable {
  @override
  String id;

  @override
  String name;

  @override
  List<Parameter> params;

  DeclaredType returnType;

  GlobalFunction({
    required this.id,
    required this.name,
    required this.params,
    required this.returnType,
  });
}

class GlobalValue implements Declaration {
  @override
  String id;

  @override
  String name;

  DeclaredType type;

  bool isConstant;

  GlobalValue({
    required this.id,
    required this.name,
    required this.type,
    required this.isConstant,
  });
}
