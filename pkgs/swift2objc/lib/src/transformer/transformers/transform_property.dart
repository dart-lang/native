import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'transform_referred_type.dart';

PropertyDeclaration transformProperty(
  PropertyDeclaration originalProperty,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final transformedType = transformReferredType(
    originalProperty.type,
    globalNamer,
    transformationMap,
  );

  final transformedProperty = PropertyDeclaration(
    id: originalProperty.id,
    name: originalProperty.name,
    hasSetter: originalProperty.hasSetter,
    type: transformedType,
    hasObjCAnnotation: true,
  );

  final getterStatements = _generateGetterStatements(
    originalProperty,
    wrappedClassInstance,
    transformedProperty,
    globalNamer,
    transformationMap,
  );
  transformedProperty.getter = PropertyEncapsulation(getterStatements);

  if (originalProperty.hasSetter) {
    final setterStatements = _generateSetterStatements(
      originalProperty,
      wrappedClassInstance,
      transformedProperty,
      globalNamer,
      transformationMap,
    );
    transformedProperty.setter = PropertyEncapsulation(setterStatements);
  }

  return transformedProperty;
}

List<String> _generateGetterStatements(
  PropertyDeclaration originalProperty,
  PropertyDeclaration wrappedClassInstance,
  PropertyDeclaration transformedProperty,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final wrappedInstanceProperty =
      '${wrappedClassInstance.name}.${originalProperty.name}';

  final (wrappedValue, wrapperType) = maybeWrapValue(
    originalProperty.type,
    wrappedInstanceProperty,
    globalNamer,
    transformationMap,
  );

  assert(wrapperType.id == transformedProperty.type.id);

  return [wrappedValue];
}

List<String> _generateSetterStatements(
  PropertyDeclaration originalProperty,
  PropertyDeclaration wrappedClassInstance,
  PropertyDeclaration transformedProperty,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final wrappedInstanceProperty =
      '${wrappedClassInstance.name}.${originalProperty.name}';

  final (unwrappedValue, unwrappedType) = maybeUnwrapValue(
    transformedProperty.type,
    'newValue',
  );

  assert(unwrappedType.id == originalProperty.type.id);

  return ['$wrappedInstanceProperty = $unwrappedValue'];
}
