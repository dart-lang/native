import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../_core/utils.dart';

String generateClass(ClassDeclaration declaration) {
  final lines = [
    _generateClassHeader(declaration),
    [
      _generateClassWrappedInstance(declaration),
      ..._generateClassProperties(declaration),
      _generateClassInitializer(declaration),
      ..._generateClassMethods(declaration),
    ].join('\n\n').indent(),
    '}',
  ].nonNulls.toList();

  return lines.join('\n');
}

String _generateClassHeader(ClassDeclaration declaration) {
  var header = StringBuffer();

  if (declaration.hasObjCAnnotation) {
    header.write('@objc ');
  }

  header.write('public class ${declaration.name}');

  final superClassAndProtocols = [
    declaration.superClass?.declaration.name,
    ...declaration.conformedProtocols
        .map((protocol) => protocol.declaration.name),
  ];

  if (superClassAndProtocols.isNotEmpty) {
    header.write(": ${superClassAndProtocols.join(", ")}");
  }

  header.write(' {');

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

String? _generateClassInitializer(ClassDeclaration declaration) {
  final initializer = declaration.initializer;
  if (initializer == null) return null;

  return [
    'init(${generateParameters(initializer.params)}) {',
    initializer.statements.join('\n').indent(),
    '}'
  ].join('\n');
}

List<String> _generateClassMethods(ClassDeclaration declaration) {
  return declaration.methods.map(
    (method) {
      var header = StringBuffer();
      if (method.hasObjCAnnotation) {
        header.write('@objc ');
      }

      header.write('func ${method.name}(${generateParameters(method.params)})');

      if (method.returnType != null) {
        header.write(' -> ${method.returnType!.name}');
      }

      header.write(' {');

      return [
        header,
        method.statements.join('\n').indent(),
        '}',
      ].join('\n');
    },
  ).toList();
}

List<String> _generateClassProperties(ClassDeclaration declaration) {
  return declaration.properties.map(
    (property) {
      var header = StringBuffer();
      if (property.hasObjCAnnotation) {
        header.write('@objc ');
      }

      header.write('var ${property.name}: ${property.type.name} {');

      final getterLines = [
        'get {',
        property.getterStatements.join('\n').indent(),
        '}'
      ];

      final setterLines = [
        'set {',
        property.setterStatements.join('\n').indent(),
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
