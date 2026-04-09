// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:test_case_selector/test_case_selector.dart';

enum TopLevelKind { class_, interface, enum_, record }

enum Member { field, method, constructor, initializer }

enum NestedKind { none, class_, interface, enum_, record }

enum TopLevelModifier { none, sealed, final_, static_ }

enum MemberModifier {
  none,
  static_,
  abstract_,
  default_,
  synchronized,
  throws,
  transient,
  volatile,
  native
}

enum ParamCount { zero, one, two }

enum MemberName { any, getFoo, setFoo, isFoo }

enum Inheritance {
  none,
  extends_,
  implements_,
  multipleImplements,
  extendsGenericSpecialized,
  extendsGenericUnspecialized,
  diamond,
  complexDag
}

enum Generics { none, oneParam, twoParams, upperBound, lowerBound, wildcard }

enum MemberGenerics { none, oneParam, twoParams, upperBound }

enum TypeKind {
  void_,
  int_,
  long_,
  short_,
  float_,
  double_,
  byte_,
  object,
  string,
  typeParam,
  memberTypeParam,
  list,
  set,
  map,
  customObject,
  customInterface,
  customEnum,
  customRecord,
  nestedCustom
}

enum IsArray { no, yes }

Future<void> main() async {
  final selector = TestCaseSelector(
    dimensions: {
      TopLevelKind: TopLevelKind.values,
      Member: Member.values,
      NestedKind: NestedKind.values,
      TopLevelModifier: TopLevelModifier.values,
      MemberModifier: MemberModifier.values,
      ParamCount: ParamCount.values,
      MemberName: MemberName.values,
      Inheritance: Inheritance.values,
      Generics: Generics.values,
      MemberGenerics: MemberGenerics.values,
      TypeKind: TypeKind.values,
      IsArray: IsArray.values,
    },
    interactionGroups: [
      {TopLevelKind, Member},
      {TopLevelKind, NestedKind},
      {TopLevelKind, TopLevelModifier, Inheritance, Generics},
      {TopLevelKind, Generics, MemberGenerics},
      {Member, MemberModifier, MemberName, MemberGenerics},
      {Member, ParamCount},
      {Member, TypeKind},
      {TypeKind, IsArray},
    ],
    isValid: (tc) {
      final top = tc.get<TopLevelKind>();
      final member = tc.get<Member>();
      final modifier = tc.get<TopLevelModifier>();
      final mod = tc.get<MemberModifier>();
      final name = tc.get<MemberName>();
      final inheritance = tc.get<Inheritance>();
      final generics = tc.get<Generics>();
      final memberGenerics = tc.get<MemberGenerics>();
      final type = tc.get<TypeKind>();
      final paramCount = tc.get<ParamCount>();
      final isArray = tc.get<IsArray>();

      // Basic Java constraints
      if (type == TypeKind.void_ && isArray == IsArray.yes) {
        return false;
      }
      if (memberGenerics != MemberGenerics.none) {
        if (member != Member.method && member != Member.constructor) {
          return false;
        }
      }
      if (top == TopLevelKind.interface) {
        if (member == Member.constructor) {
          return false;
        }
        if (member == Member.initializer) {
          return false;
        }
        if (modifier == TopLevelModifier.final_) {
          return false;
        }
      }
      if (modifier == TopLevelModifier.final_ &&
          mod == MemberModifier.abstract_) {
        return false;
      }
      if (top == TopLevelKind.enum_ || top == TopLevelKind.record) {
        if (inheritance != Inheritance.none &&
            inheritance != Inheritance.implements_) {
          return false;
        }
        if (modifier == TopLevelModifier.sealed) {
          return false;
        }
        if (modifier == TopLevelModifier.final_) {
          return false;
        }
      }
      if (top == TopLevelKind.enum_) {
        if (mod == MemberModifier.abstract_) {
          return false;
        }
        if (generics != Generics.none) {
          return false;
        }
      }
      if (top == TopLevelKind.record) {
        if (member == Member.initializer) {
          return false;
        }
      }

      // TopLevelModifiers
      // Since all generated classes are top-level, they can't be static.
      if (modifier == TopLevelModifier.static_) {
        return false;
      }
      // sealed requires subclasses in the same file/package, too complex for now.
      if (modifier == TopLevelModifier.sealed) {
        return false;
      }

      // Member modifiers
      if (mod != MemberModifier.none) {
        if (member != Member.method && member != Member.constructor) {
          if (mod != MemberModifier.static_ || member != Member.field) {
            return false;
          }
        }
        if (member == Member.constructor &&
            (mod == MemberModifier.abstract_ ||
                mod == MemberModifier.native ||
                mod == MemberModifier.default_ ||
                mod == MemberModifier.static_)) {
          return false;
        }
      }
      if (mod == MemberModifier.default_ && top != TopLevelKind.interface) {
        return false;
      }

      // Special names
      if (name != MemberName.any && member != Member.method) {
        return false;
      }

      // Types
      if (type == TypeKind.void_ && member != Member.method) {
        return false;
      }
      if (type == TypeKind.void_ && (paramCount != ParamCount.zero)) {
        return false;
      }

      // Generics vs Static
      if (type == TypeKind.typeParam) {
        if (generics == Generics.none) {
          return false;
        }
        if (mod == MemberModifier.static_) {
          return false;
        }
        if (top == TopLevelKind.interface && member == Member.field) {
          return false;
        }
      }
      if (type == TypeKind.memberTypeParam) {
        if (memberGenerics == MemberGenerics.none) {
          return false;
        }
        if (member == Member.field || top == TopLevelKind.record) {
          return false;
        }
      }

      return true;
    },
  );

  final testCases = selector.select();
  print('Generated ${testCases.length} test cases.');

  final outputDir = Directory('test/large_java_test/java/com/example');
  if (outputDir.existsSync()) {
    outputDir.deleteSync(recursive: true);
  }
  outputDir.createSync(recursive: true);

  for (var i = 0; i < testCases.length; i++) {
    final tc = testCases[i];
    final className = 'TestClass$i';
    final sb = StringBuffer();
    sb.writeln('package com.example;');
    sb.writeln('import java.util.*;');
    sb.writeln();
    generateTestCase(sb, className, tc);

    final file = File('test/large_java_test/java/com/example/$className.java');
    file.writeAsStringSync(sb.toString());
  }

  print('Wrote files to test/large_java_test/java/com/example/');
}

