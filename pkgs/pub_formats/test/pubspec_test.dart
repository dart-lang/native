// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_formats/pub_formats.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('pubspec', () {
    final json = loadYamlAsJson('test_data/pubspec_1.yaml');
    final syntax = PubspecYamlFileSyntax.fromJson(json);
    expect(syntax.validate(), isEmpty);
    expect(syntax.name, equals('some_test_pubspec_package_name'));
    expect(syntax.description, equals('Test'));
    expect(syntax.version, equals('0.0.1-wip'));
    expect(syntax.environment.sdk, equals('>=3.9.0 <4.0.0'));
    expect(syntax.environment.flutter, isNull);
    expect(syntax.dependencies, isNotEmpty);
    final somePathDependency = syntax.dependencies?['some_path_dependency'];
    expect(somePathDependency, isA<DependencySourceSyntax>());
    final somePathDependency2 = PathDependencySourceSyntax.fromJson(
      somePathDependency!.json,
      path: somePathDependency.path,
    );
    expect(somePathDependency2.path$, equals('../some_path_dependency/'));
    expect(somePathDependency2.validate(), isEmpty);
    final someHostedDependency =
        syntax.dependencies!['some_hosted_dependency']!;
    final someHostedDependency2 = HostedDependencySourceSyntax.fromJson(
      someHostedDependency.json,
      path: someHostedDependency.path,
    );
    expect(someHostedDependency2.version, equals('^1.4.0'));
    expect(
      someHostedDependency2.hosted,
      equals('https://some-package-server.com'),
    );
    expect(someHostedDependency2.validate(), isEmpty);
    final someGitDependency = syntax.dependencies!['some_git_dependency']!;
    final someGitDependency2 = GitDependencySourceSyntax.fromJson(
      someGitDependency.json,
      path: someGitDependency.path,
    );
    expect(someGitDependency2.validate(), isEmpty);
    expect(
      someGitDependency2.git.url,
      equals('git@github.com:munificent/kittens.git'),
    );
    expect(someGitDependency2.git.path$, equals('pkgs/some_git_dependency/'));
    expect(someGitDependency2.git.ref, equals('some-branch'));
    final someSdkDependency = syntax.devDependencies!['some_sdk_dependency']!;
    final someSdkDependency2 = SdkDependencySourceSyntax.fromJson(
      someSdkDependency.json,
      path: someSdkDependency.path,
    );
    expect(someSdkDependency2.validate(), isEmpty);
    expect(someSdkDependency2.sdk, equals('flutter'));
    expect(syntax.dependencyOverrides, isNull);
    expect(syntax.executables, isNotNull);
    expect(
      syntax.executables,
      equals({'slidy': 'main', 'fvm': null, 'dart-apitool': 'main'}),
    );
    expect(syntax.publishTo, equals('none'));
    expect(syntax.documentation, isNull);
    expect(syntax.issueTracker, isNull);
    expect(syntax.homepage, isNull);
    expect(syntax.repository, isNull);
    expect(
      syntax.hooks!.userDefines!['download_asset'],
      equals({'local_build': false}),
    );
    expect(
      syntax.hooks!.userDefines!['user_defines'],
      equals({
        'user_define_key': 'user_define_value',
        'user_define_key2': {'foo': 'bar'},
        'some_file':
            'pkgs/hooks_runner/test_data/user_defines/assets/data.json',
      }),
    );
    expect(
      syntax.hooks!.userDefines!['some_other_package'],
      equals({'user_define_key3': 'user_define_value3'}),
    );
  });

  // Cover functionality from package:pub pub/lib/src/pubspec_parse.dart
  test('pubspec executables section errors', () {
    final syntaxError1 = PubspecYamlFileSyntax.fromJson(
      loadYamlAsJson('test_data/pubspec_errors_executables_1.yaml'),
    );
    expect(
      syntaxError1.validate(),
      equals([
        "Unexpected value 'not a map' (String) for 'executables'. Expected a Map<String, Object?>?.",
      ]),
    );
    expect(() => syntaxError1.executables, throwsFormatException);

    final syntaxError2 = PubspecYamlFileSyntax.fromJson(
      loadYamlAsJson('test_data/pubspec_errors_executables_2.yaml'),
    );
    expect(
      syntaxError2.validate(),
      equals([
        "Unexpected key 'invalid executable name' in 'executables'. Expected a key satisfying ^[a-zA-Z_]\\w*(-[a-zA-Z_]\\w*)*\$.",
      ]),
    );
    expect(() => syntaxError2.executables, throwsFormatException);

    final syntaxError3 = PubspecYamlFileSyntax.fromJson(
      loadYamlAsJson('test_data/pubspec_errors_executables_3.yaml'),
    );
    expect(
      syntaxError3.validate(),
      equals([
        "Unexpected value 'path/containing/a/separator/to/script.dart' (String) for 'executables.my_executable'. Expected a Object? satisfying ^[^/\\\\]*\$.",
      ]),
    );
    expect(() => syntaxError3.executables, throwsFormatException);

    final validSyntax = PubspecYamlFileSyntax.fromJson(
      loadYamlAsJson('test_data/pubspec_1.yaml'),
    );
    expect(validSyntax.validate(), isEmpty);
    expect(
      () => validSyntax.executables = {'valid_executable': 'valid_entrypoint'},
      isNot(throwsArgumentError),
    );
    expect(
      () => validSyntax.executables = {
        'not a valid executable name': 'valid_entrypoint',
      },
      throwsArgumentError,
    );
    expect(
      () =>
          validSyntax.executables = {'valid_executable': 'invalid/entry_point'},
      throwsArgumentError,
    );
  });
}
