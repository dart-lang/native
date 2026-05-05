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

enum MemberType {
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

enum MemberNullability { none, nullable, nonnull }

enum GenericNullability { none, nullable, nonnull }

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
      MemberType: MemberType.values,
      IsArray: IsArray.values,
      MemberNullability: MemberNullability.values,
      GenericNullability: GenericNullability.values,
    },
    interactionGroups: [
      {TopLevelKind, Member},
      {TopLevelKind, NestedKind, TopLevelModifier, Inheritance, Generics},
      {TopLevelKind, Generics, MemberGenerics},
      {Member, MemberModifier, MemberName, MemberGenerics},
      {Member, ParamCount},
      {MemberType, IsArray, MemberNullability},
      {Member, MemberGenerics, MemberType},
      {Generics, MemberGenerics, GenericNullability},
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
      final type = tc.get<MemberType>();
      final paramCount = tc.get<ParamCount>();
      final isArray = tc.get<IsArray>();
      final memberNullability = tc.get<MemberNullability>();
      final genericNullability = tc.get<GenericNullability>();

      // Basic Java constraints
      if (type == MemberType.void_ && isArray == IsArray.yes) {
        return false;
      }
      if (type == MemberType.void_ &&
          memberNullability != MemberNullability.none) {
        return false;
      }
      if (isArray == IsArray.no &&
          memberNullability != MemberNullability.none &&
          isPrimitive(type)) {
        return false;
      }

      if (genericNullability != GenericNullability.none) {
        if (generics == Generics.none &&
            memberGenerics == MemberGenerics.none &&
            inheritance != Inheritance.extendsGenericSpecialized &&
            inheritance != Inheritance.extendsGenericUnspecialized) {
          return false;
        }
      }

      if (memberGenerics != MemberGenerics.none) {
        if (member != Member.method && member != Member.constructor) {
          return false;
        }
      }

      if (top == TopLevelKind.interface) {
        if (member == Member.constructor || member == Member.initializer) {
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
        if (mod == MemberModifier.abstract_ || generics != Generics.none) {
          return false;
        }
      }

      if (modifier == TopLevelModifier.sealed) {
        if (mod == MemberModifier.abstract_) {
          return false;
        }
        if (top == TopLevelKind.interface && member == Member.method) {
          if (mod != MemberModifier.default_ && mod != MemberModifier.static_) {
            return false;
          }
        }
        if (member == Member.constructor && paramCount != ParamCount.zero) {
          return false;
        }
        if (inheritance != Inheritance.none) {
          return false;
        }
        if (memberGenerics != MemberGenerics.none) {
          return false;
        }
      }

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
        if (mod == MemberModifier.throws && member != Member.method) {
          return false;
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
        if (member == Member.initializer && mod != MemberModifier.static_) {
          return false;
        }
        if (member == Member.constructor &&
            {
              MemberModifier.abstract_,
              MemberModifier.native,
              MemberModifier.default_,
              MemberModifier.static_,
              MemberModifier.synchronized,
              MemberModifier.throws,
              MemberModifier.final_,
            }.contains(mod)) {
          return false;
        }
      }
      if (mod == MemberModifier.default_ && top != TopLevelKind.interface) {
        return false;
      }

      if (name != MemberName.any && member != Member.method) {
        return false;
      }

      if (type == MemberType.void_ && member != Member.method) {
        return false;
      }
      if (top == TopLevelKind.record && type == MemberType.void_) {
        return false;
      }
      if (type == MemberType.void_ && paramCount != ParamCount.zero) {
        return false;
      }

      if (mod == MemberModifier.static_) {
        final useMemberScope = memberGenerics != MemberGenerics.none &&
            (type == MemberType.memberTypeParam ||
                memberGenerics == MemberGenerics.lowerBound ||
                memberGenerics == MemberGenerics.wildcard);

        if (!useMemberScope && generics != Generics.none) {
          const genericTypes = {
            MemberType.list,
            MemberType.set,
            MemberType.map,
            MemberType.customObject,
            MemberType.customInterface,
            MemberType.customRecord,
            MemberType.nestedCustom,
            MemberType.typeParam,
          };
          if (genericTypes.contains(type)) {
            return false;
          }
        }
      }

      if (type == MemberType.typeParam) {
        if (generics == Generics.none) {
          return false;
        }
        if (top == TopLevelKind.interface && member == Member.field) {
          return false;
        }
      }

      if (top == TopLevelKind.interface && member == Member.field) {
        if (generics != Generics.none) {
          const genericTypes = {
            MemberType.list,
            MemberType.set,
            MemberType.map,
            MemberType.customObject,
            MemberType.nestedCustom,
          };
          if (genericTypes.contains(type)) {
            return false;
          }
        }
      }

      if (type == MemberType.memberTypeParam) {
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
  final javaDir = Directory(p.join(scriptDir, 'java'));
  if (javaDir.existsSync()) {
    javaDir.deleteSync(recursive: true);
  }
  javaDir.createSync(recursive: true);

  writeCoreClasses(javaDir);

  final outputDir = Directory(p.join(javaDir.path, 'com', 'example'));
  outputDir.createSync(recursive: true);

  for (var i = 0; i < testCases.length; i++) {
    final tc = testCases[i];
    final className = 'TestClass$i';
    final sb = StringBuffer();
    sb.writeln(_copyrightHeader);
    sb.writeln('package com.example;');
    sb.writeln('import java.util.*;');
    sb.writeln('import org.jetbrains.annotations.Nullable;');
    sb.writeln('import org.jetbrains.annotations.NotNull;');
    sb.writeln();
    for (final line in tc.toString().split(', ')) {
      sb.writeln('// $line');
    }
    generateTestCase(sb, className, tc);

    final file = File(p.join(outputDir.path, '$className.java'));
    file.writeAsStringSync(sb.toString());
  }

  print('Wrote files to ${outputDir.path}');
}

void writeCoreClasses(Directory baseDir) {
  final coreClasses = {
    'Nullable': '''
package org.jetbrains.annotations;
import java.lang.annotation.*;
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.FIELD, ElementType.PARAMETER, ElementType.LOCAL_VARIABLE, ElementType.TYPE_USE})
public @interface Nullable {}
''',
    'NotNull': '''
package org.jetbrains.annotations;
import java.lang.annotation.*;
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.FIELD, ElementType.PARAMETER, ElementType.LOCAL_VARIABLE, ElementType.TYPE_USE})
public @interface NotNull {}
''',
    'GrandParent': '''
public class GrandParent {
  public void grandParentMethod() {}
}
''',
    'OtherInterface': '''
public interface OtherInterface {
  void otherInterfaceMethod();
}
''',
    'GenericParent': '''
public class GenericParent<T> {
  public void genericParentMethod(T t) {}
}
''',
    'GenericInterface': '''
public interface GenericInterface<T> {
  T genericInterfaceMethod(T t);
}
''',
    'BaseInterface': '''
public interface BaseInterface {
  int BASE_FIELD = 0;
  void baseMethod();
}
''',
    'DiamondLeft': '''
public interface DiamondLeft extends BaseInterface {
  int LEFT_FIELD = 1;
  void leftMethod();
  @Override
  default void baseMethod() {}
}
''',
    'DiamondRight': '''
public interface DiamondRight extends BaseInterface {
  int RIGHT_FIELD = 2;
  void rightMethod();
  @Override
  default void baseMethod() {}
}
''',
    'DagA': '''
public interface DagA {
  int A_FIELD = 3;
  void aMethod();
}
''',
    'DagB': '''
public interface DagB extends DagA {
  int B_FIELD = 4;
  void bMethod();
}
''',
    'DagC': '''
public interface DagC extends DagA, DagB {
  int C_FIELD = 5;
  void cMethod();
}
''',
    'DagD': '''
public interface DagD extends DagA, DagB, DagC {
  int D_FIELD = 6;
  void dMethod();
}
''',
    'DagE': '''
public interface DagE extends DagB, DagD {
  int E_FIELD = 7;
  void eMethod();
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
    final content = entry.value.trim();
    final isOrgJetbrains = content.startsWith('package org.jetbrains.annotations;');
    final relativePath = isOrgJetbrains
        ? 'org/jetbrains/annotations/${entry.key}.java'
        : 'com/example/${entry.key}.java';
    final file = File(p.join(baseDir.path, relativePath));
    file.parent.createSync(recursive: true);

    final packageLine = content.startsWith('package ')
        ? ''
        : 'package com.example;\n\n';
    file.writeAsStringSync('''
$_copyrightHeader
$packageLine$content
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
  final typeKind = tc.get<MemberType>();
  final isArray = tc.get<IsArray>();
  final memberNullability = tc.get<MemberNullability>();
  final genericNullability = tc.get<GenericNullability>();

  final typeStr = getJavaType(typeKind, isArray == IsArray.yes, generics,
      memberGenerics, memberNullability, genericNullability);
  final inheritanceStr = getInheritanceStr(inheritance, top, genericNullability);
  final genStr = getGenericsStr(generics, genericNullability);
  final typeParamsStr = getTypeParamsStr(generics);
  final memberGenStr = getMemberGenericsStr(memberGenerics, genericNullability);
  final topModStr = getTopLevelModifierStr(modifier, mod);
  final kind = getTopLevelKindStr(top);
  final params = getParamsStr(paramCount, typeStr);

  if (top == TopLevelKind.record) {
    sb.write('''
public record $className$genStr($typeStr field) $inheritanceStr {
${getInheritanceMethodsStr(inheritance, top)}}
''');
    return;
  }

  sb.write('''
public $topModStr$kind $className$genStr $inheritanceStr {
''');

  if (top == TopLevelKind.enum_) {
    sb.writeln(getEnumConstantsStr(member, paramCount, typeStr));
  }

  sb.write(getInheritanceMethodsStr(inheritance, top));

  sb.write(switch (member) {
    Member.field => getFieldStr(top, mod, typeStr),
    Member.method => getMethodStr(top, mod, memberGenStr, typeStr, name, params),
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

String getInheritanceStr(
    Inheritance inheritance, TopLevelKind top, GenericNullability gn) {
  final g = getGenericNullabilityStr(gn);
  switch (inheritance) {
    case Inheritance.none:
      return '';
    case Inheritance.extends_:
      if (top == TopLevelKind.interface) return ' extends OtherInterface';
      if (top == TopLevelKind.record) return '';
      return ' extends GrandParent';
    case Inheritance.implements_:
      if (top == TopLevelKind.interface) return ' extends OtherInterface';
      return ' implements OtherInterface';
    case Inheritance.multipleImplements:
      if (top == TopLevelKind.interface) {
        return ' extends OtherInterface, BaseInterface';
      }
      return ' implements OtherInterface, BaseInterface';
    case Inheritance.extendsGenericSpecialized:
      if (top == TopLevelKind.interface) {
        return ' extends GenericInterface<${g}String>';
      }
      if (top == TopLevelKind.record) {
        return ' implements GenericInterface<${g}String>';
      }
      return ' extends GenericParent<${g}String>';
    case Inheritance.extendsGenericUnspecialized:
      if (top == TopLevelKind.interface) return ' extends GenericInterface';
      if (top == TopLevelKind.record) return ' implements GenericInterface';
      return ' extends GenericParent';
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

String getInheritanceMethodsStr(Inheritance inheritance, TopLevelKind top) {
  final sb = StringBuffer();
  final isInterface = top == TopLevelKind.interface;

  void add(String decl, [String body = '{}']) {
    if (isInterface) {
      sb.write('''
  @Override
  default $decl $body
''');
    } else {
      sb.write('''
  @Override
  public $decl $body
''');
    }
  }

  switch (inheritance) {
    case Inheritance.none:
      break;
    case Inheritance.extends_:
      if (top == TopLevelKind.interface) {
        add('void otherInterfaceMethod()');
      } else if (top != TopLevelKind.record) {
        add('void grandParentMethod()');
      }
      break;
    case Inheritance.implements_:
      add('void otherInterfaceMethod()');
      break;
    case Inheritance.multipleImplements:
      add('void otherInterfaceMethod()');
      add('void baseMethod()');
      break;
    case Inheritance.extendsGenericSpecialized:
      if (top == TopLevelKind.interface || top == TopLevelKind.record) {
        add('String genericInterfaceMethod(String t)', ' { return t; }');
      } else {
        add('void genericParentMethod(String t)');
      }
      break;
    case Inheritance.extendsGenericUnspecialized:
      if (top == TopLevelKind.interface || top == TopLevelKind.record) {
        add('Object genericInterfaceMethod(Object t)', ' { return t; }');
      } else {
        add('void genericParentMethod(Object t)');
      }
      break;
    case Inheritance.diamond:
      add('void baseMethod()');
      add('void leftMethod()');
      add('void rightMethod()');
      break;
    case Inheritance.complexDag:
      add('void aMethod()');
      add('void bMethod()');
      add('void cMethod()');
      add('void dMethod()');
      add('void eMethod()');
      break;
  }
  return sb.toString();
}

String getGenericNullabilityStr(GenericNullability gn) {
  return switch (gn) {
    GenericNullability.none => '',
    GenericNullability.nullable => '@Nullable ',
    GenericNullability.nonnull => '@NotNull ',
  };
}

String getMemberNullabilityStr(MemberNullability mn) {
  return switch (mn) {
    MemberNullability.none => '',
    MemberNullability.nullable => '@Nullable ',
    MemberNullability.nonnull => '@NotNull ',
  };
}

String getGenericsStr(Generics generics, GenericNullability gn) {
  final g = getGenericNullabilityStr(gn);
  return switch (generics) {
    Generics.none => '',
    Generics.oneParam => '<${g}T>',
    Generics.twoParams => '<${g}T, ${g}U>',
    Generics.upperBound => '<${g}T extends Number>',
    Generics.lowerBound => '<${g}T>',
    Generics.wildcard => '<${g}T>',
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

String getMemberGenericsStr(
    MemberGenerics memberGenerics, GenericNullability gn) {
  final g = getGenericNullabilityStr(gn);
  return switch (memberGenerics) {
    MemberGenerics.none => '',
    MemberGenerics.oneParam => '<${g}S> ',
    MemberGenerics.twoParams => '<${g}S, ${g}V> ',
    MemberGenerics.upperBound => '<${g}S extends Number> ',
    MemberGenerics.lowerBound => '<${g}S> ',
    MemberGenerics.wildcard => '<${g}S> ',
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

bool isPrimitive(MemberType type) {
  return type == MemberType.int_ ||
      type == MemberType.long_ ||
      type == MemberType.short_ ||
      type == MemberType.float_ ||
      type == MemberType.double_ ||
      type == MemberType.byte_ ||
      type == MemberType.boolean_ ||
      type == MemberType.char_ ||
      type == MemberType.void_;
}

String getJavaType(MemberType kind, bool isArray, Generics generics,
    MemberGenerics mGenerics, MemberNullability mn, GenericNullability gn) {
  final useMemberScope = mGenerics != MemberGenerics.none;

  final scopeVar = useMemberScope ? 'S' : 'T';
  final scopeEnum = useMemberScope ? mGenerics : generics;

  final ggn = getGenericNullabilityStr(gn);
  final mmn = getMemberNullabilityStr(mn);

  final g = switch (scopeEnum) {
    Generics.oneParam || MemberGenerics.oneParam => '$ggn$scopeVar',
    Generics.twoParams || MemberGenerics.twoParams => '$ggn$scopeVar',
    Generics.upperBound || MemberGenerics.upperBound => '$ggn$scopeVar',
    Generics.lowerBound || MemberGenerics.lowerBound => '? super $ggn$scopeVar',
    Generics.wildcard || MemberGenerics.wildcard => '?',
    _ => '${mmn}String',
  };

  var t = switch (kind) {
    MemberType.void_ => 'void',
    MemberType.boolean_ => 'boolean',
    MemberType.char_ => 'char',
    MemberType.int_ => 'int',
    MemberType.long_ => 'long',
    MemberType.short_ => 'short',
    MemberType.float_ => 'float',
    MemberType.double_ => 'double',
    MemberType.byte_ => 'byte',
    MemberType.object => 'Object',
    MemberType.string => 'String',
    MemberType.typeParam => 'T',
    MemberType.memberTypeParam => 'S',
    MemberType.list => 'List<$g>',
    MemberType.set => 'Set<$g>',
    MemberType.map => 'Map<$g, $g>',
    MemberType.customObject => 'CustomObject<$g>',
    MemberType.customInterface => 'CustomInterface<$g>',
    MemberType.customEnum => 'CustomEnum',
    MemberType.customRecord => 'CustomRecord<$g>',
    MemberType.nestedCustom => 'NestedCustom<$g, $g>.Nested<$g>',
  };
  if (isArray) {
    if (isPrimitive(kind)) {
      return '$t $mmn[]';
    }
    return '$mmn$t[]';
  }
  return isPrimitive(kind) ? t : '$mmn$t';
}

String getJavaDefaultValue(String type) {
  if (type.endsWith('[]')) {
    return 'null';
  }
  switch (type) {
    case 'void':
      return '';
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
    case 'CustomEnum':
      return 'CustomEnum.V1';
    default:
      return 'null';
  }
}
