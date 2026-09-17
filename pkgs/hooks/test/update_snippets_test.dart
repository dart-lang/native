// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

import '../tool/update_snippets.dart';

void main() {
  late Directory tempDir;
  late File snippetFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('update_snippets_test');
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
}
