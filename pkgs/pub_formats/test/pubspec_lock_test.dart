// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:pub_formats/pubspec_formats.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('pubspec lock', () {
    final packageRoot = findPackageRoot('pub_formats');
    final pubspecFile = File.fromUri(
      packageRoot.resolve('test_data/pubspec_lock_1.yaml'),
    );
    final json = _convertYamlMapToJsonMap(
      loadYaml(pubspecFile.readAsStringSync()),
    );
    final parsed = PubspecLockFileSyntax.fromJson(json);
    final errors = parsed.validate();
    expect(errors, isEmpty);
    final package = parsed.packages!['dart_apitool']!;
    expect(package.source, PackageSourceSyntax.hosted);

    final description = HostedPackageDescriptionSyntax.fromJson(
      package.description.json,
    );
    expect(description.sha256, isNotEmpty);
  });

  test('pubspec lock errors', () {
    final packageRoot = findPackageRoot('pub_formats');
    final pubspecFile = File.fromUri(
      packageRoot.resolve('test_data/pubspec_lock_errors_1.yaml'),
    );
    final json = _convertYamlMapToJsonMap(
      loadYaml(pubspecFile.readAsStringSync()),
    );
    final parsed = PubspecLockFileSyntax.fromJson(json);
    final errors = parsed.validate();
    // The errors inside the descriptions are not found due to
    // https://github.com/dart-lang/native/issues/2440.
    expect(errors, equals([]));

    final package = parsed.packages!['dart_apitool']!;
    expect(package.source, PackageSourceSyntax.hosted);

    final description = HostedPackageDescriptionSyntax.fromJson(
      package.description.json,
    );
    final errorsDescription = description.validate();
    expect(
      errorsDescription,
      equals([
        "Unexpected value 'not a valid name' (String) for 'name'. Expected a String satisfying ^[a-zA-Z_]\\w*\$.",
        "Unexpected value 'not a valid sha' (String) for 'sha256'. Expected a String satisfying ^[a-f0-9]{64}\$.",
      ]),
    );
    expect(() => description.sha256, throwsFormatException);

    expect(
      () => HostedPackageDescriptionSyntax(
        name: 'my_package',
        sha256:
            '2fde1607386ab523f7a36bb3e7edb43bd58e6edaf2ffb29d8a6d578b297fdbbd',
        url: 'https://pub.dev',
      ),
      isNot(throwsArgumentError),
    );
    expect(
      () => HostedPackageDescriptionSyntax(
        name: 'my_package',
        sha256: 'notASha256',
        url: 'https://pub.dev',
      ),
      throwsArgumentError,
    );
  });
}

Map<String, Object?> _convertYamlMapToJsonMap(YamlMap yamlMap) {
  final Map<String, Object?> jsonMap = {};
  yamlMap.forEach((key, value) {
    if (key is! String) {
      // Handle non-string keys if your YAML allows them, or throw an error.
      // For typical JSON conversion, keys are expected to be strings.
      throw ArgumentError('YAML map keys must be strings for JSON conversion.');
    }
    jsonMap[key] = _convertYamlValue(value);
  });
  return jsonMap;
}

Object? _convertYamlValue(dynamic yamlValue) {
  if (yamlValue is YamlMap) {
    return _convertYamlMapToJsonMap(yamlValue);
  } else if (yamlValue is YamlList) {
    return yamlValue.map((e) => _convertYamlValue(e)).toList();
  } else {
    // For primitive types (String, int, double, bool, null)
    return yamlValue;
  }
}
