// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:spelling_checker/spelling_checker.dart';
import 'package:test/test.dart';

void main() {
  group('Dictionary', () {
    test('loads words ignoring headers and comments', () {
      const content = '''
# Header comment
# Another comment

apple
banana # inline comment
cherry
''';
      final dict = Dictionary()..loadString(content);
      expect(dict.contains('apple'), isTrue);
      expect(dict.contains('banana'), isTrue);
      expect(dict.contains('cherry'), isTrue);
      expect(dict.contains('orange'), isFalse);
    });

    test('finds alternatives for typos', () {
      final dict = Dictionary()..addAll(['apple', 'banana', 'orange']);
      final alts = dict.findAlternatives('aple');
      expect(alts, contains('apple'));
    });
  });

  group('CommentExtractor', () {
    final extractor = CommentExtractor();

    test('extracts doc comments while ignoring Dart code identifiers', () {
      const code = '''
/// This is a documentation comment for [MyClass].
/// It generates Objective-C bindings.
class MyClass {
  int someIdentifier = 42;

  // Regular comment explaining code.
  void foo() {}
}
''';
      final chunks = extractor.extractFromString(code);
      expect(chunks.length, greaterThanOrEqualTo(2));
      final fullText = chunks.map((c) => c.text).join(' ');

      expect(fullText, contains('This is a documentation comment'));
      expect(fullText, contains('Objective-C'));
      // Code identifiers shouldn't be in the extracted chunks
      expect(fullText, isNot(contains('someIdentifier')));
      expect(fullText, isNot(contains('void foo()')));
    });

    test('ignores code blocks in doc comments', () {
      const code = '''
/// Here is an example:
/// ```dart
/// var a = b + c;
/// ```
/// End of example.
void bar() {}
''';
      final chunks = extractor.extractFromString(code);
      final fullText = chunks.map((c) => c.text).join(' ');
      expect(fullText, contains('Here is an example'));
      expect(fullText, contains('End of example'));
      expect(fullText, isNot(contains('var a = b + c')));
    });

    test('strips backticks from doc comments', () {
      const code = '''
/// Call `doSomethingWithCode()` to proceed.
void bar() {}
''';
      final chunks = extractor.extractFromString(code);
      final fullText = chunks.map((c) => c.text).join(' ');
      expect(fullText, contains('Call'));
      expect(fullText, contains('to proceed'));
      expect(fullText, isNot(contains('doSomethingWithCode')));
    });
  });

  group('MarkdownExtractor', () {
    final extractor = MarkdownExtractor();

    test('extracts text while skipping code blocks and backticks', () {
      const markdown = '''
# Welcome to FFIGEN

This library generates bindings for C and Objective-C.

```dart
final generator = FfiGenerator();
```

Use `FfiGenerator` to start.
''';
      final chunks = extractor.extractFromString(markdown);
      final fullText = chunks.map((c) => c.text).join(' ');

      expect(fullText, contains('Welcome to FFIGEN'));
      expect(fullText, contains('This library generates bindings'));
      expect(fullText, contains('Use'));
      expect(fullText, contains('to start'));
      expect(fullText, isNot(contains('final generator = FfiGenerator()')));
      expect(fullText, isNot(contains('FfiGenerator')));
    });
  });

  group('SpellingChecker', () {
    final dict = Dictionary()
      ..addAll([
        'hello',
        'world',
        'objective-c',
        'dart',
        'generates',
        'binding',
      ]);
    final checker = SpellingChecker(dictionaries: [dict]);

    test('accepts correctly spelled words', () {
      expect(checker.isValidWord('hello'), isTrue);
      expect(checker.isValidWord('World'), isTrue);
      expect(checker.isValidWord('Objective-C'), isTrue);
      expect(checker.isValidWord('Dart\'s'), isTrue);
      expect(checker.isValidWord('generates'), isTrue);
    });

    test('rejects misspelled words', () {
      expect(checker.isValidWord('helo'), isFalse);
      expect(
        checker.isValidWord('ObjectiveC'),
        isFalse,
      ); // Normal text must have hyphen!
    });

    test('reports spelling issue with location', () {
      final chunks = [
        const TextChunk(
          text: 'helo world',
          filePath: 'test.dart',
          line: 10,
          column: 1,
        ),
      ];
      final issues = checker.checkChunks(chunks);
      expect(issues.length, 1);
      expect(issues.first.word, 'helo');
      expect(issues.first.line, 10);
      expect(issues.first.suggestions, contains('hello'));
    });
  });
}
