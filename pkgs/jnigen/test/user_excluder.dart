import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/elements/simple_elements.dart';
import 'package:jnigen/src/elements/user_excluder.dart';
import 'package:test/test.dart';

void main() {
  test('Exclude something using the user excluder, Simple AST', () async {
    final classes = Classes({
      'Foo': ClassDecl(
        binaryName: 'Foo',
        declKind: DeclKind.classKind,
        superclass: TypeUsage.object,
        methods: [
          Method(name: 'foo', returnType: TypeUsage.object),
          Method(name: 'Bar', returnType: TypeUsage.object),
          Method(name: 'foo1', returnType: TypeUsage.object),
          Method(name: 'Bar', returnType: TypeUsage.object),
        ],
        fields: [
          Field(name: 'foo', type: TypeUsage.object),
          Field(name: 'Bar', type: TypeUsage.object),
          Field(name: 'foo1', type: TypeUsage.object),
          Field(name: 'Bar', type: TypeUsage.object),
        ],
      ),
      'y.Foo': ClassDecl(
          binaryName: 'y.Foo',
          declKind: DeclKind.classKind,
          superclass: TypeUsage.object,
          methods: [
            Method(name: 'foo', returnType: TypeUsage.object),
            Method(name: 'Bar', returnType: TypeUsage.object),
          ],
          fields: [
            Field(name: 'foo', type: TypeUsage.object),
            Field(name: 'Bar', type: TypeUsage.object),
          ]),
    });

    final simpleClasses = SimpleClasses(classes);
    simpleClasses.accept(UserExcluder());

    expect(classes.decls.containsKey('y.Foo'), false);
    expect(classes.decls.containsKey('Foo'), true);

    expect(classes.decls['Foo']?.fields.length, 2);
    expect(classes.decls['Foo']?.fields[0].name, 'foo');
    expect(classes.decls['Foo']?.fields[1].name, 'foo1');

    expect(classes.decls['Foo']?.methods.length, 2);
    expect(classes.decls['Foo']?.methods[0].name, 'foo');
    expect(classes.decls['Foo']?.methods[1].name, 'foo1');
  });
}
