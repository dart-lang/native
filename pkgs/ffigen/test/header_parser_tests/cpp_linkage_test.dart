// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator.dart' as cg;
import 'package:ffigen/src/context.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

final _header = Uri.file(absPath('test/native_cpp_test/cpp_extern_c_test.h'));

const _cLinkageFuncs = {'add', 'deep', 'reset'};
const _cppLinkageFuncs = {'outside', 'nestedCpp', 'applyTwice'};

cg.Library _parse(FfiGenerator generator, {List<String>? warnings}) {
  final tmpDir = Directory(
    absPath('test/.temp test output'),
  ).createTempSync().path;
  return parser.parse(
    Context(
      createTestLogger(capturedMessages: warnings, level: Level.WARNING),
      generator,
      tmpDir: tmpDir,
    ),
  );
}

Map<String, bool> _funcLinkage(cg.Library library) => {
  for (final f in library.bindings.whereType<cg.Func>())
    f.originalName: f.hasCppLinkage,
};

Map<String, bool> _globalLinkage(cg.Library library) => {
  for (final g in library.bindings.whereType<cg.Global>())
    g.originalName: g.hasCppLinkage,
};

void main() {
  group('cpp_linkage', () {
    group('with C++ support', () {
      late cg.Library library;

      setUpAll(() {
        library = _parse(
          FfiGenerator(
            output: Output(dart: DartOutput(path: Uri.file('unused'))),
            input: Input(entryPoints: [_header]),
            cpp: const Cpp(),
            visitors: [
              Visitor(
                func: (node) => node.isIncluded = true,
                global: (node) => node.isIncluded = true,
              ),
            ],
          ),
        );
      });

      test('functions inside extern "C" have C linkage', () {
        final linkage = _funcLinkage(library);
        for (final name in _cLinkageFuncs) {
          expect(linkage[name], isFalse, reason: name);
        }
      });

      test('functions outside extern "C" have C++ linkage', () {
        final linkage = _funcLinkage(library);
        for (final name in _cppLinkageFuncs) {
          expect(linkage[name], isTrue, reason: name);
        }
      });

      test('globals follow the same rule', () {
        final linkage = _globalLinkage(library);
        expect(linkage['counter'], isFalse);
        expect(linkage['outsideCounter'], isTrue);
      });

      test('C++ linkage bindings look up their wrappers', () {
        final outside = library.getBinding('outside') as cg.Func;
        expect(outside.lookupSymbol, 'ffigen_outside');
        final add = library.getBinding('add') as cg.Func;
        expect(add.lookupSymbol, 'add');
      });
    });

    group('without C++ support', () {
      late cg.Library library;
      final warnings = <String>[];

      setUpAll(() {
        library = _parse(
          FfiGenerator(
            output: Output(dart: DartOutput(path: Uri.file('unused'))),
            input: Input(
              entryPoints: [_header],
              compilerOptions: [
                '-x',
                'c++',
                '-std=c++17',
                if (Platform.isMacOS) ...['-isysroot', macSdkPath],
              ],
            ),
            visitors: [
              Visitor(
                func: (node) => node.isIncluded = true,
                global: (node) => node.isIncluded = true,
              ),
            ],
          ),
          warnings: warnings,
        );
      });

      test('no wrappers are generated', () {
        expect(_funcLinkage(library).values, everyElement(isFalse));
        expect(_globalLinkage(library).values, everyElement(isFalse));
      });

      test('C++ linkage declarations are warned about', () {
        final warned = warnings.where((w) => w.contains('C++ linkage'));
        for (final name in _cppLinkageFuncs) {
          expect(warned, contains(contains("'$name'")));
        }
        expect(warned, contains(contains("'outsideCounter'")));
        for (final name in {..._cLinkageFuncs, 'counter'}) {
          expect(warned, isNot(contains(contains("'$name'"))));
        }
      });
    });
  });
}
