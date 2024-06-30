import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/transformer/transform.dart';
import 'package:swift2objc/src/transformer/transformers/transform_method.dart';

ClassDeclaration transformClass(
  ClassDeclaration originalClass,
  TransformationMap transformationMap,
) {
  final originalClassInstance = ClassPropertyDeclaration(
    id: "${originalClass.id}-wrapper-reference",
    name: "originalInstance",
    type: originalClass.asDeclaredType,
  );
  final transformedClass = ClassDeclaration(
    id: "${originalClass.id}-wrapper",
    name: "${originalClass.name}Wrapper",
    properties: [originalClassInstance],
    hasObjCAnnotation: true,
    superClass: BuiltInDeclarations.NSObject.asDeclaredType,
    isWrapper: true,
    originalInstance: originalClassInstance,
  );

  transformationMap[originalClass] = transformedClass;

  transformedClass.methods = originalClass.methods
      .map((method) => tranformMethod(method, transformationMap))
      .toList();
  return transformedClass;
}
