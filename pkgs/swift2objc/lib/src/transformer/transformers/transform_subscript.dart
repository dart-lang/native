import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/compounds/members/subscript_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'transform_referred_type.dart';

List<Declaration> transformSubscript(
  SubscriptDeclaration original,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  final transformedParams = [
    for (var i = 0; i < original.params.length; ++i)
      _transformParam(i, original.params[i], globalNamer, state),
  ];

  final localNamer = UniqueNamer();
  final resultName = localNamer.makeUnique('result');

  final (wrapperResult, type) = maybeWrapValue(
    original.returnType,
    resultName,
    globalNamer,
    state,
  );

  final isRepresentable =
      !original.isStatic &&
      !original.throws &&
      !original.async &&
      original.params.length == 1 &&
      (original.params[0].type.sameAs(intType) ||
          (original.params[0].type.isObjCRepresentable &&
              original.params[0].type is! OptionalType));

  if (isRepresentable) {
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

    return [transformedSubscript];
  }

  // Not representable as a subscript, so transform into a method.
  final prefix = [
    if (original.throws) 'try',
    if (original.async) 'await',
  ].join(' ');

  final arguments = generateInvocationParams(
    localNamer,
    original.params,
    transformedParams,
  );

  final methodSource = original.isStatic
      ? wrappedClassInstance.type.swiftType
      : wrappedClassInstance.name;

  final getter = MethodDeclaration(
    id: original.id.addIdSuffix('getter'),
    name: 'getValue',
    source: original.source,
    availability: original.availability,
    returnType: type,
    params: transformedParams,
    hasObjCAnnotation: true,
    isStatic: original.isStatic,
    throws: original.throws,
    async: original.async,
    statements: [
      'let $resultName = $prefix $methodSource[$arguments]',
      'return $wrapperResult',
    ],
  );

  if (!original.hasSetter) {
    return [getter];
  }

  final (unwrappedNewValue, _) = maybeUnwrapValue(type, 'newValue');

  final setter = MethodDeclaration(
    id: original.id.addIdSuffix('setter'),
    name: 'setValue',
    source: original.source,
    availability: original.availability,
    returnType: voidType,
    params: [
      ...transformedParams,
      Parameter(name: 'newValue', internalName: null, type: type),
    ],
    hasObjCAnnotation: true,
    isStatic: original.isStatic,
    throws: original.throws,
    async: original.async,
    statements: ['$methodSource[$arguments] = $unwrappedNewValue'],
  );

  return [getter, setter];
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
  final localNamer = UniqueNamer();
  final arguments = generateInvocationParams(
    localNamer,
    original.params,
    transformed.params,
  );

  final (unwrappedNewValue, unwrappedType) = maybeUnwrapValue(
    transformed.returnType,
    'newValue',
  );

  final methodSource = original.isStatic
      ? wrappedClassInstance.type.swiftType
      : wrappedClassInstance.name;

  return ['$methodSource[$arguments] = $unwrappedNewValue'];
}
