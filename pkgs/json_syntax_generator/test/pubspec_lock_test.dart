import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';
import 'package:json_syntax_generator/json_syntax_generator.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';

void main() {
  test('pubspec.lock schema', () {
    final packageRoot = findPackageRoot('json_syntax_generator');
    final schemaFile = File.fromUri(
      packageRoot.resolve('test_data/pubspec_lock/pubspec_lock.schema.json'),
    );
    final schemaJson = jsonDecode(schemaFile.readAsStringSync());
    final schema = JsonSchema.create(schemaJson as Object);

    final analyzedSchema = SchemaAnalyzer(
      schema,
      nameOverrides: {'path': 'path\$'},
    ).analyze();
    final output = SyntaxGenerator(
      analyzedSchema,
      header: '''
// This file is generated, do not edit.
''',
    ).generate();
    final goldenUri = packageRoot.resolve(
      'test_data/pubspec_lock/pubspec_lock_syntax.g.dart',
    );
    final tempUri = goldenUri.resolve('pubspec_lock_syntax_temp.g.dart');
    final goldenFile = File.fromUri(goldenUri);
    final tempFile = File.fromUri(tempUri);
    tempFile.writeAsStringSync(output);
    final formatResult = Process.runSync(Platform.executable, [
      'format',
      tempFile.path,
    ]);
    expect(formatResult.exitCode, equals(0));
    expect(tempFile.readAsStringSync(), goldenFile.readAsStringSync());
    tempFile.deleteSync();
  });
}
