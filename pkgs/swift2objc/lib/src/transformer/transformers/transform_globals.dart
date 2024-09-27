import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/globals/globals.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';
import 'transform_function.dart';
import 'transform_variable.dart';

ClassDeclaration transformGlobals(
  Globals globals,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {

  final transformedGlobals = ClassDeclaration(
    id: 'globals'.addIdSuffix('wrapper'),
    name: globalNamer.makeUnique('GlobalsWrapper'),
    hasObjCAnnotation: true,
    superClass: BuiltInDeclaration.swiftNSObject.asDeclaredType,
    isWrapper: true,
  );

  transformedGlobals.properties = globals.variables
      .map((variable) => transformGlobalVariable(
            variable,
            globalNamer,
            transformationMap,
          ))
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  transformedGlobals.methods = globals.functions
      .map((function) => transformGlobalFunction(
            function,
            globalNamer,
            transformationMap,
          ))
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  return transformedGlobals;
}
