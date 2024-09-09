import 'package:jnigen/src/bindings/linker.dart';
import 'package:jnigen/src/bindings/renamer.dart';
import 'package:jnigen/src/config/config.dart';
import 'package:jnigen/src/elements/elements.dart';
import 'package:test/test.dart';

Future<Config> testConfig() async {
  final config = Config(
    outputConfig: OutputConfig(
      dartConfig: DartCodeOutputConfig(
        path: Uri.file('test.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
    classes: ['Foo'],
  );
  return config;
}

void main() {
  test('Overloading elements that end with a number', () async {
    final classes = Classes({
      'Foo': ClassDecl(
        binaryName: 'Foo',
        declKind: DeclKind.classKind,
        superclass: TypeUsage.object,
        methods: [
          Method(name: 'foo', returnType: TypeUsage.object),
          Method(name: 'foo', returnType: TypeUsage.object),
          Method(name: 'foo', returnType: TypeUsage.object),
          Method(name: 'foo1', returnType: TypeUsage.object),
          Method(name: 'foo1', returnType: TypeUsage.object),
          Method(name: 'foo1', returnType: TypeUsage.object),
        ],
      ),
      'x.Foo': ClassDecl(
        binaryName: 'x.Foo',
        declKind: DeclKind.classKind,
        superclass: TypeUsage.object,
        methods: [
          Method(name: 'foo', returnType: TypeUsage.object),
          Method(name: 'foo', returnType: TypeUsage.object),
          Method(name: 'foo1', returnType: TypeUsage.object),
          Method(name: 'foo1', returnType: TypeUsage.object),
        ],
        fields: [
          Field(name: 'foo', type: TypeUsage.object),
          Field(name: 'foo1', type: TypeUsage.object),
        ],
      ),
      'y.Foo': ClassDecl(
        binaryName: 'y.Foo',
        declKind: DeclKind.classKind,
        superclass: TypeUsage.object,
      ),
      'Foo1': ClassDecl(
        binaryName: 'Foo1',
        declKind: DeclKind.classKind,
        superclass: TypeUsage.object,
      ),
      'x.Foo1': ClassDecl(
        binaryName: 'x.Foo1',
        declKind: DeclKind.classKind,
        superclass: TypeUsage.object,
      ),
      'y.Foo1': ClassDecl(
        binaryName: 'y.Foo1',
        declKind: DeclKind.classKind,
        superclass: TypeUsage.object,
      ),
    });
    final config = await testConfig();
    await classes.accept(Linker(config));
    classes.accept(Renamer(config));

    final renamedClasses =
        classes.decls.values.map((c) => c.finalName).toList();
    expect(renamedClasses, [
      'Foo',
      'Foo\$1',
      'Foo\$2',
      'Foo1',
      'Foo1\$1',
      'Foo1\$2',
    ]);

    final renamedMethods =
        classes.decls['Foo']!.methods.map((m) => m.finalName).toList();
    expect(renamedMethods, [
      'foo',
      'foo\$1',
      'foo\$2',
      'foo1',
      'foo1\$1',
      'foo1\$2',
    ]);

    final renamedFields =
        classes.decls['x.Foo']!.fields.map((f) => f.finalName).toList();
    // Fields are renamed before methods. So they always keep their original
    // name (if not renamed for a different reason).
    expect(renamedFields, [
      'foo',
      'foo1',
    ]);
    final xFooMethods =
        classes.decls['x.Foo']!.methods.map((m) => m.finalName).toList();
    expect(xFooMethods, [
      'foo\$1',
      'foo\$2',
      'foo1\$1',
      'foo1\$2',
    ]);
  });

  test('Field with the same name as inherited method gets renamed', () async {
    final classes = Classes({
      'Player': ClassDecl(
        binaryName: 'Player',
        declKind: DeclKind.classKind,
        superclass: TypeUsage.object,
        methods: [
          Method(name: 'duck', returnType: TypeUsage.object),
        ],
      ),
      'DuckOwningPlayer': ClassDecl(
        binaryName: 'DuckOwningPlayer',
        declKind: DeclKind.classKind,
        superclass:
            TypeUsage(shorthand: 'Player', kind: Kind.declared, typeJson: {})
              ..type = DeclaredType(binaryName: 'Player'),
        fields: [
          Field(name: 'duck', type: TypeUsage.object),
        ],
      ),
    });
    final config = await testConfig();
    await classes.accept(Linker(config));
    classes.accept(Renamer(config));

    final renamedMethods =
        classes.decls['Player']!.methods.map((m) => m.finalName).toList();
    expect(renamedMethods, ['duck']);
    final renamedFields = classes.decls['DuckOwningPlayer']!.fields
        .map((f) => f.finalName)
        .toList();
    expect(renamedFields, ['duck\$1']);
  });

  test('Keywords in names', () async {
    final classes = Classes({
      'Foo': ClassDecl(
        binaryName: 'Foo',
        declKind: DeclKind.classKind,
        superclass: TypeUsage.object,
        methods: [
          Method(name: 'yield', returnType: TypeUsage.object),
          Method(name: 'const', returnType: TypeUsage.object),
          Method(name: 'const', returnType: TypeUsage.object),
        ],
        fields: [
          Field(name: 'const', type: TypeUsage.object),
        ],
      ),
      'Function': ClassDecl(
        binaryName: 'Function',
        declKind: DeclKind.classKind,
        superclass: TypeUsage.object,
      ),
    });
    final config = await testConfig();
    await classes.accept(Linker(config));
    classes.accept(Renamer(config));

    final renamedMethods =
        classes.decls['Foo']!.methods.map((m) => m.finalName).toList();
    expect(renamedMethods, ['yield\$', 'const\$1', 'const\$2']);
    final renamedFields =
        classes.decls['Foo']!.fields.map((f) => f.finalName).toList();

    expect(renamedFields, ['const\$']);
    final renamedClasses =
        classes.decls.values.map((c) => c.finalName).toList();
    expect(renamedClasses, ['Foo', 'Function\$']);
  });
}
