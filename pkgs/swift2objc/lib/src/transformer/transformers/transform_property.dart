import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';
import 'transform_referred_type.dart';

ClassPropertyDeclaration transformProperty(
  ClassPropertyDeclaration originalProperty,
  ClassPropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final transformedType = transformReferredType(
    originalProperty.type,
    globalNamer,
    transformationMap,
  );

  final transformedProperty = ClassPropertyDeclaration(
    id: originalProperty.id,
    name: originalProperty.name,
    hasSetter: originalProperty.hasSetter,
    type: transformedType,
    hasObjCAnnotation: true,
  );

  transformedProperty.getterStatements = _generateGetterStatemenets(
    originalProperty,
    wrappedClassInstance,
    transformedProperty,
    globalNamer,
    transformationMap,
  );

  if (originalProperty.hasSetter) {
    transformedProperty.setterStatements = _generateSetterStatemenets(
      originalProperty,
      wrappedClassInstance,
      transformedProperty,
      globalNamer,
      transformationMap,
    );
  }

  return transformedProperty;
}

List<String> _generateGetterStatemenets(
  ClassPropertyDeclaration originalProperty,
  ClassPropertyDeclaration wrappedClassInstance,
  ClassPropertyDeclaration transformedProperty,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final wrappedInstanceProperty =
      '${wrappedClassInstance.name}.${originalProperty.name}';

  if (originalProperty.type.isObjCRepresentable) {
    assert(originalProperty.type.id == transformedProperty.type.id);
    return [wrappedInstanceProperty];
  }

  if (originalProperty.type is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  }

  final transformedTypeDeclaration = transformDeclaration(
    (originalProperty.type as DeclaredType).declaration,
    globalNamer,
    transformationMap,
  );

  assert(transformedTypeDeclaration.id == transformedProperty.type.id);

  return ['${transformedTypeDeclaration.name}($wrappedInstanceProperty)'];
}

List<String> _generateSetterStatemenets(
  ClassPropertyDeclaration originalProperty,
  ClassPropertyDeclaration wrappedClassInstance,
  ClassPropertyDeclaration transformedProperty,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final wrappedInstanceProperty =
      '${wrappedClassInstance.name}.${originalProperty.name}';

  if (originalProperty.type.isObjCRepresentable) {
    assert(originalProperty.type.id == transformedProperty.type.id);
    return ['$wrappedInstanceProperty = newValue'];
  }

  if (originalProperty.type is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  }

  final transformedTypeDeclaration = transformDeclaration(
    (originalProperty.type as DeclaredType).declaration,
    globalNamer,
    transformationMap,
  );

  assert(transformedTypeDeclaration.id == transformedProperty.type.id);

  return [
    '$wrappedInstanceProperty = ${transformedTypeDeclaration.name}(newValue)',
  ];
}
