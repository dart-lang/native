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
      TypeKind: TypeKind.values,
      IsArray: IsArray.values,
    },
    interactionGroups: [
      {TopLevelKind, Member},
      {TopLevelKind, NestedKind},
      {TopLevelKind, TopLevelModifier, Inheritance, Generics},
      {Member, MemberModifier, MemberName},
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
      final type = tc.get<TypeKind>();
      final paramCount = tc.get<ParamCount>();

      // Basic Java constraints
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
      if (type == TypeKind.typeParam && generics != Generics.none) {
        if (mod == MemberModifier.static_) {
          return false;
        }
        if (top == TopLevelKind.interface && member == Member.field) {
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
  final typeKind = tc.get<TypeKind>();
  final isArray = tc.get<IsArray>();

  final typeStr = getJavaType(typeKind, isArray == IsArray.yes, generics);

  // Inheritance string
  var inheritanceStr = '';
  if (inheritance == Inheritance.extends_) {
    if (top == TopLevelKind.interface) {
      inheritanceStr = ' extends Runnable';
    } else if (top == TopLevelKind.record) {
      inheritanceStr = '';
    } else {
      inheritanceStr = ' extends Object';
    }
  } else if (inheritance == Inheritance.implements_) {
    if (top == TopLevelKind.interface) {
      inheritanceStr = ' extends Runnable';
    } else {
      inheritanceStr = ' implements Runnable';
    }
  } else if (inheritance == Inheritance.multipleImplements) {
    if (top == TopLevelKind.interface) {
      inheritanceStr = ' extends Runnable, Cloneable';
    } else {
      inheritanceStr = ' implements Runnable, Cloneable';
    }
  } else if (inheritance == Inheritance.extendsGenericSpecialized) {
    if (top == TopLevelKind.interface) {
      inheritanceStr = ' extends List<String>';
    } else if (top == TopLevelKind.record) {
      inheritanceStr = ' implements List<String>';
    } else {
      inheritanceStr = ' extends ArrayList<String>';
    }
  } else if (inheritance == Inheritance.extendsGenericUnspecialized) {
    if (top == TopLevelKind.interface) {
      inheritanceStr = ' extends List';
    } else if (top == TopLevelKind.record) {
      inheritanceStr = ' implements List';
    } else {
      inheritanceStr = ' extends ArrayList';
    }
  }

  // Generics string
  var genStr = '';
  if (generics == Generics.oneParam) {
    genStr = '<T>';
  } else if (generics == Generics.twoParams) {
    genStr = '<T, U>';
  } else if (generics == Generics.upperBound) {
    genStr = '<T extends Number>';
  } else if (generics == Generics.lowerBound) {
    genStr = '<T>';
  } else if (generics == Generics.wildcard) {
    genStr = '<T>';
  }

  // TopLevelModifier string
  var topModStr = '';
  if (modifier == TopLevelModifier.final_) {
    topModStr = 'final ';
  } else if (modifier == TopLevelModifier.static_) {
    topModStr = 'static ';
  } else if (modifier == TopLevelModifier.sealed) {
    topModStr = 'sealed ';
  }

  if (mod == MemberModifier.abstract_) {
    topModStr += 'abstract ';
  }

  var kind = 'class';
  if (top == TopLevelKind.interface) {
    kind = 'interface';
  }
  if (top == TopLevelKind.enum_) {
    kind = 'enum';
  }
  if (top == TopLevelKind.record) {
    kind = 'record';
  }

  if (top == TopLevelKind.record) {
    sb.writeln(
        'public record $className$genStr($typeStr field) $inheritanceStr {');
    if (inheritance.name.contains('implements_') ||
        inheritance == Inheritance.multipleImplements ||
        inheritance == Inheritance.extendsGenericSpecialized ||
        inheritance == Inheritance.extendsGenericUnspecialized) {
      sb.writeln('  public void run() {}');
    }
    sb.writeln('}');
    return;
  }

  sb.writeln('public $topModStr$kind $className$genStr $inheritanceStr {');

  if (top == TopLevelKind.enum_) {
    if (member == Member.constructor) {
      String args;
      if (paramCount == ParamCount.zero) {
        args = '';
      } else if (paramCount == ParamCount.one) {
        args = getJavaDefaultValue(typeStr);
      } else {
        args = '${getJavaDefaultValue(typeStr)}, 0';
      }
      sb.writeln('  VALUE1($args), VALUE2($args);');
    } else {
      sb.writeln('  VALUE1, VALUE2;');
    }
    if (inheritance.name.contains('implements_') ||
        inheritance == Inheritance.multipleImplements ||
        inheritance == Inheritance.extendsGenericSpecialized ||
        inheritance == Inheritance.extendsGenericUnspecialized) {
      sb.writeln('  public void run() {}');
    }
  }

  if (inheritance.name.contains('implements_') ||
      inheritance == Inheritance.multipleImplements ||
      inheritance == Inheritance.extendsGenericSpecialized ||
      inheritance == Inheritance.extendsGenericUnspecialized) {
    if (top == TopLevelKind.class_) {
      sb.writeln('  public void run() {}');
    }
  }

  // Member
  if (member == Member.field) {
    final staticStr = mod == MemberModifier.static_ ? 'static ' : '';
    if (top == TopLevelKind.interface) {
      sb.writeln('  $typeStr myField = ${getJavaDefaultValue(typeStr)};');
    } else {
      sb.writeln('  public $staticStr$typeStr myField;');
    }
  } else if (member == Member.method) {
    final methodName = name == MemberName.any ? 'myMethod' : name.name;
    var params = '';
    if (paramCount == ParamCount.one) {
      params = '$typeStr p1';
    } else if (paramCount == ParamCount.two) {
      params = '$typeStr p1, int p2';
    }

    var modStr = '';
    if (mod == MemberModifier.static_) {
      modStr = 'static ';
    } else if (mod == MemberModifier.synchronized) {
      modStr = 'synchronized ';
    } else if (mod == MemberModifier.native) {
      modStr = 'native ';
    } else if (mod == MemberModifier.abstract_) {
      modStr = 'abstract ';
    }

    if (top == TopLevelKind.interface) {
      if (mod == MemberModifier.default_) {
        final defaultValue = getJavaDefaultValue(typeStr);
        final body = typeStr == 'void' ? '' : 'return $defaultValue;';
        sb.writeln('  default $typeStr $methodName($params) { $body }');
      } else if (mod == MemberModifier.static_) {
        final defaultValue = getJavaDefaultValue(typeStr);
        final body = typeStr == 'void' ? '' : 'return $defaultValue;';
        sb.writeln('  static $typeStr $methodName($params) { $body }');
      } else {
        sb.writeln('  $typeStr $methodName($params);');
      }
    } else {
      if (mod == MemberModifier.abstract_) {
        sb.writeln('  public abstract $typeStr $methodName($params);');
      } else if (mod == MemberModifier.native) {
        sb.writeln('  public native $typeStr $methodName($params);');
      } else {
        final defaultValue = getJavaDefaultValue(typeStr);
        final body = typeStr == 'void' ? '' : 'return $defaultValue;';
        sb.writeln('  public $modStr$typeStr $methodName($params) { $body }');
      }
    }
  } else if (member == Member.constructor) {
    var params = '';
    if (paramCount == ParamCount.one) {
      params = '$typeStr p1';
    } else if (paramCount == ParamCount.two) {
      params = '$typeStr p1, int p2';
    }

    if (top == TopLevelKind.enum_) {
      sb.writeln('  private $className($params) {}');
    } else {
      sb.writeln('  public $className($params) {}');
    }
  } else if (member == Member.initializer) {
    final staticStr = mod == MemberModifier.static_ ? 'static ' : '';
    sb.writeln('  $staticStr{ }');
  }

  // Nested
  if (nested != NestedKind.none) {
    var nKind = 'class';
    if (nested == NestedKind.interface) {
      nKind = 'interface';
    }
    if (nested == NestedKind.enum_) {
      nKind = 'enum';
    }
    if (nested == NestedKind.record) {
      nKind = 'record';
    }

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

String getJavaType(TypeKind kind, bool isArray, Generics generics) {
  var t = 'void';
  switch (kind) {
    case TypeKind.void_:
      t = 'void';
      break;
    case TypeKind.int_:
      t = 'int';
      break;
    case TypeKind.long_:
      t = 'long';
      break;
    case TypeKind.short_:
      t = 'short';
      break;
    case TypeKind.float_:
      t = 'float';
      break;
    case TypeKind.double_:
      t = 'double';
      break;
    case TypeKind.byte_:
      t = 'byte';
      break;
    case TypeKind.object:
      t = 'Object';
      break;
    case TypeKind.string:
      t = 'String';
      break;
    case TypeKind.typeParam:
      t = (generics == Generics.none) ? 'Object' : 'T';
      break;
    case TypeKind.list:
      t = 'List<String>';
      break;
    case TypeKind.set:
      t = 'Set<String>';
      break;
    case TypeKind.map:
      t = 'Map<String, String>';
      break;
    case TypeKind.customObject:
      t = 'ArrayList<String>';
      break;
    case TypeKind.customInterface:
      t = 'Runnable';
      break;
    case TypeKind.customEnum:
      t = 'java.lang.Thread.State';
      break;
    case TypeKind.customRecord:
      t = 'Object';
      break;
    case TypeKind.nestedCustom:
      t = 'Map.Entry<String, String>';
      break;
  }
  if (isArray && t != 'void') t += '[]';
  return t;
}

String getJavaDefaultValue(String type) {
  if (type == 'void') {
    return '';
  }
  if (type.endsWith('[]')) {
    return 'null';
  }
  if (type == 'int' || type == 'long' || type == 'byte' || type == 'short') {
    return '0';
  }
  if (type == 'float') {
    return '0.0f';
  }
  if (type == 'double') {
    return '0.0';
  }
  if (type == 'boolean') {
    return 'false';
  }
  if (type == 'char') {
    return "' '";
  }
  return 'null';
}
