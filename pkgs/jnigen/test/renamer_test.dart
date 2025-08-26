// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/bindings/linker.dart';
// import 'package:jnigen/src/bindings/renamer.dart';
import 'package:test/test.dart';

extension on Iterable<Renamable> {
  List<String> get finalNames => map((c) => c.finalName!).toList();
}

Future<void> rename(Classes classes) async {
  final config = Config(
    outputConfig: OutputConfig(
      dartConfig: DartCodeOutputConfig(
        path: Uri.file('test.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
    classes: [],
  );
  await classes.accept(Linker(config));
  // classes.accept(Renamer(config));
}

void main() {
  test('Overloading elements that end with a number', () async {
    final classes = Classes({
      'Foo': ClassDecl(
        binaryName: 'Foo',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [
          Method(name: 'foo', returnType: DeclaredType.object),
          Method(name: 'foo', returnType: DeclaredType.object),
          Method(name: 'foo', returnType: DeclaredType.object),
          Method(name: 'foo1', returnType: DeclaredType.object),
          Method(name: 'foo1', returnType: DeclaredType.object),
          Method(name: 'foo1', returnType: DeclaredType.object),
        ],
      ),
      'x.Foo': ClassDecl(
        binaryName: 'x.Foo',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [
          Method(name: 'foo', returnType: DeclaredType.object),
          Method(name: 'foo', returnType: DeclaredType.object),
          Method(name: 'foo1', returnType: DeclaredType.object),
          Method(name: 'foo1', returnType: DeclaredType.object),
        ],
        fields: [
          Field(name: 'foo', type: DeclaredType.object),
          Field(name: 'foo1', type: DeclaredType.object),
        ],
      ),
      'y.Foo': ClassDecl(
        binaryName: 'y.Foo',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
      ),
      'Foo1': ClassDecl(
        binaryName: 'Foo1',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
      ),
      'x.Foo1': ClassDecl(
        binaryName: 'x.Foo1',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
      ),
      'y.Foo1': ClassDecl(
        binaryName: 'y.Foo1',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
      ),
    });
    await rename(classes);

    final renamedClasses = classes.decls.values.finalNames;
    expect(renamedClasses, [
      'Foo',
      r'Foo$1',
      r'Foo$2',
      'Foo1',
      r'Foo1$1',
      r'Foo1$2',
    ]);

    final renamedMethods = classes.decls['Foo']!.methods.finalNames;
    expect(renamedMethods, [
      'foo',
      r'foo$1',
      r'foo$2',
      'foo1',
      r'foo1$1',
      r'foo1$2',
    ]);

    final renamedFields = classes.decls['x.Foo']!.fields.finalNames;
    // Fields are renamed before methods. So they always keep their original
    // name (if not renamed for a different reason).
    expect(renamedFields, [
      'foo',
      'foo1',
    ]);
    final xFooMethods = classes.decls['x.Foo']!.methods.finalNames;
    expect(xFooMethods, [
      r'foo$1',
      r'foo$2',
      r'foo1$1',
      r'foo1$2',
    ]);
  });

  test('Field with the same name as inherited method gets renamed', () async {
    final classes = Classes({
      'Player': ClassDecl(
        binaryName: 'Player',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [
          Method(name: 'duck', returnType: DeclaredType.object),
        ],
      ),
      'DuckOwningPlayer': ClassDecl(
        binaryName: 'DuckOwningPlayer',
        declKind: DeclKind.classKind,
        superclass: DeclaredType(binaryName: 'Player'),
        fields: [
          Field(name: 'duck', type: DeclaredType.object),
        ],
      ),
    });
    await rename(classes);

    final renamedMethods = classes.decls['Player']!.methods.finalNames;
    expect(renamedMethods, ['duck']);
    final renamedFields = classes.decls['DuckOwningPlayer']!.fields.finalNames;
    expect(renamedFields, [r'duck$1']);
  });

  test('Keywords in names', () async {
    final classes = Classes({
      'Foo': ClassDecl(
        binaryName: 'Foo',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [
          Method(name: 'yield', returnType: DeclaredType.object),
          Method(name: 'const', returnType: DeclaredType.object),
          Method(name: 'const', returnType: DeclaredType.object),
        ],
        fields: [
          Field(name: 'const', type: DeclaredType.object),
        ],
      ),
      'Function': ClassDecl(
        binaryName: 'Function',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
      ),
    });
    await rename(classes);

    final renamedMethods = classes.decls['Foo']!.methods.finalNames;
    expect(renamedMethods, [r'yield$', r'const$1', r'const$2']);
    final renamedFields = classes.decls['Foo']!.fields.finalNames;

    expect(renamedFields, [r'const$']);
    final renamedClasses = classes.decls.values.finalNames;
    expect(renamedClasses, ['Foo', r'Function$']);
  });

  test('Names with existing dollar signs', () async {
    final classes = Classes({
      'Foo': ClassDecl(
        binaryName: 'Foo',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [
          Method(name: 'foo', returnType: DeclaredType.object),
          Method(name: 'foo', returnType: DeclaredType.object),
          Method(name: r'foo$1', returnType: DeclaredType.object),
          Method(
              name: r'$$Many$Dollar$$Signs$', returnType: DeclaredType.object),
          Method(name: 'alsoAField', returnType: DeclaredType.object),
          Method(name: 'alsoAField', returnType: DeclaredType.object),
        ],
        fields: [
          Field(name: r'alsoAField', type: DeclaredType.object),
          Field(name: r'alsoAField$1', type: DeclaredType.object),
        ],
      ),
    });
    await rename(classes);

    final renamedMethods = classes.decls['Foo']!.methods.finalNames;
    expect(renamedMethods, [
      'foo',
      r'foo$1',
      r'foo$$1',
      r'$$$$Many$$Dollar$$$$Signs$$',
      r'alsoAField$1',
      r'alsoAField$2',
    ]);

    final renamedFields = classes.decls['Foo']!.fields.finalNames;
    expect(renamedFields, [
      'alsoAField',
      r'alsoAField$$1',
    ]);
  });

  test('Names that start with underscores', () async {
    final classes = Classes({
      '_Foo': ClassDecl(
        binaryName: '_Foo',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [
          Method(name: '_foo', returnType: DeclaredType.object),
        ],
        fields: [
          Field(name: '_bar', type: DeclaredType.object),
        ],
      ),
    });
    await rename(classes);

    final renamedMethods = classes.decls['_Foo']!.methods.finalNames;
    expect(renamedMethods, [r'$_foo']);
    final renamedFields = classes.decls['_Foo']!.fields.finalNames;
    expect(renamedFields, [r'$_bar']);
    final renamedClasses = classes.decls.values.finalNames;
    expect(renamedClasses, [r'$_Foo']);
  });

  test('Combination of underscore, dollar signs, and overloading', () async {
    // TODO(https://github.com/dart-lang/native/issues/1544): Test class names
    // containing dollar signs.
    final classes = Classes({
      r'_Foo$': ClassDecl(
        binaryName: r'_Foo$',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [
          Method(name: r'_foo$', returnType: DeclaredType.object),
          Method(name: r'_foo$', returnType: DeclaredType.object),
        ],
        fields: [
          Field(name: r'_foo$', type: DeclaredType.object),
        ],
      ),
    });
    await rename(classes);

    final renamedMethods = classes.decls[r'_Foo$']!.methods.finalNames;
    expect(renamedMethods, [r'$_foo$$$1', r'$_foo$$$2']);
    final renamedFields = classes.decls[r'_Foo$']!.fields.finalNames;
    expect(renamedFields, [r'$_foo$$']);
  });

  test('Interface implementation methods', () async {
    final classes = Classes({
      'MyInterface': ClassDecl(
        binaryName: 'MyInterface',
        declKind: DeclKind.interfaceKind,
        superclass: DeclaredType.object,
        methods: [
          Method(name: 'implement', returnType: DeclaredType.object),
          Method(name: 'implementIn', returnType: DeclaredType.object),
        ],
      ),
      'MyClass': ClassDecl(
        binaryName: 'MyClass',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [
          Method(name: 'implement', returnType: DeclaredType.object),
          Method(name: 'implementIn', returnType: DeclaredType.object),
        ],
      ),
    });
    await rename(classes);

    final interfaceRenamedMethods =
        classes.decls['MyInterface']!.methods.finalNames;
    expect(interfaceRenamedMethods, [r'implement$1', r'implementIn$1']);
    final classRenamedMethods = classes.decls['MyClass']!.methods.finalNames;
    expect(classRenamedMethods, [r'implement', r'implementIn']);
  });

  test('Inner classes vs classes with dollar signs', () async {
    final classes = Classes({
      'Outer': ClassDecl(
        binaryName: 'Outer',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [],
      ),
      r'Outer$Inner': ClassDecl(
        binaryName: r'Outer$Inner',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [],
        outerClassBinaryName: 'Outer',
      ),
      r'Outer$Inner$Innermost': ClassDecl(
        binaryName: r'Outer$Inner$Innermost',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [],
        outerClassBinaryName: r'Outer$Inner',
      ),
      r'Outer$With$Many$Dollarsigns': ClassDecl(
        binaryName: r'Outer$With$Many$Dollarsigns',
        declKind: DeclKind.classKind,
        superclass: DeclaredType.object,
        methods: [],
      ),
    });
    await rename(classes);
    expect(classes.decls['Outer']!.finalName, 'Outer');
    expect(classes.decls[r'Outer$Inner']!.finalName, r'Outer$Inner');
    expect(classes.decls[r'Outer$Inner$Innermost']!.finalName,
        r'Outer$Inner$Innermost');
    expect(classes.decls[r'Outer$With$Many$Dollarsigns']!.finalName,
        r'Outer$$With$$Many$$Dollarsigns');
  });
}
