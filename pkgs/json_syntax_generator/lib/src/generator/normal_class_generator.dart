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
    final className = classInfo.name;
    final superclass = classInfo.superclass;
    final superclassName = superclass?.name;
    final properties = classInfo.properties;
    final identifyingSubtype = classInfo.taggedUnionKey;

    final constructorParams = <String>[];
    final setupParams = <String>[];
    final constructorSetterCalls = <String>[];
    final accessors = <String>[];
    final superParams = <String>[];

    final propertyNames =
        {
            for (final property in properties) property.name,
            if (superclass != null)
              for (final property in superclass.properties) property.name,
          }.toList()
          ..sort();
    for (final propertyName in propertyNames) {
      final superClassProperty = superclass?.getProperty(propertyName);
      final thisClassProperty = classInfo.getProperty(propertyName);
      final property = superClassProperty ?? thisClassProperty!;
      if (superClassProperty != null) {
        if (identifyingSubtype == null) {
          constructorParams.add(
            '${property.isRequired ? 'required ' : ''}super.${property.name}',
          );
        } else {
          superParams.add("type: '$identifyingSubtype'");
        }
      } else {
        final dartType = property.type;
        constructorParams.add(
          '${property.isRequired ? 'required ' : ''}$dartType ${property.name}',
        );
        setupParams.add(
          '${property.isRequired ? 'required' : ''} $dartType ${property.name}',
        );
        if (property.setterPrivate) {
          constructorSetterCalls.add('_${property.name} = ${property.name};');
        } else {
          constructorSetterCalls.add(
            'this.${property.name} = ${property.name};',
          );
        }
      }
      if (thisClassProperty != null) {
        accessors.add(PropertyGenerator(thisClassProperty).generate());
      }
    }

    if (constructorSetterCalls.isNotEmpty) {
      constructorSetterCalls.add('json.sortOnKey();');
    }

    if (superclass != null) {
      buffer.writeln('''
class $className extends $superclassName {
  $className.fromJson(super.json) : super.fromJson();

  $className(${wrapBracesIfNotEmpty(constructorParams.join(', '))})
    : super(${superParams.join(',')}) 
    ${wrapInBracesOrSemicolon(constructorSetterCalls.join('\n    '))}
''');
      if (setupParams.isNotEmpty) {
        buffer.writeln('''
  /// Setup all fields for [$className] that are not in
  /// [$superclassName].
  void setup (
    ${wrapBracesIfNotEmpty(setupParams.join(','))}
  ) {
    ${constructorSetterCalls.join('\n')}
  }
''');
      }

      buffer.writeln('''
  ${accessors.join('\n')}

  @override
  String toString() => '$className(\$json)';
}
''');
    } else {
      buffer.writeln('''
class $className {
  final Map<String, Object?> json;

  $className.fromJson(this.json);

  $className(${wrapBracesIfNotEmpty(constructorParams.join(', '))}) : json = {} {
    ${constructorSetterCalls.join('\n    ')}
  }

  ${accessors.join('\n')}

  @override
  String toString() => '$className(\$json)';
}
''');
    }

    if (identifyingSubtype != null) {
      buffer.writeln('''
extension ${className}Extension on $superclassName {
  bool get is$className => type == '$identifyingSubtype';

  $className get as$className => $className.fromJson(json);
}
''');
    }

    return buffer.toString();
  }
}
