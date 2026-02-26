import '../../ast/_core/shared/parameter.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/compounds/members/subscript_declaration.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'transform_referred_type.dart';

SubscriptDeclaration transformSubscript(
  SubscriptDeclaration original,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  final transformedParams = [
    for (var i = 0; i < original.params.length; ++i)
      _transformParam(i, original.params[i], globalNamer, state),
  ];

  // Transform return type (which is the type of the value being accessed/set)
  final localNamer = UniqueNamer();
  final resultName = localNamer.makeUnique('result');

  // We wrap the result of GETTER.
  final (wrapperResult, type) = maybeWrapValue(
    original.returnType,
    resultName,
    globalNamer,
    state,
  );

  final transformedSubscript = SubscriptDeclaration(
    id: original.id,
    source: original.source,
    availability: original.availability,
    returnType: type,
    params: transformedParams,
    hasObjCAnnotation: true,
    isStatic: original.isStatic,
    throws: original.throws,
    async: original.async,
    mutating: original.mutating,
    hasSetter: original.hasSetter,
  );

  // Generate Getter
  transformedSubscript.getter = PropertyStatements(
    _generateGetterStatements(
      original,
      transformedSubscript,
      wrappedClassInstance,
      globalNamer,
      localNamer,
      resultName,
      wrapperResult,
    ),
  );

  // Generate Setter if needed
  if (original.hasSetter) {
    transformedSubscript.setter = PropertyStatements(
      _generateSetterStatements(
        original,
        transformedSubscript,
        wrappedClassInstance,
        globalNamer,
      ),
    );
  }

  return transformedSubscript;
}

Parameter _transformParam(
  int index,
  Parameter p,
  UniqueNamer globalNamer,
  TransformationState state,
) => Parameter(
  name: p.name.isEmpty ? '_' : p.name,
  internalName: p.name.isEmpty && p.internalName == null
      ? 'arg$index'
      : p.internalName,
  type: transformReferredType(p.type, globalNamer, state),
);

List<String> _generateGetterStatements(
  SubscriptDeclaration original,
  SubscriptDeclaration transformed,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  UniqueNamer localNamer,
  String resultName,
  String wrappedResult,
) {
  // Generate invocation params string (unwrapping wrapper types)
  final arguments = generateInvocationParams(
    localNamer,
    original.params,
    transformed.params,
  );

  final methodSource = original.isStatic
      ? wrappedClassInstance.type.swiftType
      : wrappedClassInstance.name;

  final call = '$methodSource[$arguments]';

  return ['let $resultName = $call', 'return $wrappedResult'];
}

List<String> _generateSetterStatements(
  SubscriptDeclaration original,
  SubscriptDeclaration transformed,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
) {
  // For setter, we need to unwrap 'newValue'.
  // 'newValue' is available in set block.
  // transformed type of 'newValue' matches transformed return type.

  final localNamer = UniqueNamer();
  // Unwrap params first
  final arguments = generateInvocationParams(
    localNamer,
    original.params,
    transformed.params,
  );

  // Unwrap 'newValue'
  final (unwrappedNewValue, unwrappedType) = maybeUnwrapValue(
    transformed.returnType,
    'newValue',
  );
  // assert(unwrappedType.sameAs(original.returnType)); // might fail if generic logic differs slightly?

  final methodSource = original.isStatic
      ? wrappedClassInstance.type.swiftType
      : wrappedClassInstance.name;

  return ['$methodSource[$arguments] = $unwrappedNewValue'];
}
