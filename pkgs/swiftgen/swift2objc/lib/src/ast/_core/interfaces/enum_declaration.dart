import 'confomingable.dart';
import 'declaration.dart';
import 'genericable.dart';

abstract interface class EnumDeclaration implements Declaration, Genericable, Conformingable {
  abstract List<EnumCase> cases;
}

abstract interface class EnumCase implements Declaration {}