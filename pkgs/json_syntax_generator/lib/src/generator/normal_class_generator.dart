// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model/class_info.dart';
import 'code_generation_helpers.dart';
import 'property_generator.dart';

class ClassGenerator {
  final NormalClassInfo classInfo;

  ClassGenerator(this.classInfo);

  String generate() {
    final buffer = StringBuffer();
    _generateClass(buffer);
    _generateTaggedUnionExtension(buffer);
    return buffer.toString();
  }

  void _generateClass(StringBuffer buffer) {
    final className = classInfo.name;
    final superclassName = classInfo.superclass?.name ?? 'JsonObject';

    buffer.writeln('''
class $className extends $superclassName {
''');
    buffer.writeln(_generateTag());
    buffer.writeln(_generateJsonFactory());
    buffer.writeln(_generateJsonConstructor());
    buffer.writeln(_generateDefaultConstructor());
    buffer.writeln(_generateSetupMethod());
    buffer.writeln(_generateAccessors());
    buffer.writeln(_generateValidateMethod());
    buffer.writeln(_generateExtraValidationMethod());
    buffer.writeln(_generateToString());
    buffer.writeln('''
}
''');
  }

  /// If this is a tagged union value, expose the tag.
  String _generateTag() {
    if (classInfo.superclass?.visibleTaggedUnion != true) return '';
    final tagProperty = classInfo.superclass!.taggedUnionProperty;
    final tagValue = classInfo.taggedUnionValue;
    return '''
static const ${tagProperty}Value = '$tagValue';
''';
  }

  /// If this is the parent class in a tagged union, generate a factory that
  /// branches to invoke subclass constructors.
  String _generateJsonFactory() {
    if (!classInfo.isTaggedUnion || classInfo.superclass != null) {
      // Not a tagged union, no need to generate a factory.
      return '';
    }

    final className = classInfo.name;
    final factorySubclassReturns = <String>[];
    for (final subclass in classInfo.subclasses) {
      if (subclass.taggedUnionValue != null) {
        factorySubclassReturns.add('''
        if (result.is${subclass.name}) {
          return result.as${subclass.name};
        }''');
      }
    }
    final factorySubclassReturnsString = factorySubclassReturns.join('\n');

    return '''
  factory $className.fromJson(
    Map<String, Object?> json, {
    List<Object> path = const [],
  }) {
    final result = $className._fromJson(json, path: path);
    $factorySubclassReturnsString
    return result;
  }
''';
  }

  String _generateJsonConstructor() {
    final className = classInfo.name;

    if (classInfo.superclass == null) {
      final constructorName =
          classInfo.isTaggedUnion ? '_fromJson' : 'fromJson';
      return '''
  $className.$constructorName(super.json, {
    super.path = const [],
  }) : super.fromJson();
''';
    }

    final superConstructorName =
        classInfo.isTaggedUnion ? '_fromJson' : 'fromJson';
    return '''
  $className.fromJson(super.json, {
    super.path,
  }) : super.$superConstructorName();
''';
  }

  String _generateDefaultConstructor() {
    final parameters = _generateDefaultConstructorParameters();
    final superArguments = _generateDefaultConstructorSuperArguments();
    final setterCalls = _generateSetterCalls();
    final className = classInfo.name;
    final parametersString = wrapBracesIfNotEmpty(parameters.join(', '));
    final superArgumentsString = superArguments.join(',');
    final body = wrapInBracesOrSemicolon(setterCalls.join('\n    '));

    if (classInfo.superclass == null) {
      return '''
  $className($parametersString)
  : super()
    $body
''';
    }

    return '''
  $className($parametersString)
    : super($superArgumentsString) 
    $body
''';
  }

  /// Generates a list of named parameters.
  ///
  /// Alphabetically sorted through this and super parameters.
  ///
  /// Omits the tagged value property for tagged union sub classes.
  List<String> _generateDefaultConstructorParameters() {
    final result = <String>[];
    final superclass = classInfo.superclass;

    final propertyNames = _getAllPropertyNames();
    for (final propertyName in propertyNames) {
      final superClassProperty = superclass?.getProperty(propertyName);
      final thisClassProperty = classInfo.getProperty(propertyName);

      if (superClassProperty != null) {
        if (propertyName != classInfo.superclass?.taggedUnionProperty) {
          if (thisClassProperty != null &&
              superClassProperty.type != thisClassProperty.type) {
            // More specific type on this class so emit normal parameter.
            // Must be passed to super constructor call.
            final dartType = thisClassProperty.type;
            final propertyName = thisClassProperty.name;
            result.add('required $dartType $propertyName');
          } else {
            // Same type on this class, emit super parameter.
            final propertyName = superClassProperty.name;
            result.add('required super.$propertyName');
          }
        }
      } else {
        final dartType = thisClassProperty!.type;
        final propertyName = thisClassProperty.name;
        result.add('required $dartType $propertyName');
      }
    }
    return result;
  }

  /// Generates super constructor calls.
  ///
  /// * For tagged unions, the tagged union value.
  /// * For parameters that have a more specific type in the subclass a simple
  ///   forwarding.
  ///
  /// All other parameters are already set by `super.paramName`.
  List<String> _generateDefaultConstructorSuperArguments() {
    final superclass = classInfo.superclass;
    if (superclass == null) return [];

    final result = <String>[];

    final taggedUnionProperty = superclass.taggedUnionProperty;
    final taggedUnionValue = classInfo.taggedUnionValue;
    if (taggedUnionValue != null && taggedUnionProperty != null) {
      result.add("$taggedUnionProperty: '$taggedUnionValue'");
    }

    final propertyNames = _getAllPropertyNames();
    for (final propertyName in propertyNames) {
      final superClassProperty = superclass.getProperty(propertyName);
      final thisClassProperty = classInfo.getProperty(propertyName);

      if (propertyName != classInfo.superclass?.taggedUnionProperty) {
        if (thisClassProperty != null &&
            superClassProperty != null &&
            superClassProperty.type != thisClassProperty.type) {
          final propertyName = thisClassProperty.name;
          result.add('$propertyName: $propertyName');
        }
      }
    }
    return result;
  }

