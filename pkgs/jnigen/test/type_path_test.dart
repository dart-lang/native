import 'package:jnigen/jnigen.dart';
import 'package:test/test.dart';

void main() {
  test('Type path parsing', () {
    const string = '0;.3;[14;*';
    final typePath = typePathFromString(string);
    expect(typePath, const [
      ToTypeParam(0),
      ToInnerClass(),
      ToTypeParam(3),
      ToArrayElement(),
      ToTypeParam(14),
      ToWildcardBound(),
    ]);
    expect(typePath.join(), string);
  });
}
