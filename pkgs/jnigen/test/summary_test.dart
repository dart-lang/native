// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// These tests validate individual characteristics in summary
// For example, the values of methods, arguments, types, generic params etc...
@Tags(['summarizer_test'])

import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/summary/summary.dart';
import 'package:test/test.dart';

import 'test_util/summary_util.dart';
import 'test_util/test_util.dart';

const jnigenPackage = 'com.github.dart_lang.jnigen';
const simplePackage = "$jnigenPackage.simple_package";

extension on Classes {
  String _getSimpleName(ClassDecl c) {
    return c.binaryName.split(".").last;
  }

  ClassDecl getClassBySimpleName(String simpleName) {
    return decls.values.firstWhere((c) => _getSimpleName(c) == simpleName);
  }

  ClassDecl getClass(String dirName, String className) {
    return decls['$jnigenPackage.$dirName.$className']!;
  }

  ClassDecl getExampleClass() {
    return getClass('simple_package', 'Example');
  }
}

extension on ClassDecl {
  Method getMethod(String name) => methods.firstWhere((m) => m.name == name);
  Field getField(String name) => fields.firstWhere((f) => f.name == name);
}

void registerCommonTests(Classes classes) {
  test('static modifier', () {
    final example = classes.getExampleClass();
    final containsStatic = contains("static");
    final notContainsStatic = isNot(containsStatic);
    expect(example.getMethod("max4").modifiers, containsStatic);
    expect(example.getMethod("getCodename").modifiers, notContainsStatic);
    expect(example.getField("ON").modifiers, containsStatic);
    expect(example.getField("codename").modifiers, notContainsStatic);
    final nested = classes.getClassBySimpleName("Example\$Nested");
    expect(nested.modifiers, containsStatic);
    final nonStaticNested =
        classes.getClassBySimpleName("Example\$NonStaticNested");
    expect(nonStaticNested.modifiers, notContainsStatic);
  });

  test('Public, protected and private modifiers', () {
    final example = classes.getExampleClass();
    final hasPrivate = contains("private");
    final hasProtected = contains("protected");
    final hasPublic = contains("public");
    final isPrivate = allOf(hasPrivate, isNot(hasProtected), isNot(hasPublic));
    final isProtected =
        allOf(isNot(hasPrivate), hasProtected, isNot(hasPublic));
    final isPublic = allOf(isNot(hasPrivate), isNot(hasProtected), hasPublic);
    expect(example.getMethod("getNumber").modifiers, isPublic);
    expect(example.getMethod("privateMethod").modifiers, isPrivate);
    expect(example.getMethod("protectedMethod").modifiers, isProtected);
    expect(example.getField("OFF").modifiers, isPublic);
    expect(example.getField("number").modifiers, isPrivate);
    expect(example.getField("protectedField").modifiers, isProtected);
  });

  test('final modifier', () {
    final example = classes.getExampleClass();
    final isFinal = contains('final');
    expect(example.getField("PI").modifiers, isFinal);
    expect(example.getField("unusedRandom").modifiers, isFinal);
    expect(example.getField("number").modifiers, isNot(isFinal));
    expect(example.getMethod("finalMethod").modifiers, isFinal);
  });

  void assertToBeStringListType(TypeUsage listType) {
    expect(listType.kind, equals(Kind.declared));
    final listClassType = listType.type as DeclaredType;
    expect(listClassType.binaryName, equals('java.util.List'));
    expect(listClassType.params, hasLength(1));
    final listTypeParam = listClassType.params[0];
    expect(listTypeParam.kind, equals(Kind.declared));
    expect(listTypeParam.type.name, equals('java.lang.String'));
  }

  test('return types', () {
    final example = classes.getExampleClass();
    expect(example.getMethod("getNumber").returnType.shorthand, equals("int"));
    expect(example.getMethod("getName").returnType.shorthand,
        equals("java.lang.String"));
    expect(example.getMethod("getNestedInstance").returnType.name,
        equals("$simplePackage.Example\$Nested"));
    final listType = example.getMethod("getList").returnType;
    assertToBeStringListType(listType);
  });

  test('parameter types', () {
    final example = classes.getExampleClass();
    final joinStrings = example.getMethod('joinStrings');
    final listType = joinStrings.params[0].type;
    assertToBeStringListType(listType);
    final stringType = joinStrings.params[1].type;
    expect(stringType.kind, Kind.declared);
    expect((stringType.type as DeclaredType).binaryName, 'java.lang.String');
  });

  test('Parameters of several types', () {
    final example = classes.getExampleClass();
    final method = example.getMethod('methodWithSeveralParams');
    expect(method.typeParams, hasLength(1));
    expect(method.typeParams[0].name, 'T');
    expect(method.typeParams[0].bounds[0].name, 'java.lang.CharSequence');

    final charParam = method.params[0];
    expect(charParam.type.kind, equals(Kind.primitive));
    expect(charParam.type.name, equals('char'));

    final stringParam = method.params[1];
    expect(stringParam.type.kind, equals(Kind.declared));
    expect((stringParam.type.type as DeclaredType).binaryName,
        equals('java.lang.String'));

    final arrayParam = method.params[2];
    expect(arrayParam.type.kind, equals(Kind.array));
    expect((arrayParam.type.type as ArrayType).type.name, equals('int'));

    final typeVarParam = method.params[3];
    expect(typeVarParam.type.kind, equals(Kind.typeVariable));
    expect((typeVarParam.type.type as TypeVar).name, equals('T'));

    final listParam = method.params[4];
    expect(listParam.type.kind, equals(Kind.declared));
    final listType = (listParam.type.type as DeclaredType);
    expect(listType.binaryName, equals('java.util.List'));
    expect(listType.params, hasLength(1));
    final tType = listType.params[0];
    expect(tType.kind, Kind.typeVariable);
    expect((tType.type as TypeVar).name, equals('T'));

    final wildcardMapParam = method.params[5];
    expect(wildcardMapParam.type.kind, equals(Kind.declared));
    final mapType = (wildcardMapParam.type.type as DeclaredType);
    expect(mapType.binaryName, equals('java.util.Map'));
    expect(mapType.params, hasLength(2));
    final strType = mapType.params[0];
    expect(strType.name, 'java.lang.String');
    // TODO(#141): Wildcard implementation.
    /*
    final wildcardType = mapType.params[1];
    expect(wildcardType.kind, equals(Kind.wildcard));
    expect((wildcardType.type as Wildcard).extendsBound?.name,
        equals('java.lang.CharSequence'));
    */
  });

  test('superclass', () {
    final baseClass = classes.getClass('inheritance', 'BaseClass');
    expect(baseClass.typeParams, hasLength(1));
    final typeParam = baseClass.typeParams.single;
    expect(typeParam.bounds.map((b) => b.name).toList(),
        ['java.lang.CharSequence']);

    final specific = classes.getClass('inheritance', 'SpecificDerivedClass');
    expect(specific.typeParams, hasLength(0));
    expect(specific.superclass, isNotNull);
    final specificSuper = specific.superclass!.type as DeclaredType;
    expect(specificSuper.params[0].type, isA<DeclaredType>());
    expect(specificSuper.params[0].type.name, equals('java.lang.String'));

    final generic = classes.getClass('inheritance', 'GenericDerivedClass');
    expect(generic.typeParams, hasLength(1));
    expect(generic.typeParams[0].name, equals('T'));
    expect(generic.typeParams[0].bounds.map((b) => b.name).toList(),
        ['java.lang.CharSequence']);
    expect(generic.superclass, isNotNull);
    final genericSuper = generic.superclass!.type as DeclaredType;
    expect(genericSuper.params[0].type, isA<TypeVar>());
    expect(genericSuper.params[0].type.name, equals('T'));
  });

  test('constructor is included', () {
    final example = classes.getExampleClass();
    void assertOneCtorExistsWithArity(List<String> paramTypes) {
      final arityCtors = example.methods
          .where(
              (m) => m.name == '<init>' && m.params.length == paramTypes.length)
          .toList();
      expect(arityCtors, hasLength(1));
      final ctor = arityCtors[0];
      expect(ctor.params.map((p) => p.type.name), equals(paramTypes));
    }

    assertOneCtorExistsWithArity([]);
    assertOneCtorExistsWithArity(['int']);
    assertOneCtorExistsWithArity(['int', 'boolean']);
    assertOneCtorExistsWithArity(['int', 'boolean', 'java.lang.String']);
  });

  test('Overloaded methods', () {
    final methods = classes
        .getExampleClass()
        .methods
        .where((m) => m.name == 'overloaded')
        .toList();
    final signatures =
        methods.map((m) => m.params.map((p) => p.type.name).toList()).toSet();
    expect(
      signatures,
      equals({
        <String>[],
        ['int'],
        ['int', 'java.lang.String'],
        ['java.util.List'],
        ['java.util.List', 'java.lang.String'],
      }),
    );
  });

  test('Declaration type (class vs interface vs enum)', () {
    final example = classes.getExampleClass();
    expect(example.declKind, DeclKind.classKind);
    final myInterface = classes.getClass('interfaces', 'MyInterface');
    expect(myInterface.declKind, DeclKind.interfaceKind);
    final color = classes.getClass('simple_package', 'Color');
    expect(color.declKind, DeclKind.enumKind);
  });

  test('Enum values', () {
    final example = classes.getExampleClass();
    expect(example.values, anyOf(isNull, isEmpty));
    final color = classes.getClass('simple_package', 'Color');
    const expectedEnumValues = {
      'RED',
      'BLUE',
      'BLACK',
      'GREEN',
      'YELLOW',
      'LIME'
    };
    expect(color.values?.toSet(), expectedEnumValues);
  });

  test('Static final field values', () {
    final example = classes.getExampleClass();
    expect(example.getField("ON").defaultValue, equals(1));
    expect(example.getField("OFF").defaultValue, equals(0));
    expect(example.getField("PI").defaultValue, closeTo(3.14159, 0.001));
    expect(
        example.getField("SEMICOLON").defaultValue, equals(';'.codeUnitAt(0)));
    expect(example.getField("SEMICOLON_STRING").defaultValue, equals(';'));
  });

  test('self referencing generic parameters', () {
    final gp = classes.getClass('generics', 'GenericTypeParams');
    final typeParams = gp.typeParams;
    expect(typeParams[0].name, equals('S'));
    expect(typeParams[0].bounds.map((e) => e.name), ['java.lang.CharSequence']);
    expect(typeParams[1].name, equals('K'));
    final selfBound = typeParams[1].bounds[0];
    expect(selfBound.kind, Kind.declared);
    expect(selfBound.name,
        equals('com.github.dart_lang.jnigen.generics.GenericTypeParams'));
    final selfBoundType = selfBound.type as DeclaredType;
    expect(selfBoundType.params, hasLength(2));
    expect(selfBoundType.params.map((e) => e.name), ['S', 'K']);
    expect(selfBoundType.params.map((e) => e.kind),
        [Kind.typeVariable, Kind.typeVariable]);
  });
}