  /// Generates the setter calls for both [_generateDefaultConstructor] and
  /// [_generateSetupMethod].
  List<String> _generateSetterCalls() {
    final result = <String>[];
    final superclass = classInfo.superclass;
    for (final property in classInfo.properties) {
      final superClassProperty = superclass?.getProperty(property.name);
      if (superClassProperty != null) {
        // This property will be already set in the super constructor.
        // TODO: The parameter in the constructor currently has the super class
        // property type.
        continue;
      }
      if (property.setterPrivate) {
        result.add('_${property.name} = ${property.name};');
      } else {
        result.add('this.${property.name} = ${property.name};');
      }
    }
    if (result.isNotEmpty) {
      result.add('json.sortOnKey();');
    }
    return result;
  }

  String _generateSetupMethod() {
    if (classInfo.superclass == null || classInfo.properties.isEmpty) {
      return '';
    }

    final parameters = _generateSetupParameters();
    final setterCalls = _generateSetterCalls();
    final className = classInfo.name;
    final superclassName = classInfo.superclass!.name;
    final parametersString = wrapBracesIfNotEmpty(parameters.join(', '));
    final setterCallsString = setterCalls.join('\n    ');
    return '''
  /// Setup all fields for [$className] that are not in
  /// [$superclassName].
  void setup ($parametersString) {
    $setterCallsString
  }
''';
  }

  List<String> _generateSetupParameters() {
    final result = <String>[];
    final superclass = classInfo.superclass;

    for (final property in classInfo.properties) {
      final superClassProperty = superclass?.getProperty(property.name);
      if (superClassProperty != null) {
        continue;
      }
      if (superClassProperty == null) {
        final dartType = property.type;
        result.add('required $dartType ${property.name}');
      }
    }
    return result;
  }

  String _generateAccessors() => [
    for (final property in classInfo.properties)
      PropertyGenerator(property).generate(),
  ].join('\n');

  String _generateValidateMethod() {
    final validateCalls = [
      for (final property in classInfo.properties)
        '...${property.validateName}()',
      if (classInfo.extraValidation.isNotEmpty) '..._validateExtraRules()',
    ];
    final validateCallsString = validateCalls.join(',\n');

    return '''
  @override
  List<String> validate() => [
    ...super.validate(),
    $validateCallsString
  ];
''';
  }

  String _generateExtraValidationMethod() {
    if (classInfo.extraValidation.isEmpty) return '';
    final statements =
        classInfo.extraValidation
            .map(_generateExtraValidationStatements)
            .join()
            .trim();
    return '''
  List<String> _validateExtraRules() {
    final result = <String>[];
    $statements
    return result;
  }
''';
  }

  String _generateExtraValidationStatements(
    ConditionallyRequired extraValidationRule,
  ) {
    final path = extraValidationRule.conditionPath;
    final values = extraValidationRule.conditionValues;
    final requiredPath = extraValidationRule.requiredPath;
    final pathString = path.map((e) => "'$e'").join(',');
    final traverseExpression = '_reader.tryTraverse([$pathString])';
    final String conditionExpression;
    if (values.length == 1) {
      conditionExpression = "$traverseExpression == '${values.single}'";
    } else {
      final valuesString = values.map((e) => "'$e'").join(',');
      conditionExpression = '[$valuesString].contains($traverseExpression)';
    }
    if (requiredPath.length == 1) {
      final jsonKey = requiredPath.single;
      return """
    if ($conditionExpression) {
      result.addAll(_reader.validate<Object>('$jsonKey'));
    }
""";
    } else if (requiredPath.length == 2) {
      final jsonKey0 = requiredPath[0];
      final jsonKey1 = requiredPath[1];
      return """
    if ($conditionExpression) {
      final objectErrors = _reader.validate<Map<String, Object?>?>('$jsonKey0');
      result.addAll(objectErrors);
      if (objectErrors.isEmpty) {
        final jsonValue = _reader.get<Map<String, Object?>?>('$jsonKey0');
        if (jsonValue != null) {
          final reader = JsonReader(jsonValue, [...path, '$jsonKey0']);
          result.addAll(reader.validate<Object>('$jsonKey1'));
        }
      }
    }
""";
    } else {
      throw UnimplementedError('Different path lengths not implemented yet.');
    }
  }

  String _generateToString() {
    final className = classInfo.name;
    return '''
  @override
  String toString() => '$className(\$json)';
''';
  }

  void _generateTaggedUnionExtension(StringBuffer buffer) {
    if (!classInfo.isTaggedUnion || classInfo.superclass == null) return;

    final className = classInfo.name;
    final superclassName = classInfo.superclass!.name;
    final taggedUnionValue = classInfo.taggedUnionValue;
    final taggedUnionProperty = classInfo.superclass!.taggedUnionProperty;

    buffer.writeln('''
extension ${className}Extension on $superclassName {
  bool get is$className => $taggedUnionProperty == '$taggedUnionValue';

  $className get as$className => $className.fromJson(json, path: path);
}
''');
  }

  /// Get all property names of this class, including from the super classes.
  ///
  /// Alphabetically sorted.
  List<String> _getAllPropertyNames() {
    final properties = classInfo.properties;
    final superclass = classInfo.superclass;
    return {
        for (final property in properties) property.name,
        if (superclass != null)
          for (final property in superclass.properties) property.name,
      }.toList()
      ..sort();
  }
}
