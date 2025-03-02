import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/compounds/protocol_declaration.dart';
import '../_core/utils.dart';

List<String> generateProtocol(ProtocolDeclaration declaration) {
  return [
    '${_generateProtocolHeader(declaration)} {',
    ...<String>[
      ..._generateProtocolProperties(declaration),
      ..._generateInitializers(declaration),
      ..._generateProtocolMethods(declaration)
    ].nonNulls.indent(),
    '}\n',
  ];
}

String _generateProtocolHeader(ProtocolDeclaration declaration) {
  final header = StringBuffer();

  if (declaration.hasObjCAnnotation) {
    header.write('@objc ');
  }

  header.write('public protocol ${declaration.name}');

  final superClassAndProtocols = [
    ...declaration.conformedProtocols
        .map((protocol) => protocol.declaration.name),
  ].nonNulls;

  if (superClassAndProtocols.isNotEmpty) {
    header.write(': ${superClassAndProtocols.join(", ")}');
  }

  return header.toString();
}

List<String> _generateProtocolMethods(ProtocolDeclaration declaration) => [
      for (final method in declaration.methods)
        ..._generateProtocolMethod(method)
    ];

List<String> _generateProtocolMethod(MethodDeclaration method) {
  final header = StringBuffer();

  if (method.hasObjCAnnotation) {
    header.write('@objc ');
  }

  if (method.isStatic) {
    header.write('static ');
  }

  // if (method.isOverriding) {
  //   header.write('override ');
  // }

  header.write(
    'func ${method.name}(${generateParameters(method.params)}) ',
  );

  header.write(generateAnnotations(method));

  if (!method.returnType.sameAs(voidType)) {
    header.write('-> ${method.returnType.swiftType} ');
  }

  return ['$header'];
}

List<String> _generateProtocolProperties(ProtocolDeclaration declaration) => [
      for (final property in declaration.properties)
        ..._generateProtocolProperty(property),
    ];

List<String> _generateProtocolProperty(PropertyDeclaration property) {
  final header = StringBuffer();

  if (property.hasObjCAnnotation) {
    header.write('@objc ');
  }

  if (property.isStatic) {
    header.write('static ');
  }

  // TODO: Getters work differently
  header.write(property.isConstant ? 'let' : 'var');
  header.write(' ${property.name}: ${property.type.swiftType}');
  header.write(' { ${[
    if (property.getter != null) 'get',
    if (property.setter != null) 'set'
  ].join(' ')} }');

  return [
    header.toString(),
  ];
}

List<String> _generateInitializers(ProtocolDeclaration declaration) {
  final initializers = [
    ...declaration.initializers,
  ].nonNulls;
  return [for (final init in initializers) ..._generateInitializer(init)];
}

List<String> _generateInitializer(InitializerDeclaration initializer) {
  final header = StringBuffer();

  if (initializer.hasObjCAnnotation) {
    header.write('@objc ');
  }

  header.write('init');

  if (initializer.isFailable) {
    header.write('?');
  }

  header.write('(${generateParameters(initializer.params)})');

  return [
    '$header ${generateAnnotations(initializer)}',
  ];
}
