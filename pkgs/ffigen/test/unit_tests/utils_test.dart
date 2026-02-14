
import 'package:ffigen/src/code_generator/utils.dart';
import 'package:test/test.dart';

void main() {
  test('makeDeprecatedAnnotation', () {
    expect(makeDeprecatedAnnotation(null), '');
    expect(makeDeprecatedAnnotation(''), "@Deprecated('Deprecated')");
    expect(makeDeprecatedAnnotation('foo'), '@Deprecated("foo")');
    expect(makeDeprecatedAnnotation('foo "bar"'), r'@Deprecated("foo \"bar\"")');
    expect(makeDeprecatedAnnotation(r'foo $bar'), r'@Deprecated("foo \$bar")');
  });
}