void generateTestCase(StringBuffer sb, String className, TestCase tc) {
  final top = tc.get<TopLevelKind>();
  final member = tc.get<Member>();
  final nested = tc.get<NestedKind>();
  final modifier = tc.get<TopLevelModifier>();
  final mod = tc.get<MemberModifier>();
  final paramCount = tc.get<ParamCount>();
  final name = tc.get<MemberName>();
  final inheritance = tc.get<Inheritance>();
  final generics = tc.get<Generics>();
  final memberGenerics = tc.get<MemberGenerics>();
  final typeKind = tc.get<TypeKind>();
  final isArray = tc.get<IsArray>();

  final typeStr =
      getJavaType(typeKind, isArray == IsArray.yes, generics, memberGenerics);
  final inheritanceStr = getInheritanceStr(inheritance, top);
  final genStr = getGenericsStr(generics);
  final memberGenStr = getMemberGenericsStr(memberGenerics);
  final topModStr = getTopLevelModifierStr(modifier, mod);
  final kind = getTopLevelKindStr(top);

  if (top == TopLevelKind.record) {
    sb.writeln(
        'public record $className$genStr($typeStr field) $inheritanceStr {');
    if (hasRunMethod(inheritance)) {
      sb.writeln('  public void run() {}');
    }
    sb.writeln('}');
    return;
  }

  sb.writeln('public $topModStr$kind $className$genStr $inheritanceStr {');

  if (top == TopLevelKind.enum_) {
    if (member == Member.constructor) {
      final args = switch (paramCount) {
        ParamCount.zero => '',
        ParamCount.one => getJavaDefaultValue(typeStr),
        ParamCount.two => '${getJavaDefaultValue(typeStr)}, 0',
      };
      sb.writeln('  VALUE1($args), VALUE2($args);');
    } else {
      sb.writeln('  VALUE1, VALUE2;');
    }
    if (hasRunMethod(inheritance)) {
      sb.writeln('  public void run() {}');
    }
  }

  if (hasRunMethod(inheritance) && top == TopLevelKind.class_) {
    sb.writeln('  public void run() {}');
  }

  final params = getParamsStr(paramCount, typeStr);

  switch (member) {
    case Member.field:
      final staticStr = mod == MemberModifier.static_ ? 'static ' : '';
      if (top == TopLevelKind.interface) {
        sb.writeln('  $typeStr myField = ${getJavaDefaultValue(typeStr)};');
      } else {
        sb.writeln('  public $staticStr$typeStr myField;');
      }
      break;
    case Member.method:
      final methodName = name == MemberName.any ? 'myMethod' : name.name;
      final modStr = getMemberModifierStr(mod);

      if (top == TopLevelKind.interface) {
        switch (mod) {
          case MemberModifier.default_:
            final defaultValue = getJavaDefaultValue(typeStr);
            final body = typeStr == 'void' ? '' : 'return $defaultValue;';
            sb.writeln(
                '  default $memberGenStr$typeStr $methodName($params) { $body }');
            break;
          case MemberModifier.static_:
            final defaultValue = getJavaDefaultValue(typeStr);
            final body = typeStr == 'void' ? '' : 'return $defaultValue;';
            sb.writeln(
                '  static $memberGenStr$typeStr $methodName($params) { $body }');
            break;
          default:
            sb.writeln('  $memberGenStr$typeStr $methodName($params);');
        }
      } else {
        switch (mod) {
          case MemberModifier.abstract_:
            sb.writeln(
                '  public abstract $memberGenStr$typeStr $methodName($params);');
            break;
          case MemberModifier.native:
            sb.writeln(
                '  public native $memberGenStr$typeStr $methodName($params);');
            break;
          default:
            final defaultValue = getJavaDefaultValue(typeStr);
            final body = typeStr == 'void' ? '' : 'return $defaultValue;';
            sb.writeln(
                '  public $modStr$memberGenStr$typeStr $methodName($params) { $body }');
        }
      }
      break;
    case Member.constructor:
      if (top == TopLevelKind.enum_) {
        sb.writeln('  private $memberGenStr$className($params) {}');
      } else {
        sb.writeln('  public $memberGenStr$className($params) {}');
      }
      break;
    case Member.initializer:
      final staticStr = mod == MemberModifier.static_ ? 'static ' : '';
      sb.writeln('  $staticStr{ }');
      break;
  }

  if (nested != NestedKind.none) {
    final nKind = getNestedKindStr(nested);
    if (nested == NestedKind.record) {
      sb.writeln('  public static record NestedRecord(int x) {}');
    } else if (nested == NestedKind.enum_) {
      sb.writeln('  public enum NestedEnum { V1 }');
    } else {
      sb.writeln('  public static $nKind Nested {}');
    }
  }

  sb.writeln('}');
}

