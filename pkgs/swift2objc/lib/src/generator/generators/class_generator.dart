import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../_core/utils.dart';

String generateClass(ClassDeclaration declaration) {
  return [
    '${_generateClassHeader(declaration)} {',
    [
      _generateClassWrappedInstance(declaration),
      ..._generateClassProperties(declaration),
      ..._generateInitializers(declaration),
      ..._generateClassMethods(declaration),
    ].nonNulls.join('\n\n').indent(),
    '}',
  ].join('\n');
}

String _generateClassHeader(ClassDeclaration declaration) {
  final header = StringBuffer();

  if (declaration.hasObjCAnnotation) {
    header.write('@objc ');
  }

  header.write('public class ${declaration.name}');

  final superClassAndProtocols = [
    declaration.superClass?.declaration.name,
    ...declaration.conformedProtocols
        .map((protocol) => protocol.declaration.name),
  ].nonNulls;

  if (superClassAndProtocols.isNotEmpty) {
    header.write(': ${superClassAndProtocols.join(", ")}');
  }

  return header.toString();
}

String? _generateClassWrappedInstance(ClassDeclaration declaration) {
  final property = declaration.wrappedInstance;

  if (property == null) return null;

  assert(
    property.type is! GenericType,
    "Wrapped instance can't have a generic type",
  );

  return 'var ${property.name}: ${property.type.name}';
}

List<String> _generateInitializers(ClassDeclaration declaration) {
  final initializers = [
    declaration.wrapperInitializer,
    ...declaration.initializers,
  ].nonNulls;

  return initializers.map(
    (initializer) {
      final header = StringBuffer();

      if (initializer.hasObjCAnnotation) {
        header.write('@objc ');
      }

      header.write('init(${generateParameters(initializer.params)})');

      return ['$header {', initializer.statements.join('\n').indent(), '}']
          .join('\n');
    },
  ).toList();
}

List<String> _generateClassMethods(ClassDeclaration declaration) {
  return declaration.methods.map((method) {
    final header = StringBuffer();

    if (method.hasObjCAnnotation) {
      header.write('@objc ');
    }

    header.write(
      'public func ${method.name}(${generateParameters(method.params)})',
    );

    if (method.returnType != null) {
      header.write(' -> ${method.returnType!.name}');
    }

    return [
      '$header {',
      method.statements.join('\n').indent(),
      '}',
    ].join('\n');
  }).toList();
}

List<String> _generateClassProperties(ClassDeclaration declaration) {
  return declaration.properties.map(
    (property) {
      final header = StringBuffer();
      if (property.hasObjCAnnotation) {
        header.write('@objc ');
      }

      header.write('public var ${property.name}: ${property.type.name} {');

      final getterLines = [
        'get {',
        property.getter?.statements.join('\n').indent(),
        '}'
      ];

      final setterLines = [
        'set {',
        property.setter?.statements.join('\n').indent(),
        '}'
      ];

      return [
        header,
        getterLines.join('\n').indent(),
        if (property.hasSetter) setterLines.join('\n').indent(),
        '}',
      ].join('\n');
    },
  ).toList();
}
