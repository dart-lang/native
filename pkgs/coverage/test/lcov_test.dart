// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:coverage/coverage.dart';
import 'package:coverage/src/util.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

final _sampleAppPath = p.join('test', 'test_files', 'test_app.dart');
final _sampleGeneratedPath = p.join('test', 'test_files', 'test_app.g.dart');
final _isolateLibPath = p.join('test', 'test_files', 'test_app_isolate.dart');

final _sampleAppFileUri = p.toUri(p.absolute(_sampleAppPath)).toString();
final _sampleGeneratedFileUri =
    p.toUri(p.absolute(_sampleGeneratedPath)).toString();
final _isolateLibFileUri = p.toUri(p.absolute(_isolateLibPath)).toString();

void main() {
  test('validate hitMap', () async {
    final hitmap = await _getHitMap();

    expect(hitmap, contains(_sampleAppFileUri));
    expect(hitmap, contains(_sampleGeneratedFileUri));
    expect(hitmap, contains(_isolateLibFileUri));
    expect(hitmap, contains('package:coverage/src/util.dart'));

    final sampleAppHitMap = hitmap[_sampleAppFileUri];
    final sampleAppHitLines = sampleAppHitMap?.lineHits;
    final sampleAppHitFuncs = sampleAppHitMap?.funcHits;
    final sampleAppFuncNames = sampleAppHitMap?.funcNames;
    final sampleAppBranchHits = sampleAppHitMap?.branchHits;

    expect(sampleAppHitLines, containsPair(53, greaterThanOrEqualTo(1)),
        reason: 'be careful if you modify the test file');
    expect(sampleAppHitLines, containsPair(57, 0),
        reason: 'be careful if you modify the test file');
    expect(sampleAppHitLines, isNot(contains(39)),
        reason: 'be careful if you modify the test file');
    expect(sampleAppHitFuncs, containsPair(52, 1),
        reason: 'be careful if you modify the test file');
    expect(sampleAppHitFuncs, containsPair(56, 0),
        reason: 'be careful if you modify the test file');
    expect(sampleAppFuncNames, containsPair(52, 'usedMethod'),
        reason: 'be careful if you modify the test file');
    expect(sampleAppBranchHits, containsPair(48, 1),
        reason: 'be careful if you modify the test file');
  });

  test('validate hitMap, old VM without branch coverage', () async {
    final hitmap = await _getHitMap();

    expect(hitmap, contains(_sampleAppFileUri));
    expect(hitmap, contains(_sampleGeneratedFileUri));
    expect(hitmap, contains(_isolateLibFileUri));
    expect(hitmap, contains('package:coverage/src/util.dart'));

    final sampleAppHitMap = hitmap[_sampleAppFileUri];
    final sampleAppHitLines = sampleAppHitMap?.lineHits;
    final sampleAppHitFuncs = sampleAppHitMap?.funcHits;
    final sampleAppFuncNames = sampleAppHitMap?.funcNames;

    expect(sampleAppHitLines, containsPair(53, greaterThanOrEqualTo(1)),
        reason: 'be careful if you modify the test file');
    expect(sampleAppHitLines, containsPair(57, 0),
        reason: 'be careful if you modify the test file');
    expect(sampleAppHitLines, isNot(contains(39)),
        reason: 'be careful if you modify the test file');
    expect(sampleAppHitFuncs, containsPair(52, 1),
        reason: 'be careful if you modify the test file');
    expect(sampleAppHitFuncs, containsPair(56, 0),
        reason: 'be careful if you modify the test file');
    expect(sampleAppFuncNames, containsPair(52, 'usedMethod'),
        reason: 'be careful if you modify the test file');
  });

  group('LcovFormatter', () {
    test('format()', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      // ignore: deprecated_member_use_from_same_package
      final formatter = LcovFormatter(resolver);

      final res = await formatter
          .format(hitmap.map((key, value) => MapEntry(key, value.lineHits)));

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, contains(p.absolute(_sampleGeneratedPath)));
      expect(res, contains(p.absolute(_isolateLibPath)));
      expect(res, contains(p.absolute(p.join('lib', 'src', 'util.dart'))));
    });

    test('formatLcov()', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res = hitmap.formatLcov(resolver);

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, contains(p.absolute(_sampleGeneratedPath)));
      expect(res, contains(p.absolute(_isolateLibPath)));
      expect(res, contains(p.absolute(p.join('lib', 'src', 'util.dart'))));
    });

    test('formatLcov() includes files in reportOn list', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res = hitmap.formatLcov(resolver, reportOn: ['lib/', 'test/']);

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, contains(p.absolute(_sampleGeneratedPath)));
      expect(res, contains(p.absolute(_isolateLibPath)));
      expect(res, contains(p.absolute(p.join('lib', 'src', 'util.dart'))));
    });

    test('formatLcov() excludes files not in reportOn list', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res = hitmap.formatLcov(resolver, reportOn: ['lib/']);

      expect(res, isNot(contains(p.absolute(_sampleAppPath))));
      expect(res, isNot(contains(p.absolute(_sampleGeneratedPath))));
      expect(res, isNot(contains(p.absolute(_isolateLibPath))));
      expect(res, contains(p.absolute(p.join('lib', 'src', 'util.dart'))));
    });

    test('formatLcov() excludes files matching glob patterns', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res = hitmap.formatLcov(
        resolver,
        ignoreGlobs: {Glob('**/*.g.dart'), Glob('**/util.dart')},
      );

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, isNot(contains(p.absolute(_sampleGeneratedPath))));
      expect(res, contains(p.absolute(_isolateLibPath)));
      expect(
        res,
        isNot(contains(p.absolute(p.join('lib', 'src', 'util.dart')))),
      );
    });

    test(
        'formatLcov() excludes files matching glob patterns regardless of their'
        'presence on reportOn list', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res = hitmap.formatLcov(
        resolver,
        reportOn: ['test/'],
        ignoreGlobs: {Glob('**/*.g.dart')},
      );

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, isNot(contains(p.absolute(_sampleGeneratedPath))));
      expect(res, contains(p.absolute(_isolateLibPath)));
    });

    test('formatLcov() uses paths relative to basePath', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res = hitmap.formatLcov(resolver, basePath: p.absolute('lib'));

      expect(
          res, isNot(contains(p.absolute(p.join('lib', 'src', 'util.dart')))));
      expect(res, contains(p.join('src', 'util.dart')));
    });
  });

  group('PrettyPrintFormatter', () {
    test('format()', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      // ignore: deprecated_member_use_from_same_package
      final formatter = PrettyPrintFormatter(resolver, Loader());

      final res = await formatter
          .format(hitmap.map((key, value) => MapEntry(key, value.lineHits)));

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, contains(p.absolute(_sampleGeneratedPath)));
      expect(res, contains(p.absolute(_isolateLibPath)));
      expect(res, contains(p.absolute(p.join('lib', 'src', 'util.dart'))));

      // be very careful if you change the test file
      expect(res, contains('      0|  return a - b;'));

      expect(res, contains('|  return withTimeout(() async {'),
          reason: 'be careful if you change lib/src/util.dart');

      final hitLineRegexp = RegExp(r'\s+(\d+)\|  return a \+ b;');
      final match = hitLineRegexp.allMatches(res).single;

      final hitCount = int.parse(match[1]!);
      expect(hitCount, greaterThanOrEqualTo(1));
    });

    test('prettyPrint()', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res = await hitmap.prettyPrint(resolver, Loader());

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, contains(p.absolute(_sampleGeneratedPath)));
      expect(res, contains(p.absolute(_isolateLibPath)));
      expect(res, contains(p.absolute(p.join('lib', 'src', 'util.dart'))));

      // be very careful if you change the test file
      expect(res, contains('      0|  return a - b;'));

      expect(res, contains('|  return withTimeout(() async {'),
          reason: 'be careful if you change lib/src/util.dart');

      final hitLineRegexp = RegExp(r'\s+(\d+)\|  return a \+ b;');
      final match = hitLineRegexp.allMatches(res).single;

      final hitCount = int.parse(match[1]!);
      expect(hitCount, greaterThanOrEqualTo(1));
    });

    test('prettyPrint() includes files in reportOn list', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res = await hitmap
          .prettyPrint(resolver, Loader(), reportOn: ['lib/', 'test/']);

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, contains(p.absolute(_sampleGeneratedPath)));
      expect(res, contains(p.absolute(_isolateLibPath)));
      expect(res, contains(p.absolute(p.join('lib', 'src', 'util.dart'))));
    });

    test('prettyPrint() excludes files not in reportOn list', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res =
          await hitmap.prettyPrint(resolver, Loader(), reportOn: ['lib/']);

      expect(res, isNot(contains(p.absolute(_sampleAppPath))));
      expect(res, isNot(contains(p.absolute(_sampleGeneratedPath))));
      expect(res, isNot(contains(p.absolute(_isolateLibPath))));
      expect(res, contains(p.absolute(p.join('lib', 'src', 'util.dart'))));
    });

    test('prettyPrint() excludes files matching glob patterns', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res = await hitmap.prettyPrint(
        resolver,
        Loader(),
        ignoreGlobs: {Glob('**/*.g.dart'), Glob('**/util.dart')},
      );

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, isNot(contains(p.absolute(_sampleGeneratedPath))));
      expect(res, contains(p.absolute(_isolateLibPath)));
      expect(
        res,
        isNot(contains(p.absolute(p.join('lib', 'src', 'util.dart')))),
      );
    });

    test(
        'prettyPrint() excludes files matching glob patterns regardless of'
        'their presence on reportOn list', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res = await hitmap.prettyPrint(
        resolver,
        Loader(),
        reportOn: ['test/'],
        ignoreGlobs: {Glob('**/*.g.dart')},
      );

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, isNot(contains(p.absolute(_sampleGeneratedPath))));
      expect(res, contains(p.absolute(_isolateLibPath)));
    });

    test('prettyPrint() functions', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res =
          await hitmap.prettyPrint(resolver, Loader(), reportFuncs: true);

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, contains(p.absolute(_sampleGeneratedPath)));
      expect(res, contains(p.absolute(_isolateLibPath)));
      expect(res, contains(p.absolute(p.join('lib', 'src', 'util.dart'))));

      // be very careful if you change the test file
      expect(res, contains('      1|Future<void> main() async {'));
      expect(res, contains('      1|int usedMethod(int a, int b) {'));
      expect(res, contains('      0|int unusedMethod(int a, int b) {'));
      expect(res, contains('       |  return a + b;'));
    });

    test('prettyPrint() branches', () async {
      final hitmap = await _getHitMap();

      final resolver = await Resolver.create(packagePath: '.');
      final res =
          await hitmap.prettyPrint(resolver, Loader(), reportBranches: true);

      expect(res, contains(p.absolute(_sampleAppPath)));
      expect(res, contains(p.absolute(_sampleGeneratedPath)));
      expect(res, contains(p.absolute(_isolateLibPath)));
      expect(res, contains(p.absolute(p.join('lib', 'src', 'util.dart'))));

      // be very careful if you change the test file
      expect(res, contains('      1|  if (x == answer) {'));
      expect(res, contains('      0|  while (i < lines.length) {'));
      expect(res, contains('       |  bar.baz();'));
    });
  });
}

Future<Map<String, HitMap>> _getHitMap() async {
  expect(FileSystemEntity.isFileSync(_sampleAppPath), isTrue);

  // select service port.
  final port = await getOpenPort();

  // start sample app.
  final sampleAppArgs = [
    '--pause-isolates-on-exit',
    '--enable-vm-service=$port',
    '--branch-coverage',
    _sampleAppPath
  ];
  final sampleProcess =
      await TestProcess.start(Platform.resolvedExecutable, sampleAppArgs);

  final serviceUri = await serviceUriFromProcess(sampleProcess.stdoutStream());

  // collect hit map.
  final coverageJson = (await collect(serviceUri, true, true, false, <String>{},
      functionCoverage: true,
      branchCoverage: true))['coverage'] as List<Map<String, dynamic>>;
  final hitMap = HitMap.parseJson(coverageJson);

  await sampleProcess.shouldExit(0);

  return hitMap;
}