String getInheritanceStr(Inheritance inheritance, TopLevelKind top) {
  switch (inheritance) {
    case Inheritance.none:
      return '';
    case Inheritance.extends_:
      if (top == TopLevelKind.interface) return ' extends Runnable';
      if (top == TopLevelKind.record) return '';
      return ' extends Object';
    case Inheritance.implements_:
      if (top == TopLevelKind.interface) return ' extends Runnable';
      return ' implements Runnable';
    case Inheritance.multipleImplements:
      if (top == TopLevelKind.interface) return ' extends Runnable, Cloneable';
      return ' implements Runnable, Cloneable';
    case Inheritance.extendsGenericSpecialized:
      if (top == TopLevelKind.interface) return ' extends List<String>';
      if (top == TopLevelKind.record) return ' implements List<String>';
      return ' extends ArrayList<String>';
    case Inheritance.extendsGenericUnspecialized:
      if (top == TopLevelKind.interface) return ' extends List';
      if (top == TopLevelKind.record) return ' implements List';
      return ' extends ArrayList';
    default:
      return '';
  }
}

String getGenericsStr(Generics generics) {
  return switch (generics) {
    Generics.none => '',
    Generics.oneParam => '<T>',
    Generics.twoParams => '<T, U>',
    Generics.upperBound => '<T extends Number>',
    Generics.lowerBound => '<T>',
    Generics.wildcard => '<T>',
  };
}

