// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:snippet_tool/snippet_tool.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late File snippetFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('snippet_tool_test');
    snippetFile = File.fromUri(tempDir.uri.resolve('snippet.dart'));
    await snippetFile.writeAsString('''
// snippet-start#my_snippet
void hello() {
  print('hello');
}
// snippet-end#my_snippet
''');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  const tag =
      '<!-- '
      'file://./snippet.dart#my_snippet -->';
  const multilineTag =
      '<!-- '
      'file://./snippet_multiline.dart#my_snippet -->';
  const fence =
      '```'
      'dart';
  const endFence = '```';

  group('updateSnippets', () {
    test('ordinary code block', () {
      const docContent =
          '''
$tag
$fence
old content
$endFence
''';
      final docUri = tempDir.uri.resolve('doc.md');
      final errors = <String>[];
      final updated = updateSnippets(docContent, docUri, errors);
      expect(errors, isEmpty);
      expect(updated, '''
$tag
$fence
void hello() {
  print('hello');
}
$endFence
''');
    });

    test('doc comments (/// )', () {
      const docContent =
          '''
/// $tag
/// $fence
/// old content
/// $endFence
''';
      final docUri = tempDir.uri.resolve('doc.dart');
      final errors = <String>[];
      final updated = updateSnippets(docContent, docUri, errors);
      expect(errors, isEmpty);
      expect(updated, '''
/// $tag
/// $fence
/// void hello() {
///   print('hello');
/// }
/// $endFence
''');
    });

    test('blockquoted code block (> )', () {
      const docContent =
          '''
> $tag
> $fence
> old content
> $endFence
''';
      final docUri = tempDir.uri.resolve('doc.md');
      final errors = <String>[];
      final updated = updateSnippets(docContent, docUri, errors);
      expect(errors, isEmpty);
      expect(updated, '''
> $tag
> $fence
> void hello() {
>   print('hello');
> }
> $endFence
''');
    });

    test('blockquoted code block without space (>```dart)', () {
      const docContent =
          '''
>$tag
>$fence
>old content
>$endFence
''';
      final docUri = tempDir.uri.resolve('doc.md');
      final errors = <String>[];
      final updated = updateSnippets(docContent, docUri, errors);
      expect(errors, isEmpty);
      expect(updated, '''
>$tag
>$fence
>void hello() {
>  print('hello');
>}
>$endFence
''');
    });

    test('blockquoted code block with empty lines', () {
      const docContent =
          '''
> $multilineTag
> $fence
> old content
> $endFence
''';
      final snippetMultiline = File.fromUri(
        tempDir.uri.resolve('snippet_multiline.dart'),
      );
      snippetMultiline.writeAsStringSync('''
// snippet-start#my_snippet
void hello() {
  print('hello');

  print('world');
}
// snippet-end#my_snippet
''');
      final docUri = tempDir.uri.resolve('doc.md');
      final errors = <String>[];
      final updated = updateSnippets(docContent, docUri, errors);
      expect(errors, isEmpty);
      expect(updated, '''
> $multilineTag
> $fence
> void hello() {
>   print('hello');
>
>   print('world');
> }
> $endFence
''');
    });

    test('parses snippet anchor', () {
      final multiAnchorFile = File.fromUri(
        tempDir.uri.resolve('multi_anchor.dart'),
      );
      multiAnchorFile.writeAsStringSync('''
// snippet-start#first
void first() {}
// snippet-end#first

// snippet-start#second
void second() {}
// snippet-end#second
''');
      const docContent = '''
<!-- file://./multi_anchor.dart#second -->
```dart
old
```
''';
      final docUri = tempDir.uri.resolve('doc.md');
      final errors = <String>[];
      final updated = updateSnippets(docContent, docUri, errors);
      expect(errors, isEmpty);
      expect(updated, '''
<!-- file://./multi_anchor.dart#second -->
```dart
void second() {}
```
''');
    });

    test('anchor not found reports error', () {
      const docContent = '''
<!-- file://./snippet.dart#non_existent -->
```dart
old
```
''';
      final docUri = tempDir.uri.resolve('doc.md');
      final errors = <String>[];
      updateSnippets(docContent, docUri, errors);
      expect(errors, isNotEmpty);
      expect(errors.first, contains('Anchor "non_existent" not found'));
    });

    test('unmatched code block fence reports error', () {
      const docContent =
          '''
$tag
```dart
void test() {}
''';
      final docUri = tempDir.uri.resolve('doc.md');
      final errors = <String>[];
      updateSnippets(docContent, docUri, errors);
      expect(errors, isNotEmpty);
      expect(errors.first, contains('Unmatched ```'));
    });

    test('no-source-file marker is ignored', () {
      const docContent = '''
<!-- no-source-file -->
```dart
void test() {}
```
''';
      final docUri = tempDir.uri.resolve('doc.md');
      final errors = <String>[];
      final updated = updateSnippets(docContent, docUri, errors);
      expect(errors, isEmpty);
      expect(updated, docContent);
    });

    test('strips copyright header with double space before Please', () {
      final file = File.fromUri(tempDir.uri.resolve('double_space.dart'));
      file.writeAsStringSync('''
// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

void doubleSpace() {}
''');
      const docContent = '''
<!-- file://./double_space.dart -->
```dart
old
```
''';
      final docUri = tempDir.uri.resolve('doc.md');
      final errors = <String>[];
      final updated = updateSnippets(docContent, docUri, errors);
      expect(errors, isEmpty);
      expect(updated, '''
<!-- file://./double_space.dart -->
```dart
void doubleSpace() {}
```
''');
    });

    test('strips copyright header with single space before Please', () {
      final file = File.fromUri(tempDir.uri.resolve('single_space.dart'));
      file.writeAsStringSync('''
// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

void singleSpace() {}
''');
      const docContent = '''
<!-- file://./single_space.dart -->
```dart
old
```
''';
      final docUri = tempDir.uri.resolve('doc.md');
      final errors = <String>[];
      final updated = updateSnippets(docContent, docUri, errors);
      expect(errors, isEmpty);
      expect(updated, '''
<!-- file://./single_space.dart -->
```dart
void singleSpace() {}
```
''');
    });

    test('strips copyright header enclosed in snippet markers', () {
      final file = File.fromUri(tempDir.uri.resolve('markers_copyright.dart'));
      file.writeAsStringSync('''
// snippet-start
// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

void marked() {}
// snippet-end
''');
      const docContent = '''
<!-- file://./markers_copyright.dart -->
```dart
old
```
''';
      final docUri = tempDir.uri.resolve('doc.md');
      final errors = <String>[];
      final updated = updateSnippets(docContent, docUri, errors);
      expect(errors, isEmpty);
      expect(updated, '''
<!-- file://./markers_copyright.dart -->
```dart
void marked() {}
```
''');
    });
  });

  group('dedent', () {
    test('removes common leading indentation', () {
      const code = '    void foo() {\n      print(1);\n    }';
      expect(dedent(code), 'void foo() {\n  print(1);\n}');
    });

    test('handles empty lines', () {
      const code = '  line 1\n\n  line 2';
      expect(dedent(code), 'line 1\n\nline 2');
    });
  });

  group('updateSnippetsInFile', () {
    test('updates file and counts when changed', () {
      final docFile = File.fromUri(tempDir.uri.resolve('doc.md'));
      docFile.writeAsStringSync('''
$tag
$fence
old content
$endFence
''');
      final counts = Counts();
      final errors = <String>[];
      updateSnippetsInFile(docFile, counts, errors);
      expect(errors, isEmpty);
      expect(counts.processed, 1);
      expect(counts.changed, 1);
      expect(docFile.readAsStringSync(), '''
$tag
$fence
void hello() {
  print('hello');
}
$endFence
''');

      // Subsequent run should not count as changed.
      updateSnippetsInFile(docFile, counts, errors);
      expect(counts.processed, 2);
      expect(counts.changed, 1);
    });
  });

  group('updateSnippetsInDirectory', () {
    test('updates files recursively', () {
      final subDir = Directory.fromUri(tempDir.uri.resolve('sub/'))
        ..createSync(recursive: true);
      final docFile = File.fromUri(subDir.uri.resolve('doc.md'));
      docFile.writeAsStringSync('''
<!-- file://./../snippet.dart#my_snippet -->
$fence
old content
$endFence
''');
      final counts = Counts();
      final errors = <String>[];
      updateSnippetsInDirectory(tempDir, counts, errors);
      expect(errors, isEmpty);
      expect(counts.processed, 2); // snippet.dart + sub/doc.md
      expect(counts.changed, 1);
      expect(docFile.readAsStringSync(), '''
<!-- file://./../snippet.dart#my_snippet -->
$fence
void hello() {
  print('hello');
}
$endFence
''');
    });

    test('skips hidden and build directories', () {
      final hiddenDir = Directory.fromUri(tempDir.uri.resolve('.hidden/'))
        ..createSync(recursive: true);
      File.fromUri(
        hiddenDir.uri.resolve('test.dart'),
      ).writeAsStringSync('void f() {}');

      final buildDir = Directory.fromUri(tempDir.uri.resolve('build/'))
        ..createSync(recursive: true);
      File.fromUri(
        buildDir.uri.resolve('test.dart'),
      ).writeAsStringSync('void f() {}');

      final files = findFiles(tempDir);
      expect(files.length, 1);
      expect(files.first.path, snippetFile.path);
    });
  });
}
