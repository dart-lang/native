// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:ffigen/src/config_provider/yaml_to_dart.dart';
import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../test_utils.dart';

/// Emits Dart source for [yamlBody], a legacy ffigen YAML config.
String emit(
  String yamlBody, {
  String? configFilename,
  String outputFilePath = '/repo/tool/ffigen.dart',
}) {
  return emitDartConfig(
    loadYaml(yamlBody) as YamlMap,
    configFilename: configFilename,
    outputFilePath: outputFilePath,
  );
}

/// Formats [source] with `package:dart_style`, throwing if it's not valid
/// Dart. Used to make sure the emitter always produces syntactically valid
/// code.
String formatOrThrow(String source) {
  return DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  ).format(source);
}

const _minimalHeader = '''
output: out.dart
headers:
  entry-points:
    - 'a.h'
''';

void main() {
  group('migrate', () {
    test('minimal config formats and has expected shape', () {
      final dart = emit(_minimalHeader);
      expect(dart, contains("import 'package:ffigen/ffigen.dart';"));
      expect(dart, contains('final packageRoot = Platform.script.resolve('));
      // Plain entry point paths are kept even if the file doesn't exist at
      // migration time.
      expect(
        dart,
        contains("Headers(entryPoints: [packageRoot.resolve('a.h')]"),
      );
      expect(
        dart,
        contains("Output(dartFile: packageRoot.resolve('out.dart')"),
      );
      // Legacy default is include-everything, unlike the Dart API's own
      // default of excluding everything, so it must always be emitted.
      expect(
        dart,
        contains('functions: Functions(include: Declarations.includeAll'),
      );
      expect(formatOrThrow(dart), isNotEmpty);
    });

    test('output as a full map with objc-bindings and symbol-file', () {
      final dart = emit('''
output:
  bindings: 'out.dart'
  objc-bindings: 'out.m.dart'
  symbol-file:
    output: 'package:foo/foo.dart'
    import-path: 'package:foo/foo.dart'
headers:
  entry-points:
    - 'a.h'
''');
      expect(dart, contains("dartFile: packageRoot.resolve('out.dart')"));
      expect(
        dart,
        contains("objectiveCFile: packageRoot.resolve('out.m.dart')"),
      );
      expect(
        dart,
        contains(
          "symbolFile: SymbolFile(Uri.parse('package:foo/foo.dart'), "
          "Uri.parse('package:foo/foo.dart'))",
        ),
      );
      formatOrThrow(dart);
    });

    test('name/description become DynamicLibraryBindings by default', () {
      final dart = emit('''
name: MyLib
description: 'My lib bindings'
$_minimalHeader
''');
      expect(
        dart,
        contains(
          "DynamicLibraryBindings(wrapperName: 'MyLib', "
          "wrapperDocComment: 'My lib bindings')",
        ),
      );
      formatOrThrow(dart);
    });

    test('ffi-native becomes NativeExternalBindings', () {
      final dart = emit('''
ffi-native:
  asset-id: 'package:foo/foo.dart'
$_minimalHeader
''');
      expect(
        dart,
        contains("NativeExternalBindings(assetId: 'package:foo/foo.dart')"),
      );
      formatOrThrow(dart);
    });

    test('ffi-native: null still uses NativeExternalBindings default', () {
      final dart = emit('''
ffi-native: null
$_minimalHeader
''');
      expect(dart, contains('DynamicLibraryBindings(wrapperName:'));
      formatOrThrow(dart);
    });

    test('comments: false becomes CommentType.none', () {
      final dart = emit('''
comments: false
$_minimalHeader
''');
      expect(dart, contains('commentType: const CommentType.none()'));
      formatOrThrow(dart);
    });

    test('preamble is preserved verbatim', () {
      final dart = emit('''
preamble: |
  // my preamble
$_minimalHeader
''');
      expect(dart, contains('my preamble'));
      formatOrThrow(dart);
    });

    test('compiler-opts as a string is split into a list', () {
      final dart = emit('''
compiler-opts: '-DFOO -DBAR'
$_minimalHeader
''');
      expect(dart, contains("compilerOptions: ['-DFOO', '-DBAR']"));
      formatOrThrow(dart);
    });

    test('compiler-opts-automatic uses defaultCompilerOpts', () {
      final dart = emit('''
compiler-opts-automatic:
  macos:
    include-c-standard-library: false
$_minimalHeader
''');
      expect(
        dart,
        contains('...defaultCompilerOpts(logger, macIncludeStdLib: false)'),
      );
      // `Logger` comes from package:ffigen's own exports; the generated
      // script must not import packages the target package may not depend on.
      expect(dart, contains("final logger = Logger('ffigen');"));
      expect(dart, isNot(contains("import 'package:logging/logging.dart';")));
      formatOrThrow(dart);
    });

    test('include-directives become Headers.includeGlobs', () {
      final dart = emit('''
output: out.dart
headers:
  entry-points:
    - 'a.h'
  include-directives:
    - '**include/*.h'
''');
      // The path separator is platform-dependent (normalizePath), so only
      // check the invocation shape.
      expect(dart, contains('include: Headers.includeGlobs(['));
      expect(dart, contains('*.h'));
      // The generated script may only import package:ffigen itself.
      expect(dart, isNot(contains("import 'package:glob/glob.dart';")));
      formatOrThrow(dart);
    });

    test('glob entry points that match nothing get a TODO', () {
      final dart = emit('''
output: out.dart
headers:
  entry-points:
    - 'no/such/dir/*.h'
''');
      expect(dart, contains('Headers(entryPoints: []'));
      expect(dart, contains('// TODO(ffigen migration):'));
      expect(dart, contains('matched no files'));
      formatOrThrow(dart);
    });

    group('include/exclude', () {
      test('plain names become includeSet', () {
        final dart = emit('''
functions:
  include:
    - foo
    - bar
$_minimalHeader
''');
        expect(dart, contains('Functions(include: Declarations.includeSet({'));
        expect(dart, contains("'foo'"));
        expect(dart, contains("'bar'"));
        formatOrThrow(dart);
      });

      test('include: [] excludes everything', () {
        final dart = emit('''
functions:
  include: []
$_minimalHeader
''');
        expect(dart, isNot(contains('functions:')));
        formatOrThrow(dart);
      });

      test('regex patterns fall back to a helper lambda', () {
        final dart = emit('''
functions:
  include:
    - 'clang_.*'
$_minimalHeader
''');
        expect(dart, contains('_declarationIncluder(includePatterns: ['));
        expect(dart, contains(r"RegExp(r'clang_.*', dotAll: true)"));
        expect(dart, contains('bool _matchesAny('));
        formatOrThrow(dart);
      });

      test('exclude forces the fallback lambda', () {
        final dart = emit('''
functions:
  include:
    - foo
  exclude:
    - bar
$_minimalHeader
''');
        expect(dart, contains('_declarationIncluder('));
        expect(dart, contains('includeNames: {'));
        expect(dart, contains('excludeNames: {'));
        formatOrThrow(dart);
      });

      test('exclude-all-by-default with no overrides omits the section', () {
        final dart = emit('''
exclude-all-by-default: true
$_minimalHeader
''');
        // Structs/unions always emit `dependencies`, but functions/enums/etc
        // should be omitted entirely since `Declarations.excludeAll` is
        // already the Dart API's own default.
        expect(dart, isNot(contains('functions:')));
        expect(dart, isNot(contains('enums:')));
        expect(dart, contains('structs: Structs(dependencies:'));
        formatOrThrow(dart);
      });

      test(
        'exclude-all-by-default is threaded through the fallback lambda',
        () {
          final dart = emit('''
exclude-all-by-default: true
functions:
  exclude:
    - 'foo.*'
$_minimalHeader
''');
          expect(dart, contains('excludeAllByDefault: true'));
          formatOrThrow(dart);
        },
      );
    });

    group('rename', () {
      test('plain names become renameWithMap', () {
        final dart = emit('''
functions:
  rename:
    foo: bar
$_minimalHeader
''');
        expect(
          dart,
          contains("rename: Declarations.renameWithMap({'foo': 'bar'})"),
        );
        formatOrThrow(dart);
      });

      test(r'regex rename falls back to $-group substitution helper', () {
        final dart = emit(
          r'''
functions:
  rename:
    'clang_(.*)': '$1'
'''
          '\n$_minimalHeader',
        );
        expect(dart, contains('_tryRegexRename(name,'));
        expect(dart, contains('String? _tryRegexRename('));
        formatOrThrow(dart);
      });

      test('member-rename with plain names becomes renameMemberWithMap', () {
        final dart = emit('''
functions:
  member-rename:
    Foo:
      bar: baz
$_minimalHeader
''');
        expect(dart, contains('Declarations.renameMemberWithMap({'));
        formatOrThrow(dart);
      });

      test('member-rename with a regex declaration falls back to a lambda', () {
        final dart = emit('''
functions:
  member-rename:
    'Foo.*':
      bar: baz
$_minimalHeader
''');
        expect(dart, contains('(Declaration decl, String member) {'));
        expect(dart, contains('_fullRegexMatch(RegExp('));
        formatOrThrow(dart);
      });
    });

    group('structs/unions', () {
      test('dependency-only is always emitted (default differs from Dart)', () {
        final dartFull = emit('''
structs:
  dependency-only: full
$_minimalHeader
''');
        expect(dartFull, contains('dependencies: CompoundDependencies.full'));

        final dartOpaque = emit('''
structs:
  dependency-only: opaque
$_minimalHeader
''');
        expect(
          dartOpaque,
          contains('dependencies: CompoundDependencies.opaque'),
        );
        formatOrThrow(dartFull);
        formatOrThrow(dartOpaque);
      });

      test('pack becomes a packingOverride lambda', () {
        final dart = emit('''
structs:
  pack:
    Foo: 4
    Bar: none
$_minimalHeader
''');
        expect(dart, contains('packingOverride: (Declaration decl) {'));
        expect(dart, contains('PackingValue(e.value)'));
        expect(
          dart,
          contains('MapEntry(RegExp(r\'Bar\', dotAll: true), null)'),
        );
        formatOrThrow(dart);
      });
    });

    group('enums', () {
      test('as-int becomes a style callback', () {
        final dart = emit('''
enums:
  as-int:
    include:
      - Foo
$_minimalHeader
''');
        expect(dart, contains('EnumStyle? suggestedStyle'));
        expect(dart, contains('EnumStyle.intConstants'));
        expect(dart, contains('EnumStyle.dartEnum'));
        formatOrThrow(dart);
      });

      test('silence-enum-warning defaults to true for objc', () {
        final dart = emit('''
language: objc
$_minimalHeader
''');
        expect(dart, contains('silenceWarning: true'));
        formatOrThrow(dart);
      });
    });

    group('type-map / library-imports', () {
      test('native-types wires up Integers.imported', () {
        final dart = emit('''
type-map:
  native-types:
    MyInt:
      lib: ffi
      c-type: Int32
      dart-type: int
$_minimalHeader
''');
        expect(dart, contains('Integers('));
        expect(dart, contains("LibraryImport('ffi', 'dart:ffi')"));
        expect(
          dart,
          contains(
            "ImportedType(LibraryImport('ffi', 'dart:ffi'), "
            "'Int32', 'int', 'MyInt')",
          ),
        );
        formatOrThrow(dart);
      });

      test('custom library-imports are resolved by alias', () {
        final dart = emit('''
library-imports:
  foo: 'package:foo/foo.dart'
type-map:
  typedefs:
    MyType:
      lib: foo
      c-type: Foo
      dart-type: Foo
$_minimalHeader
''');
        expect(dart, contains("LibraryImport('foo', 'package:foo/foo.dart')"));
        formatOrThrow(dart);
      });
    });

    group('objective-c', () {
      test('module becomes a module-matcher helper', () {
        final dart = emit('''
language: objc
objc-interfaces:
  module:
    'NS.*': 'foundation'
$_minimalHeader
''');
        expect(dart, contains('module: _moduleMatcher(['));
        expect(dart, contains('String? Function(Declaration) _moduleMatcher('));
        formatOrThrow(dart);
      });

      test('include-transitive-objc-interfaces is emitted only when true', () {
        final dart = emit('''
language: objc
include-transitive-objc-interfaces: true
$_minimalHeader
''');
        expect(dart, contains('includeTransitive: true'));
        formatOrThrow(dart);
      });

      test('include-transitive-objc-categories is emitted only when false', () {
        final dart = emit('''
language: objc
include-transitive-objc-categories: false
$_minimalHeader
''');
        expect(dart, contains('includeTransitive: false'));
        formatOrThrow(dart);
      });

      test('external-versions migrates both min and max', () {
        final dart = emit('''
language: objc
external-versions:
  ios:
    min: 12.0.0
    max: 17.0.0
  macos:
    max: 14.0.0
$_minimalHeader
''');
        expect(
          dart,
          contains(
            "ios: Versions(min: Version.parse('12.0.0'), "
            "max: Version.parse('17.0.0'))",
          ),
        );
        expect(dart, contains("macos: Versions(max: Version.parse('14.0.0'))"));
        formatOrThrow(dart);
      });

      test('member-filter becomes an includeMember lambda', () {
        final dart = emit('''
language: objc
objc-interfaces:
  member-filter:
    Foo:
      exclude:
        - bar
$_minimalHeader
''');
        expect(
          dart,
          contains('includeMember: (Declaration decl, String member) {'),
        );
        expect(dart, contains('_includeName(member,'));
        formatOrThrow(dart);
      });
    });

    group('TODOs for unmappable options', () {
      test('sort: true is dropped with a TODO', () {
        final dart = emit('''
sort: true
$_minimalHeader
''');
        expect(dart, contains('// TODO(ffigen migration):'));
        expect(dart, contains("'sort: true'"));
      });

      test('llvm-path gets a TODO pointing at generate()', () {
        final dart = emit('''
llvm-path:
  - /usr/lib
$_minimalHeader
''');
        expect(dart, contains('libclangDylib'));
      });

      test('unnamed-enums as-int has no Dart equivalent', () {
        final dart = emit('''
unnamed-enums:
  as-int:
    include:
      - Foo
$_minimalHeader
''');
        expect(dart, contains('UnnamedEnums'));
        expect(dart, contains('// TODO(ffigen migration):'));
      });

      test('variadic-arguments has no public-API equivalent', () {
        final dart = emit('''
functions:
  variadic-arguments:
    printf:
      - types: ['int']
$_minimalHeader
''');
        expect(dart, contains('// TODO(ffigen migration):'));
        expect(dart, contains('variadic-arguments'));
      });

      test('unknown top-level keys are flagged', () {
        final dart = emit('''
some-made-up-key: 123
$_minimalHeader
''');
        expect(dart, contains("Unhandled top-level key 'some-made-up-key'"));
      });
    });

    test('resolves relative header/output paths against the output script', () {
      final dart = emit(
        '''
output: 'lib/out.dart'
headers:
  entry-points:
    - '${absPath('test/config_tests/exclude_all_by_default.h')}'
''',
        configFilename: absPath('test/config_tests/some_config.yaml'),
        outputFilePath: absPath(
          path.join('test', 'config_tests', 'tool', 'ffigen.dart'),
        ),
      );
      expect(dart, contains("Platform.script.resolve('../')"));
      expect(dart, contains("packageRoot.resolve('lib/out.dart')"));
      formatOrThrow(dart);
    });

    test('all in-repo config.yaml files can be migrated without throwing', () {
      final configYamlGlob = Glob('**config.yaml');
      final configYamlFiles = configYamlGlob.listFileSystemSync(
        const LocalFileSystem(),
        root: packagePathForTests,
      );
      expect(configYamlFiles, isNotEmpty);

      for (final fileEntity in configYamlFiles) {
        final file = fileEntity.absolute.path;
        final doc = loadYaml(
          File(file).readAsStringSync(),
          sourceUrl: Uri.file(file),
        );
        if (doc is! YamlMap) continue;

        String dart;
        try {
          dart = emitDartConfig(
            doc,
            configFilename: file,
            outputFilePath: path.join(
              path.dirname(file),
              'tool',
              'ffigen.dart',
            ),
          );
        } catch (e, st) {
          fail('emitDartConfig threw for $file:\n$e\n$st');
        }

        try {
          formatOrThrow(dart);
        } catch (e, st) {
          fail(
            'Generated Dart for $file did not format cleanly:\n'
            '$e\n$st\n\n$dart',
          );
        }
      }
    });
  });
}
