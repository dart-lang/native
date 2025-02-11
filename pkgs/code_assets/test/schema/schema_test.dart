import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';

import 'helpers.dart';

void main() {
  final schemasUri = packageUri.resolve('lib/schema/');
  final hookSchemasUri = packageUri.resolve('../hook/lib/schema/');

  final allSchemas = <Uri, Map<String, dynamic>>{};

  for (final dirUri in [schemasUri, hookSchemasUri]) {
    Directory.fromUri(dirUri).listSync().forEach((file) {
      file as File;
      final json = jsonDecode(file.readAsStringSync());
      allSchemas[file.uri] = json;
    });
  }

  final schemaUri = schemasUri.resolve('build_output.schema.json');
  final schemaJson = allSchemas[schemaUri]!;

  final schema = JsonSchema.create(
    schemaJson,
    refProvider: RefProvider.sync((String ref) {
      // TODO(dcharkes): Why are the refs mangled?
      if (ref.startsWith('/')) {
        ref = ref.substring(1);
      }
      if (ref.startsWith('hook/')) {
        ref = '../../../$ref';
      }
      final x = schemaUri.resolve(ref);
      return allSchemas[x]!;
    }),
  );

  final buildOutputUri = packageUri.resolve(
    'test/data/build_output_macos.json',
  );
  final buildOutputJson = jsonDecode(
    File.fromUri(buildOutputUri).readAsStringSync(),
  );
  final result = schema.validate(buildOutputJson);
  print(result);
}
