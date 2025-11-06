// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_formats/pub_formats.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('pubspec lock', () {
    final json = loadYamlAsJson('test_data/pubspec_lock_1.yaml');
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
    final json = loadYamlAsJson('test_data/pubspec_lock_errors_1.yaml');
    final parsed = PubspecLockFileSyntax.fromJson(json);
    final errors = parsed.validate();
    // The errors inside the descriptions are not found due to
    // https://github.com/dart-lang/native/issues/2440.
    expect(errors, equals([]));

    final package = parsed.packages!['dart_apitool']!;
    expect(package.source, PackageSourceSyntax.hosted);

    final description = HostedPackageDescriptionSyntax.fromJson(
      package.description.json,
      path: package.description.path,
    );
    final errorsDescription = description.validate();
    expect(
      errorsDescription,
      equals([
        "Unexpected value 'not a valid name' (String) for 'dart_apitool.description.name'. Expected a String satisfying ^[a-zA-Z_]\\w*\$.",
        "Unexpected value 'not a valid sha' (String) for 'dart_apitool.description.sha256'. Expected a String satisfying ^[a-f0-9]{64}\$.",
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

  test('pubspec lock errors', () {
    final json = loadYamlAsJson('test_data/pubspec_lock_errors_2.yaml');
    final parsed = PubspecLockFileSyntax.fromJson(json);
    final errors = parsed.validate();
    expect(
      errors,
      equals([
        "Unexpected key 'not a valid package name' in 'packages'. Expected a key satisfying ^[a-zA-Z_]\\w*\$.",
      ]),
    );

    expect(() => parsed.packages, throwsFormatException);

    final packageSyntax = PackageSyntax(
      dependency: DependencyTypeSyntax.directMain,
      description: HostedPackageDescriptionSyntax(
        name: 'valid_package_name',
        sha256:
            '2fde1607386ab523f7a36bb3e7edb43bd58e6edaf2ffb29d8a6d578b297fdbbd',
        url: 'https://pub.dev',
      ),
      source: PackageSourceSyntax.hosted,
      version: '1.2.3',
    );
    final sdKsSyntax = SDKsSyntax(dart: '1.2.3');
    expect(
      () => PubspecLockFileSyntax(
        sdks: sdKsSyntax,
        packages: {'valid_package_name': packageSyntax},
      ),
      isNot(throwsArgumentError),
    );
    expect(
      () => PubspecLockFileSyntax(
        sdks: sdKsSyntax,
        packages: {'not a valid package name': packageSyntax},
      ),
      throwsArgumentError,
    );
  });
}
