// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:coverage/coverage.dart';
import 'package:coverage/src/util.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'test_util.dart';

final _isolateLibPath = p.join('test', 'test_files', 'test_app_isolate.dart');

final _sampleAppFileUri = p.toUri(p.absolute(testAppPath)).toString();
final _isolateLibFileUri = p.toUri(p.absolute(_isolateLibPath)).toString();

void main() {
  test('collect_coverage_api', () async {
    final coverage = coverageDataFromJson(await _collectCoverage());
    expect(coverage, isNotEmpty);

    final sources = coverage.sources();

    for (var sampleCoverageData in sources[_sampleAppFileUri]!) {
      expect(sampleCoverageData['hits'], isNotEmpty);
    }

    for (var sampleCoverageData in sources[_isolateLibFileUri]!) {
      expect(sampleCoverageData['hits'], isNotEmpty);
    }
  });

  test('collect_coverage_api with scoped output', () async {
    final coverage = coverageDataFromJson(
      await _collectCoverage(scopedOutput: <String>{}..add('coverage')),
    );
    expect(coverage, isNotEmpty);

    final sources = coverage.sources();

    for (var key in sources.keys) {
      final uri = Uri.parse(key);
      expect(uri.path.startsWith('coverage'), isTrue);
    }
  });

  test('collect_coverage_api with isolateIds', () async {
    final coverage =
        coverageDataFromJson(await _collectCoverage(isolateIds: true));
    expect(coverage, isEmpty);
  });

  test('collect_coverage_api with function coverage', () async {
    final coverage =
        coverageDataFromJson(await _collectCoverage(functionCoverage: true));
    expect(coverage, isNotEmpty);

    final sources = coverage.sources();

    final functionInfo = functionInfoFromSources(sources);

    expect(
      functionInfo[_sampleAppFileUri]!,
      {
        'main': 1,
        'usedMethod': 1,
        'unusedMethod': 0,
      },
    );

    expect(
      functionInfo[_isolateLibFileUri]!,
      {
        'BarClass.BarClass': 1,
        'fooAsync': 1,
        'fooSync': 1,
        'isolateTask': 1,
        'BarClass.baz': 1
      },
    );
  });

  test('collect_coverage_api with branch coverage', () async {
    final coverage =
        coverageDataFromJson(await _collectCoverage(branchCoverage: true));
    expect(coverage, isNotEmpty);

    final sources = coverage.sources();

    // Dart VM versions before 2.17 don't support branch coverage.
    expect(sources[_sampleAppFileUri],
        everyElement(containsPair('branchHits', isNotEmpty)));
    expect(sources[_isolateLibFileUri],
        everyElement(containsPair('branchHits', isNotEmpty)));
  });

  test('collect_coverage_api with coverableLineCache', () async {
    final coverableLineCache = <String, Set<int>>{};
    final coverage =
        await _collectCoverage(coverableLineCache: coverableLineCache);
    final result = await HitMap.parseJson(
        coverage['coverage'] as List<Map<String, dynamic>>);

    expect(coverableLineCache, contains(_sampleAppFileUri));
    expect(coverableLineCache, contains(_isolateLibFileUri));

    // Expect that we have some missed lines.
    expect(result[_sampleAppFileUri]!.lineHits.containsValue(0), isTrue);
    expect(result[_isolateLibFileUri]!.lineHits.containsValue(0), isTrue);

    // Clear _sampleAppFileUri's cache entry, then gather coverage again. We're
    // doing this to verify that force compilation is disabled for these
    // libraries. The result should be that _isolateLibFileUri should be the
    // same, but _sampleAppFileUri should be missing all its missed lines.
    coverableLineCache[_sampleAppFileUri] = {};
    final coverage2 =
        await _collectCoverage(coverableLineCache: coverableLineCache);
    final result2 = await HitMap.parseJson(
        coverage2['coverage'] as List<Map<String, dynamic>>);

    // _isolateLibFileUri still has missed lines, but _sampleAppFileUri doesn't.
    expect(result2[_sampleAppFileUri]!.lineHits.containsValue(0), isFalse);
    expect(result2[_isolateLibFileUri]!.lineHits.containsValue(0), isTrue);

    // _isolateLibFileUri is the same. _sampleAppFileUri is the same, but
    // without all its missed lines.
    expect(result2[_isolateLibFileUri]!.lineHits,
        result[_isolateLibFileUri]!.lineHits);
    result[_sampleAppFileUri]!.lineHits.removeWhere((line, hits) => hits == 0);
    expect(result2[_sampleAppFileUri]!.lineHits,
        result[_sampleAppFileUri]!.lineHits);
  }, skip: !platformVersionCheck(3, 2));
}

Future<Map<String, dynamic>> _collectCoverage(
    {Set<String> scopedOutput = const {},
    bool isolateIds = false,
    bool functionCoverage = false,
    bool branchCoverage = false,
    Map<String, Set<int>>? coverableLineCache}) async {
  final openPort = await getOpenPort();

  // run the sample app, with the right flags
  final sampleProcess = await runTestApp(openPort);

  final serviceUri = await serviceUriFromProcess(sampleProcess.stdoutStream());
  final isolateIdSet = isolateIds ? <String>{} : null;

  return collect(serviceUri, true, true, false, scopedOutput,
      timeout: timeout,
      isolateIds: isolateIdSet,
      functionCoverage: functionCoverage,
      branchCoverage: branchCoverage,
      coverableLineCache: coverableLineCache);
}
