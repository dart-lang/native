import 'package:swift2objc/src/ast/_core/shared/parameter.dart';
import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/transformer/transform.dart';
import 'package:swift2objc/src/transformer/transformers/transform_referred_type.dart';

ClassMethodDeclaration tranformMethod(
  ClassMethodDeclaration originalMethod,
  TransformationMap transformationMap,
) {
  final transformedParams = originalMethod.params
      .map((param) => _tranformParamter(param, transformationMap))
      .toList();

  final transformedMethod = ClassMethodDeclaration(
    id: originalMethod.id,
    name: originalMethod.name,
    returnType: transformReferredType(
      originalMethod.returnType,
      transformationMap,
    ),
    params: transformedParams,
    hasObjCAnnotation: true,
  );

  transformedMethod.statements = <String>[
    _generateMethodCall(originalMethod, transformedMethod)
  ];

  transformationMap[originalMethod] = transformedMethod;

  return transformedMethod;
}

String _generateMethodCall(
  ClassMethodDeclaration originalMethod,
  ClassMethodDeclaration transformedMethod,
) {
  final arguments = <String>[];

  for (var i = 0; i < originalMethod.params.length; i++) {
    final originalParam = originalMethod.params[i];
    final transformedParam = transformedMethod.params[i];

    String methodCallArg =
        "${originalParam.name}: ${transformedParam.internalName ?? transformedParam.name}";

    final transformedType = transformedParam.type;
    if (transformedType is DeclaredType) {
      final typeDeclaration = transformedType.declaration;
      if (typeDeclaration is ClassDeclaration && typeDeclaration.isWrapper) {
        methodCallArg += ".${typeDeclaration.originalInstance!.name}";
      }
    }

    arguments.add(methodCallArg);
  }

  return "originalInstance.${originalMethod.name}(${arguments.join(", ")})";
}

Parameter _tranformParamter(
  Parameter originalParameter,
  TransformationMap transformationMap,
) {
  return Parameter(
    name: originalParameter.name,
    internalName: originalParameter.internalName,
    type: transformReferredType(
      originalParameter.type,
      transformationMap,
    ),
  );
}
