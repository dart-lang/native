// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../tool/detect_classes.dart';

/// Helper to create a mocked [ProcessResult].
ProcessResult _mockResult({
  int exitCode = 0,
  String stdout = '',
  String stderr = '',
}) => ProcessResult(1234, exitCode, stdout, stderr);

/// Helper to create a mocked [Process].
Process _mockProcess({
  int exitCode = 0,
  required Stream<List<int>> stdout,
  required StreamSink<List<int>> stdin,
}) => _MockProcess(exitCode, stdout, stdin);

class _MockProcess implements Process {
  @override
  final int pid = 1234;
  final int _exitCode;
  @override
  final Stream<List<int>> stdout;
  @override
  late final IOSink stdin;
  @override
  final Stream<List<int>> stderr = const Stream.empty();

  _MockProcess(this._exitCode, this.stdout, StreamSink<List<int>> stdinSink) {
    stdin = IOSink(stdinSink);
  }

  @override
  Future<int> get exitCode => Future.value(_exitCode);

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => true;
}

void main() {
  group('extractClassSymbols', () {
    test('extracts _OBJC_CLASS_\$_ symbols and ignores non-class symbols', () {
      const nmOutput = '''
0000000000008088 D _OBJC_CLASS_\$__TtC7classes16TestClassWrapper
0000000000008060 D _OBJC_METACLASS_\$__TtC7classes16TestClassWrapper
00000000000080b0 D _OBJC_CLASS_\$__TtC7classes21TestOtherClassWrapper
00000000000080e0 D _OBJC_CLASS_\$_CustomObjCClass
0000000000003f40 T _swift_bridgeObjectRelease
                 U _OBJC_CLASS_\$_NSObject
''';
      final symbols = extractClassSymbols(nmOutput);
      expect(symbols, {
        '_TtC7classes16TestClassWrapper',
        '_TtC7classes21TestOtherClassWrapper',
        'CustomObjCClass',
        'NSObject',
      });
    });

    test('deduplicates symbols across universal/fat binary architectures', () {
      const nmOutput = '''
libTest.dylib (for architecture x86_64):
0000000000008088 D _OBJC_CLASS_\$__TtC7classes16TestClassWrapper

libTest.dylib (for architecture arm64):
0000000000008088 D _OBJC_CLASS_\$__TtC7classes16TestClassWrapper
''';
      final symbols = extractClassSymbols(nmOutput);
      expect(symbols, {'_TtC7classes16TestClassWrapper'});
    });

    test('returns empty set if no class symbols exist', () {
      const nmOutput = '''
0000000000003f40 T _swift_bridgeObjectRelease
0000000000003f50 T _main
''';
      final symbols = extractClassSymbols(nmOutput);
      expect(symbols, isEmpty);
    });
  });

  group('parseDemangledSymbol', () {
    test('parses "mangled ---> demangled" format with module and class', () {
      final detected = parseDemangledSymbol(
        '_TtC7classes16TestClassWrapper ---> classes.TestClassWrapper',
        '_TtC7classes16TestClassWrapper',
      );
      expect(detected.module, 'classes');
      expect(detected.className, 'TestClassWrapper');
      expect(detected.qualifiedName, 'classes.TestClassWrapper');
      expect(detected.rawSymbol, '_TtC7classes16TestClassWrapper');
    });

    test('parses simplified demangled name with dot', () {
      final detected = parseDemangledSymbol(
        'AVFAudioWrapper.AVAudioPlayerWrapper',
        '_TtC15AVFAudioWrapper20AVAudioPlayerWrapper',
      );
      expect(detected.module, 'AVFAudioWrapper');
      expect(detected.className, 'AVAudioPlayerWrapper');
      expect(detected.qualifiedName, 'AVFAudioWrapper.AVAudioPlayerWrapper');
    });

    test('parses plain Objective-C class without module', () {
      final detected = parseDemangledSymbol('NSObject', 'NSObject');
      expect(detected.module, isNull);
      expect(detected.className, 'NSObject');
      expect(detected.qualifiedName, 'NSObject');
      expect(detected.rawSymbol, 'NSObject');
    });
  });

  group('parseMangledSwiftClass fallback', () {
    test('parses standard Swift class symbols correctly', () {
      final c1 = parseMangledSwiftClass('_TtC7classes16TestClassWrapper');
      expect(c1, isNotNull);
      expect(c1!.module, 'classes');
      expect(c1.className, 'TestClassWrapper');
      expect(c1.qualifiedName, 'classes.TestClassWrapper');

      final c2 = parseMangledSwiftClass('_TtC6target17TestTargetWrapper');
      expect(c2, isNotNull);
      expect(c2!.module, 'target');
      expect(c2.className, 'TestTargetWrapper');

      final c3 = parseMangledSwiftClass(
        '_TtC15AVFAudioWrapper20AVAudioPlayerWrapper',
      );
      expect(c3, isNotNull);
      expect(c3!.module, 'AVFAudioWrapper');
      expect(c3.className, 'AVAudioPlayerWrapper');

      final c4 = parseMangledSwiftClass('_TtC9callbacks18TestMessageService');
      expect(c4, isNotNull);
      expect(c4!.module, 'callbacks');
      expect(c4.className, 'TestMessageService');
    });

    test('returns null for non-Swift or malformed symbols', () {
      expect(parseMangledSwiftClass('NSObject'), isNull);
      expect(parseMangledSwiftClass('_TtC9invalid'), isNull);
      expect(parseMangledSwiftClass('_TtC'), isNull);
    });
  });

  group('demangleSymbols', () {
    test('pipes symbols through process when startProcess provided', () async {
      final inController = StreamController<List<int>>();
      inController.stream.listen((_) {});
      final outController = StreamController<List<int>>();

      outController.add(
        utf8.encode(
          'classes.TestClassWrapper\nclasses.TestOtherClassWrapper\n',
        ),
      );
      unawaited(outController.close());

      Future<Process> mockStarter(
        String executable,
        List<String> arguments,
      ) async {
        expect(executable, 'swift');
        expect(arguments, ['demangle']);
        return _mockProcess(
          exitCode: 0,
          stdout: outController.stream,
          stdin: inController.sink,
        );
      }

      final classes = await demangleSymbols([
        '_TtC7classes16TestClassWrapper',
        '_TtC7classes21TestOtherClassWrapper',
      ], startProcess: mockStarter);

      expect(classes, hasLength(2));
      expect(classes[0].module, 'classes');
      expect(classes[0].className, 'TestClassWrapper');
      expect(classes[1].module, 'classes');
      expect(classes[1].className, 'TestOtherClassWrapper');
    });

    test('falls back gracefully when swift demangle is unavailable', () async {
      Future<Process> failingStarter(String executable, List<String> args) =>
          throw const ProcessException('swift', ['demangle'], 'not found');

      final classes = await demangleSymbols([
        '_TtC7classes16TestClassWrapper',
        'CustomObjCClass',
      ], startProcess: failingStarter);

      expect(classes, hasLength(2));
      expect(classes[0].module, 'classes');
      expect(classes[0].className, 'TestClassWrapper');
      expect(classes[1].module, isNull);
      expect(classes[1].className, 'CustomObjCClass');
    });
  });

  group('groupClassesByModule', () {
    test('groups and sorts classes alphabetically', () {
      final classes = [
        const DetectedClass(
          module: 'ModuleB',
          className: 'BetaClass',
          rawSymbol: '...',
        ),
        const DetectedClass(
          module: 'ModuleA',
          className: 'AlphaClass',
          rawSymbol: '...',
        ),
        const DetectedClass(
          module: 'ModuleA',
          className: 'AnotherAlphaClass',
          rawSymbol: '...',
        ),
        const DetectedClass(
          module: null,
          className: 'ObjCClass',
          rawSymbol: '...',
        ),
      ];

      final grouped = groupClassesByModule(classes);
      expect(grouped.keys, containsAll(['ModuleA', 'ModuleB', null]));
      expect(grouped['ModuleA']!.map((c) => c.className).toList(), [
        'AlphaClass',
        'AnotherAlphaClass',
      ]);
      expect(grouped['ModuleB']!.map((c) => c.className).toList(), [
        'BetaClass',
      ]);
      expect(grouped[null]!.map((c) => c.className).toList(), ['ObjCClass']);
    });
  });

  group('formatReport', () {
    test('formats report with Swift module and visitor hint', () {
      final report = formatReport('path/to/classes.dylib', [
        const DetectedClass(
          module: 'classes',
          className: 'TestClassWrapper',
          rawSymbol: '_TtC7classes16TestClassWrapper',
        ),
      ]);

      expect(report, contains('Detected 1 class in path/to/classes.dylib:'));
      expect(report, contains("Module 'classes':"));
      expect(report, contains('- TestClassWrapper (classes.TestClassWrapper)'));
      expect(report, contains('fg.Visitor('));
      expect(report, contains('node.module'));
    });

    test('formats report for binary with only Objective-C classes', () {
      final report = formatReport('path/to/objc.dylib', [
        const DetectedClass(
          module: null,
          className: 'MyClass',
          rawSymbol: 'MyClass',
        ),
      ]);

      expect(report, contains('Objective-C (no Swift module):'));
      expect(report, contains('- MyClass'));
      // No Swift module visitor advice needed when no Swift classes exist
      expect(report, isNot(contains("Module '")));
    });

    test('formats message when no classes found', () {
      final report = formatReport('path/to/empty.dylib', []);
      expect(
        report,
        'No Objective-C or Swift class symbols found in path/to/empty.dylib.',
      );
    });
  });

  group('detectClasses end-to-end with mock runner', () {
    test('extracts and demangles classes from nm output', () async {
      Future<ProcessResult> mockRunner(String exe, List<String> args) async {
        expect(exe, 'nm');
        expect(args, ['test.dylib']);
        return _mockResult(
          stdout: '''
0000000000008088 D _OBJC_CLASS_\$__TtC7classes16TestClassWrapper
00000000000080b0 D _OBJC_CLASS_\$__TtC7classes21TestOtherClassWrapper
00000000000080d8 D _OBJC_CLASS_\$_PlainClass
''',
        );
      }

      final classes = await detectClasses('test.dylib', runProcess: mockRunner);
      expect(classes, hasLength(3));
      expect(classes.map((c) => c.qualifiedName).toList(), [
        'classes.TestClassWrapper',
        'classes.TestOtherClassWrapper',
        'PlainClass',
      ]);
    });

    test('throws ProcessException when nm returns non-zero exit code', () {
      Future<ProcessResult> failingRunner(String exe, List<String> args) async {
        return _mockResult(exitCode: 1, stderr: 'No such file or directory');
      }

      expect(
        () => detectClasses('invalid.dylib', runProcess: failingRunner),
        throwsA(isA<ProcessException>()),
      );
    });
  });
}
