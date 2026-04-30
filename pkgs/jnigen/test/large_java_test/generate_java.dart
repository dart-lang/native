// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test_case_selector/test_case_selector.dart';

const _copyrightHeader = '''
// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''';

enum TopLevelKind { class_, interface, enum_, record }

enum Member { field, method, constructor, initializer }

enum NestedKind { none, innerClass, staticClass, interface, enum_, record }

enum TopLevelModifier { none, final_, sealed }

enum MemberModifier {
  none,
  static_,
  final_,
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

enum MemberGenerics {
  none,
  oneParam,
  twoParams,
  upperBound,
  lowerBound,
  wildcard
}

enum TypeKind {
  void_,
  boolean_,
  char_,
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
      {TopLevelKind, NestedKind, TopLevelModifier, Inheritance, Generics},
      {TopLevelKind, Generics, MemberGenerics},
      {Member, MemberModifier, MemberName, MemberGenerics},
      {Member, ParamCount},
      {TypeKind, IsArray},
      {Member, MemberGenerics, TypeKind},
    ],
    isValid: (tc) {
      final top = tc.get<TopLevelKind>();
      final member = tc.get<Member>();
      final nested = tc.get<NestedKind>();
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
        if (modifier == TopLevelModifier.final_ ||
            modifier == TopLevelModifier.sealed) {
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

      if (modifier == TopLevelModifier.sealed) {
        if (mod == MemberModifier.abstract_) {
          return false;
        }
        if (top == TopLevelKind.interface && member == Member.method) {
          // Abstract methods in interface.
          if (mod != MemberModifier.default_ && mod != MemberModifier.static_) {
            return false;
          }
        }
        if (member == Member.constructor && paramCount != ParamCount.zero) {
          // Subclass must call super(...)
          return false;
        }
        if (inheritance != Inheritance.none) {
          // Runnable, List, etc require overrides.
          return false;
        }
        if (memberGenerics != MemberGenerics.none) {
          // Subclass might need to handle generic methods.
          return false;
        }
      }

      // Generics constraints
      // Declaration-site bounds
      if (generics == Generics.lowerBound || generics == Generics.wildcard) {
        return false;
      }
      if (memberGenerics == MemberGenerics.lowerBound ||
          memberGenerics == MemberGenerics.wildcard) {
        return false;
      }

      if (top == TopLevelKind.record) {
        if (member == Member.initializer ||
            memberGenerics != MemberGenerics.none) {
          return false;
        }
      }

      // Nested types constraints
      if (nested == NestedKind.innerClass) {
        if (top == TopLevelKind.interface ||
            top == TopLevelKind.enum_ ||
            top == TopLevelKind.record) {
          return false;
        }
      }
      if (nested == NestedKind.staticClass) {
        if (top != TopLevelKind.class_ && top != TopLevelKind.enum_) {
          return false;
        }
      }

      // Member modifiers
      if (mod != MemberModifier.none) {
        if (mod == MemberModifier.final_) {
          if (member == Member.constructor || member == Member.initializer) {
            return false;
          }
          if (top == TopLevelKind.interface && member == Member.method) {
            return false;
          }
        }
        if (mod == MemberModifier.transient || mod == MemberModifier.volatile) {
          if (member != Member.field || top == TopLevelKind.interface) {
            return false;
          }
        }
        if (mod == MemberModifier.throws) {
          if (member != Member.method) {
            return false;
          }
        }
        if (member == Member.field) {
          const fieldModifiers = {
            MemberModifier.static_,
            MemberModifier.final_,
            MemberModifier.transient,
            MemberModifier.volatile,
          };
          if (!fieldModifiers.contains(mod)) {
            return false;
          }
        }
        if (member == Member.initializer) {
          if (mod != MemberModifier.static_) {
            return false;
          }
        }
        if (member == Member.constructor &&
            (mod == MemberModifier.abstract_ ||
                mod == MemberModifier.native ||
                mod == MemberModifier.default_ ||
                mod == MemberModifier.static_ ||
                mod == MemberModifier.synchronized ||
                mod == MemberModifier.throws ||
                mod == MemberModifier.final_)) {
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
      if (top == TopLevelKind.record && type == TypeKind.void_) {
        return false;
      }
      if (type == TypeKind.void_ && (paramCount != ParamCount.zero)) {
        return false;
      }

      // Generics vs Static
      if (mod == MemberModifier.static_) {
        // If the type is forced to use the class scope 'T' (or is T itself),
        // and the class is generic, it's invalid in a static context.
        final useMemberScope = memberGenerics != MemberGenerics.none &&
            (type == TypeKind.memberTypeParam ||
                memberGenerics == MemberGenerics.lowerBound ||
                memberGenerics == MemberGenerics.wildcard);

        if (!useMemberScope) {
          if (type == TypeKind.typeParam || generics != Generics.none) {
            // Some TypeKind like list/set/map/etc will use 'T' if top-level is
            // generic.
            const genericTypes = {
              TypeKind.list,
              TypeKind.set,
              TypeKind.map,
              TypeKind.customObject,
              TypeKind.nestedCustom,
              TypeKind.typeParam,
            };
            if (genericTypes.contains(type)) {
              return false;
            }
          }
        }
      }

      if (type == TypeKind.typeParam) {
        if (generics == Generics.none) {
          return false;
        }
        if (top == TopLevelKind.interface && member == Member.field) {
          return false;
        }
      }

      // Interfaces vs Static Fields
      if (top == TopLevelKind.interface && member == Member.field) {
        if (generics != Generics.none) {
          const genericTypes = {
            TypeKind.list,
            TypeKind.set,
            TypeKind.map,
            TypeKind.customObject,
            TypeKind.nestedCustom,
          };
          if (genericTypes.contains(type)) {
            return false;
          }
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

  final scriptDir = p.dirname(p.fromUri(Platform.script));
  final outputDir = Directory(p.join(scriptDir, 'java', 'com', 'example'));
  if (outputDir.existsSync()) {
    outputDir.deleteSync(recursive: true);
  }
  outputDir.createSync(recursive: true);

  writeCoreClasses(outputDir);

  for (var i = 0; i < testCases.length; i++) {
    final tc = testCases[i];
    final className = 'TestClass$i';
    final sb = StringBuffer();
    sb.writeln(_copyrightHeader);
    sb.writeln('package com.example;');
    sb.writeln('import java.util.*;');
    sb.writeln();
    sb.writeln('// ${tc.toString().split(', ').join('\n// ')}');
    generateTestCase(sb, className, tc);

    final file = File(p.join(outputDir.path, '$className.java'));
    file.writeAsStringSync(sb.toString());
  }

  print('Wrote files to ${outputDir.path}');
}

void writeCoreClasses(Directory outputDir) {
  final coreClasses = {
    'BaseInterface': '''
public interface BaseInterface {
  int BASE_FIELD = 0;
  default void baseMethod() {}
}
''',
    'DiamondLeft': '''
public interface DiamondLeft extends BaseInterface {
  int LEFT_FIELD = 1;
  default void leftMethod() {}
}
''',
    'DiamondRight': '''
public interface DiamondRight extends BaseInterface {
  int RIGHT_FIELD = 2;
  default void rightMethod() {}
}
''',
    'DagA': '''
public interface DagA {
  int A_FIELD = 3;
  default void aMethod() {}
}
''',
    'DagB': '''
public interface DagB extends DagA {
  int B_FIELD = 4;
  default void bMethod() {}
}
''',
    'DagC': '''
public interface DagC extends DagA, DagB {
  int C_FIELD = 5;
  default void cMethod() {}
}
''',
    'DagD': '''
public interface DagD extends DagA, DagB, DagC {
  int D_FIELD = 6;
  default void dMethod() {}
}
''',
    'DagE': '''
public interface DagE extends DagB, DagD {
  int E_FIELD = 7;
  default void eMethod() {}
}
''',
    'CustomRecord': '''
public record CustomRecord<T>(T x, String y) {}
''',
    'CustomObject': '''
public class CustomObject<T> {
  public T value;
  public CustomObject(T value) { this.value = value; }
}
''',
    'CustomInterface': '''
public interface CustomInterface<T> {
  T getValue();
}
''',
    'CustomEnum': '''
public enum CustomEnum {
  V1, V2
}
''',
    'NestedCustom': '''
public class NestedCustom<T, U> {
  public class Nested<V> {
    public T t;
    public U u;
    public V v;
  }
}
''',
  };

  for (final entry in coreClasses.entries) {
    final file = File('${outputDir.path}/${entry.key}.java');
    file.writeAsStringSync('''
$_copyrightHeader
package com.example;

${entry.value.trim()}
''');
  }
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
  final typeParamsStr = getTypeParamsStr(generics);
  final memberGenStr = getMemberGenericsStr(memberGenerics);
  final topModStr = getTopLevelModifierStr(modifier, mod);
  final kind = getTopLevelKindStr(top);
  final params = getParamsStr(paramCount, typeStr);

  if (top == TopLevelKind.record) {
    sb.write('''
public record $className$genStr($typeStr field) $inheritanceStr {
${hasRunMethod(inheritance) ? '  public void run() {}\n' : ''}}
''');
    return;
  }

  sb.write('''
public $topModStr$kind $className$genStr $inheritanceStr {
''');

  if (top == TopLevelKind.enum_) {
    sb.writeln(getEnumConstantsStr(member, paramCount, typeStr));
    if (hasRunMethod(inheritance)) {
      sb.writeln('  public void run() {}');
    }
  }

  if (hasRunMethod(inheritance) && top == TopLevelKind.class_) {
    sb.writeln('  public void run() {}');
  }

  sb.write(switch (member) {
    Member.field => getFieldStr(top, mod, typeStr),
    Member.method =>
      getMethodStr(top, mod, memberGenStr, typeStr, name, params),
    Member.constructor =>
      getConstructorStr(top, memberGenStr, className, params),
    Member.initializer => getInitializerStr(mod),
  });

  if (nested != NestedKind.none) {
    sb.writeln(getNestedStr(nested));
  }

  if (modifier == TopLevelModifier.sealed) {
    final keyword = top == TopLevelKind.interface ? 'implements' : 'extends';
    sb.write('''
  public static final class Sub$genStr $keyword $className$typeParamsStr {}
''');
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
      if (top == TopLevelKind.interface) return ' extends Cloneable';
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
    case Inheritance.diamond:
      if (top == TopLevelKind.interface) {
        return ' extends DiamondLeft, DiamondRight';
      }
      return ' implements DiamondLeft, DiamondRight';
    case Inheritance.complexDag:
      if (top == TopLevelKind.interface) {
        return ' extends DagA, DagD, DagE';
      }
      return ' implements DagA, DagD, DagE';
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

String getTypeParamsStr(Generics generics) {
  return switch (generics) {
    Generics.none => '',
    Generics.oneParam => '<T>',
    Generics.twoParams => '<T, U>',
    _ => '<T>',
  };
}

String getMemberGenericsStr(MemberGenerics memberGenerics) {
  return switch (memberGenerics) {
    MemberGenerics.none => '',
    MemberGenerics.oneParam => '<S> ',
    MemberGenerics.twoParams => '<S, V> ',
    MemberGenerics.upperBound => '<S extends Number> ',
    MemberGenerics.lowerBound => '<S> ',
    MemberGenerics.wildcard => '<S> ',
  };
}

String getTopLevelModifierStr(TopLevelModifier modifier, MemberModifier mod) {
  var s = switch (modifier) {
    TopLevelModifier.none => '',
    TopLevelModifier.final_ => 'final ',
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
    MemberModifier.final_ => 'final ',
    MemberModifier.synchronized => 'synchronized ',
    MemberModifier.native => 'native ',
    MemberModifier.abstract_ => 'abstract ',
    MemberModifier.transient => 'transient ',
    MemberModifier.volatile => 'volatile ',
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

String getEnumConstantsStr(
    Member member, ParamCount paramCount, String typeStr) {
  if (member == Member.constructor) {
    final args = switch (paramCount) {
      ParamCount.zero => '',
      ParamCount.one => getJavaDefaultValue(typeStr),
      ParamCount.two => '${getJavaDefaultValue(typeStr)}, 0',
    };
    return '  VALUE1($args), VALUE2($args);';
  }
  return '  VALUE1, VALUE2;';
}

String getFieldStr(TopLevelKind top, MemberModifier mod, String typeStr) {
  final modStr = getMemberModifierStr(mod);
  final defaultValue = getJavaDefaultValue(typeStr);
  if (top == TopLevelKind.interface) {
    return '''
  $modStr$typeStr myField = $defaultValue;
''';
  }
  final init = mod == MemberModifier.final_ ? ' = $defaultValue' : '';
  return '''
  public $modStr$typeStr myField$init;
''';
}

String getMethodStr(TopLevelKind top, MemberModifier mod, String memberGenStr,
    String typeStr, MemberName name, String params) {
  final methodName = name == MemberName.any ? 'myMethod' : name.name;
  final defaultValue = getJavaDefaultValue(typeStr);
  final body = typeStr == 'void' ? '' : 'return $defaultValue;';
  final throwsStr = mod == MemberModifier.throws ? ' throws Exception' : '';

  if (top == TopLevelKind.interface) {
    return switch (mod) {
      MemberModifier.default_ => '''
  default $memberGenStr$typeStr $methodName($params)$throwsStr { $body }
''',
      MemberModifier.static_ => '''
  static $memberGenStr$typeStr $methodName($params)$throwsStr { $body }
''',
      _ => '''
  $memberGenStr$typeStr $methodName($params)$throwsStr;
''',
    };
  }

  final modStr = getMemberModifierStr(mod);
  return switch (mod) {
    MemberModifier.abstract_ => '''
  public abstract $memberGenStr$typeStr $methodName($params)$throwsStr;
''',
    MemberModifier.native => '''
  public native $memberGenStr$typeStr $methodName($params)$throwsStr;
''',
    _ => '''
  public $modStr$memberGenStr$typeStr $methodName($params)$throwsStr { $body }
''',
  };
}

String getConstructorStr(
    TopLevelKind top, String memberGenStr, String className, String params) {
  final visibility = top == TopLevelKind.enum_ ? 'private' : 'public';
  return '''
  $visibility $memberGenStr$className($params) {}
''';
}

String getInitializerStr(MemberModifier mod) {
  final staticStr = mod == MemberModifier.static_ ? 'static ' : '';
  return '''
  $staticStr{ }
''';
}

String getNestedStr(NestedKind nested) {
  final nKind = switch (nested) {
    NestedKind.innerClass || NestedKind.staticClass => 'class',
    NestedKind.interface => 'interface',
    NestedKind.enum_ => 'enum',
    NestedKind.record => 'record',
    _ => 'class',
  };
  if (nested == NestedKind.record) {
    return '''
  public static record NestedRecord(int x) {}
''';
  }
  if (nested == NestedKind.enum_) {
    return '''
  public enum NestedEnum { V1 }
''';
  }
  final staticStr = nested == NestedKind.innerClass ? '' : 'static ';
  return '''
  public $staticStr$nKind Nested {}
''';
}

bool hasRunMethod(Inheritance inheritance) {
  return inheritance == Inheritance.extends_ ||
      inheritance == Inheritance.implements_ ||
      inheritance == Inheritance.multipleImplements ||
      inheritance == Inheritance.extendsGenericSpecialized ||
      inheritance == Inheritance.extendsGenericUnspecialized ||
      inheritance == Inheritance.diamond ||
      inheritance == Inheritance.complexDag;
}

String getJavaType(
    TypeKind kind, bool isArray, Generics generics, MemberGenerics mGenerics) {
  final useMemberScope = mGenerics != MemberGenerics.none;

  final scopeVar = useMemberScope ? 'S' : 'T';
  final scopeEnum = useMemberScope ? mGenerics : generics;

  final g = switch (scopeEnum) {
    Generics.oneParam || MemberGenerics.oneParam => scopeVar,
    Generics.twoParams || MemberGenerics.twoParams => scopeVar,
    Generics.upperBound || MemberGenerics.upperBound => scopeVar,
    Generics.lowerBound || MemberGenerics.lowerBound => '? super $scopeVar',
    Generics.wildcard || MemberGenerics.wildcard => '?',
    _ => 'String',
  };

  var t = switch (kind) {
    TypeKind.void_ => 'void',
    TypeKind.boolean_ => 'boolean',
    TypeKind.char_ => 'char',
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
    TypeKind.list => 'List<$g>',
    TypeKind.set => 'Set<$g>',
    TypeKind.map => 'Map<$g, $g>',
    TypeKind.customObject => 'CustomObject<$g>',
    TypeKind.customInterface => 'CustomInterface<$g>',
    TypeKind.customEnum => 'CustomEnum',
    TypeKind.customRecord => 'CustomRecord<$g>',
    TypeKind.nestedCustom => 'NestedCustom<$g, $g>.Nested<$g>',
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
