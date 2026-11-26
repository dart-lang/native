// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks_runner/hooks_runner.dart';
import 'package:test/test.dart';

void main() {
  group('parseCommandLineUserDefines', () {
    test('parses a single define', () {
      expect(parseCommandLineUserDefines(['my_package.key=value']), {
        'my_package': {'key': 'value'},
      });
    });

    test('parses multiple defines for multiple packages', () {
      expect(
        parseCommandLineUserDefines([
          'my_package.key=value',
          'my_package.other=1',
          'other_package.key=value',
        ]),
        {
          'my_package': {'key': 'value', 'other': 1},
          'other_package': {'key': 'value'},
        },
      );
    });

    test('splits on the first dot only', () {
      expect(
        parseCommandLineUserDefines(['my_package.some_key=value']),
        {
          'my_package': {'some_key': 'value'},
        },
      );
    });

    test('last define wins for duplicate keys', () {
      expect(
        parseCommandLineUserDefines([
          'my_package.key=first',
          'my_package.key=second',
        ]),
        {
          'my_package': {'key': 'second'},
        },
      );
    });

    test('decodes JSON values', () {
      expect(
        parseCommandLineUserDefines([
          'my_package.bool_true=true',
          'my_package.bool_false=false',
          'my_package.null_value=null',
          'my_package.int_value=42',
          'my_package.double_value=4.2',
          'my_package.list_value=["arm64","x64"]',
          'my_package.map_value={"nested":"value"}',
          'my_package.quoted_string="42"',
        ]),
        {
          'my_package': {
            'bool_true': true,
            'bool_false': false,
            'null_value': null,
            'int_value': 42,
            'double_value': 4.2,
            'list_value': ['arm64', 'x64'],
            'map_value': {
              'nested': 'value',
            },
            'quoted_string': '42',
          },
        },
      );
    });

    test('uses the raw value for values that are not valid JSON', () {
      expect(
        parseCommandLineUserDefines([
          'my_package.optimization_level=O3',
          'my_package.leading_zeros=007',
          'my_package.version=v1.20',
          'my_package.empty=',
        ]),
        {
          'my_package': {
            'optimization_level': 'O3',
            'leading_zeros': '007',
            'version': 'v1.20',
            'empty': '',
          },
        },
      );
    });

    test('decodes values that look like a number as a number', () {
      expect(parseCommandLineUserDefines(['my_package.version=1.20']), {
        'my_package': {'version': 1.2},
      });
    });

    test('keeps equals signs in the value', () {
      expect(parseCommandLineUserDefines(['my_package.key=a=b']), {
        'my_package': {'key': 'a=b'},
      });
    });

    test('throws for a missing equals sign', () {
      expect(
        () => parseCommandLineUserDefines(['my_package.key']),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains("Expected '<package>.<key>=<value>'"),
          ),
        ),
      );
    });

    test('throws for a missing dot', () {
      expect(
        () => parseCommandLineUserDefines(['my_package=value']),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains("Expected '<package>.<key>=<value>'"),
          ),
        ),
      );
    });

    test('throws for an empty package name', () {
      expect(
        () => parseCommandLineUserDefines(['.key=value']),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('non-empty package name'),
          ),
        ),
      );
    });

    test('throws for an empty key', () {
      expect(
        () => parseCommandLineUserDefines(['my_package.=value']),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('non-empty key'),
          ),
        ),
      );
    });

    test('throws for a nested key', () {
      expect(
        () => parseCommandLineUserDefines(['my_package.nested.key=value']),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains('Nested user-defines'), contains('JSON value')),
          ),
        ),
      );
    });

    test('returns an empty map for no arguments', () {
      expect(parseCommandLineUserDefines([]), isEmpty);
    });
  });

  group('parseEnvironmentUserDefines', () {
    test('parses a single define', () {
      expect(
        parseEnvironmentUserDefines(
          {
            'DART_HOOK_DEFINE__my_package__key': 'value',
          },
          knownPackageNames: {'my_package'},
        ).defines,
        {
          'my_package': {'key': 'value'},
        },
      );
    });

    test('accepts a lower case prefix', () {
      expect(
        parseEnvironmentUserDefines(
          {
            'dart_hook_define__my_package__key': 'value',
          },
          knownPackageNames: {'my_package'},
        ).defines,
        {
          'my_package': {'key': 'value'},
        },
      );
    });

    test('decodes JSON values', () {
      expect(
        parseEnvironmentUserDefines(
          {
            'DART_HOOK_DEFINE__my_package__bool_value': 'true',
            'DART_HOOK_DEFINE__my_package__list_value': '["arm64"]',
            'DART_HOOK_DEFINE__my_package__string_value': 'arm64',
          },
          knownPackageNames: {'my_package'},
        ).defines,
        {
          'my_package': {
            'bool_value': true,
            'list_value': ['arm64'],
            'string_value': 'arm64',
          },
        },
      );
    });

    test('ignores unrelated environment variables', () {
      expect(
        parseEnvironmentUserDefines(
          {
            'PATH': '/usr/bin',
            'DART_HOOK_DEFINE': 'value',
          },
          knownPackageNames: {'my_package'},
        ).defines,
        isEmpty,
      );
    });

    test('attributes package names with double underscores using the '
        'longest match', () {
      final result = parseEnvironmentUserDefines(
        {
          'DART_HOOK_DEFINE__foo__bar__key': 'foo__bar',
          'DART_HOOK_DEFINE__foo__other_key': 'foo',
        },
        knownPackageNames: {'foo', 'foo__bar'},
      );
      expect(result.warnings, isEmpty);
      expect(result.defines, {
        'foo': {'other_key': 'foo'},
        'foo__bar': {'key': 'foo__bar'},
      });
    });

    test('warns for a package that does not exist', () {
      final result = parseEnvironmentUserDefines(
        {
          'DART_HOOK_DEFINE__unknown_package__key': 'value',
        },
        knownPackageNames: {'my_package'},
      );
      expect(result.defines, isEmpty);
      expect(
        result.warnings.single,
        allOf(
          contains('DART_HOOK_DEFINE__unknown_package__key'),
          contains(
            'unknown_package',
          ),
        ),
      );
    });

    test('attributes to the first `__` when no packages are known', () {
      final result = parseEnvironmentUserDefines(
        {
          'DART_HOOK_DEFINE__my_package__key': 'value',
        },
        knownPackageNames: {},
      );
      expect(result.warnings, isEmpty);
      expect(result.defines, {
        'my_package': {'key': 'value'},
      });
    });

    test('warns for a variable with only the prefix', () {
      final result = parseEnvironmentUserDefines(
        {
          'DART_HOOK_DEFINE__': 'value',
        },
        knownPackageNames: {'my_package'},
      );
      expect(result.defines, isEmpty);
      expect(
        result.warnings.single,
        allOf(
          contains('DART_HOOK_DEFINE__'),
          contains('<package>__<key>=<value>'),
          isNot(contains("'' is not a package")),
        ),
      );
    });

    test('warns for a missing package name separator', () {
      final result = parseEnvironmentUserDefines(
        {
          'DART_HOOK_DEFINE__my_package': 'value',
        },
        knownPackageNames: {'my_package'},
      );
      expect(result.defines, isEmpty);
      expect(result.warnings.single, contains('my_package'));
    });

    test('warns for an empty key', () {
      final result = parseEnvironmentUserDefines(
        {
          'DART_HOOK_DEFINE__my_package__': 'value',
        },
        knownPackageNames: {'my_package'},
      );
      expect(result.defines, isEmpty);
      expect(result.warnings.single, contains('non-empty key'));
    });
  });

  group('decodeUserDefineValue', () {
    test('decodes JSON', () {
      expect(decodeUserDefineValue('true'), true);
      expect(decodeUserDefineValue('42'), 42);
      expect(decodeUserDefineValue('null'), isNull);
    });

    test('falls back to string', () {
      expect(decodeUserDefineValue('O3'), 'O3');
      expect(decodeUserDefineValue(''), '');
    });
  });
}
