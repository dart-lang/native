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
        fields: [
          Field(name: 'foo', type: TypeUsage.object),
          Field(name: 'foo', type: TypeUsage.object),
          Field(name: 'foo', type: TypeUsage.object),
          Field(name: 'foo1', type: TypeUsage.object),
          Field(name: 'foo1', type: TypeUsage.object),
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
      'Foo1',
      'Foo2',
      'Foo1\$',
      'Foo1\$1',
      'Foo1\$2',
    ]);

    final renamedMethods =
        classes.decls['Foo']!.methods.map((m) => m.finalName).toList();
    expect(renamedMethods, [
      'foo',
      'foo1',
      'foo2',
      'foo1\$',
      'foo1\$1',
      'foo1\$2',
    ]);

    final renamedFields =
        classes.decls['x.Foo']!.fields.map((f) => f.finalName).toList();
    expect(renamedFields, [
      'foo',
      'foo1',
      'foo2',
      'foo1\$',
      'foo1\$1',
      'foo1\$2',
    ]);
  });
}
