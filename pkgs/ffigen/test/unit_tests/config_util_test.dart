import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator.dart' as code_gen;
import 'package:test/test.dart';

import '../test_utils.dart';

Struct createStruct(String name) {
  final generator = FfiGenerator(
    input: const Input(entryPoints: []),
    output: Output(dartFile: Uri.file('unused.dart')),
  );
  return Struct(
    code_gen.Struct(
      context: testContext(generator),
      name: name,
      originalName: name,
      usr: name,
    ),
  );
}

void main() {
  group('Visitor utils', () {
    test('IncludeSetVisitor', () {
      final visitor = IncludeSetVisitor(structs: {'foo', 'bar'});
      final structFoo = createStruct('foo');
      final structBaz = createStruct('baz');
      visitor.visitStruct(structFoo);
      visitor.visitStruct(structBaz);
      expect(structFoo.isIncluded, isTrue);
      expect(structBaz.isIncluded, isFalse);
    });

    test('RenameMapVisitor', () {
      final visitor = RenameMapVisitor({'foo': 'bar'});
      final structFoo = createStruct('foo');
      final structBaz = createStruct('baz');
      visitor.visitStruct(structFoo);
      visitor.visitStruct(structBaz);
      expect(structFoo.name, 'bar');
      expect(structBaz.name, 'baz');
    });
  });
}
