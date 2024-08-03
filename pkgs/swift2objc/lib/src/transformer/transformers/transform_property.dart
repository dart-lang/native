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

List<String> _generateSetterStatemenets(
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
