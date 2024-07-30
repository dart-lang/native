import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../transform.dart';
import 'unique_namer.dart';

(String wrappedValue, ReferredType wrapperType) generateWrappedValue(
  ReferredType type,
  String valueIdentifier,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  if (type is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  }

  final transformedTypeDeclaration = transformDeclaration(
    (type as DeclaredType).declaration,
    globalNamer,
    transformationMap,
  );

  return (
    '${transformedTypeDeclaration.name}($valueIdentifier)',
    transformedTypeDeclaration.asDeclaredType
  );
}

(String wrappedValue, ReferredType wrapperType) generateUnwrappedValue(
  ReferredType type,
  String valueIdentifier,
) {
  if (type is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  }

  final declaration = (type as DeclaredType).declaration;

  assert(declaration is ClassDeclaration,
      'A wrapped value type can only be a class');

  final wrappedInstance = (declaration as ClassDeclaration).wrappedInstance;

  assert(wrappedInstance != null, 'Class ${declaration.name} is not a wrapper');

  return ('$valueIdentifier.${wrappedInstance!.name}', wrappedInstance.type);
}
