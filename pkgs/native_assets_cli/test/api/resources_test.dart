import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  const resourceFile = '''{
  "_comment": "Resources referenced by annotated resource identifiers",
  "AppTag": "TBD",
  "environment": {
    "dart.tool.dart2js": false
  },
  "identifiers": []
}''';
  test('empty resources parsing', () {
    final resourceIdentifiers = ResourceIdentifiers.fromFile(resourceFile);
    expect(resourceIdentifiers.identifiers, isEmpty);
  });
}