void main() async {
  await checkLocallyBuiltDependencies();

  final tempDir = getTempDir("jnigen_summary_tests_");

  final sourceConfig =
      getSummaryGenerationConfig(sourcePath: [simplePackagePath]);
  final parsedFromSource = await getSummary(sourceConfig);

  final targetDir = tempDir.createTempSync("compiled_classes_test_");
  await compileJavaFiles(simplePackageDir, targetDir);
  final classConfig = getSummaryGenerationConfig(classPath: [targetDir.path]);
  final parsedFromClasses = await getSummary(classConfig);

  group('source summary', () {
    registerCommonTests(parsedFromSource);
  });

  group('compiled summary', () {
    registerCommonTests(parsedFromClasses);
  });

  group('source-based summary features', () {
    final classes = parsedFromSource;
    test('Parameter names', () {
      final example = classes.getExampleClass();
      final joinStrings = example.getMethod('joinStrings');
      expect(
          joinStrings.params.map((p) => p.name).toList(), ['values', 'delim']);
      final methodWithSeveralParams =
          example.getMethod("methodWithSeveralParams");
      expect(methodWithSeveralParams.params.map((p) => p.name).toList(),
          ['ch', 's', 'a', 't', 'lt', 'wm']);
    });

    test('Javadoc comment', () {
      final example = classes.getExampleClass();
      final joinStrings = example.getMethod('joinStrings');
      expect(joinStrings.javadoc?.comment,
          contains("Joins the strings in the list using the given delimiter."));
    });
  });

  tearDownAll(() => tempDir.deleteSync(recursive: true));
}