String getMemberGenericsStr(MemberGenerics memberGenerics) {
  return switch (memberGenerics) {
    MemberGenerics.none => '',
    MemberGenerics.oneParam => '<S> ',
    MemberGenerics.twoParams => '<S, V> ',
    MemberGenerics.upperBound => '<S extends Number> ',
  };
}

String getTopLevelModifierStr(TopLevelModifier modifier, MemberModifier mod) {
  var s = switch (modifier) {
    TopLevelModifier.none => '',
    TopLevelModifier.final_ => 'final ',
    TopLevelModifier.static_ => 'static ',
    TopLevelModifier.sealed => 'sealed ',
  };
  if (mod == MemberModifier.abstract_) {
    s += 'abstract ';
  }
  return s;
}

String getTopLevelKindStr(TopLevelKind top) {
  return switch (top) {
    TopLevelKind.class_ => 'class',
    TopLevelKind.interface => 'interface',
    TopLevelKind.enum_ => 'enum',
    TopLevelKind.record => 'record',
  };
}

String getMemberModifierStr(MemberModifier mod) {
  return switch (mod) {
    MemberModifier.static_ => 'static ',
    MemberModifier.synchronized => 'synchronized ',
    MemberModifier.native => 'native ',
    MemberModifier.abstract_ => 'abstract ',
    _ => '',
  };
}

String getParamsStr(ParamCount paramCount, String typeStr) {
  return switch (paramCount) {
    ParamCount.zero => '',
    ParamCount.one => '$typeStr p1',
    ParamCount.two => '$typeStr p1, int p2',
  };
}

String getNestedKindStr(NestedKind nested) {
  return switch (nested) {
    NestedKind.class_ => 'class',
    NestedKind.interface => 'interface',
    NestedKind.enum_ => 'enum',
    NestedKind.record => 'record',
    _ => 'class',
  };
}

bool hasRunMethod(Inheritance inheritance) {
  return inheritance == Inheritance.implements_ ||
      inheritance == Inheritance.multipleImplements ||
      inheritance == Inheritance.extendsGenericSpecialized ||
      inheritance == Inheritance.extendsGenericUnspecialized;
}

String getJavaType(
    TypeKind kind, bool isArray, Generics generics, MemberGenerics mGenerics) {
  var t = switch (kind) {
    TypeKind.void_ => 'void',
    TypeKind.int_ => 'int',
    TypeKind.long_ => 'long',
    TypeKind.short_ => 'short',
    TypeKind.float_ => 'float',
    TypeKind.double_ => 'double',
    TypeKind.byte_ => 'byte',
    TypeKind.object => 'Object',
    TypeKind.string => 'String',
    TypeKind.typeParam => 'T',
    TypeKind.memberTypeParam => 'S',
    TypeKind.list => 'List<String>',
    TypeKind.set => 'Set<String>',
    TypeKind.map => 'Map<String, String>',
    TypeKind.customObject => 'ArrayList<String>',
    TypeKind.customInterface => 'Runnable',
    TypeKind.customEnum => 'java.lang.Thread.State',
    TypeKind.customRecord => 'Object',
    TypeKind.nestedCustom => 'Map.Entry<String, String>',
  };
  if (isArray) t += '[]';
  return t;
}

String getJavaDefaultValue(String type) {
  if (type == 'void') {
    return '';
  }
  if (type.endsWith('[]')) {
    return 'null';
  }
  switch (type) {
    case 'int':
    case 'long':
    case 'byte':
    case 'short':
      return '0';
    case 'float':
      return '0.0f';
    case 'double':
      return '0.0';
    case 'boolean':
      return 'false';
    case 'char':
      return "' '";
    default:
      return 'null';
  }
}
