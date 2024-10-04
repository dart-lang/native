// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:coverage/coverage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';

import 'collect_coverage_mock_test.mocks.dart';

@GenerateMocks([VmService])
SourceReportRange _range(int scriptIndex, SourceReportCoverage coverage) =>
    SourceReportRange(scriptIndex: scriptIndex, coverage: coverage);

IsolateRef _isoRef(String id, String isoGroupId) =>
    IsolateRef(id: id, isolateGroupId: isoGroupId);

IsolateGroupRef _isoGroupRef(String id) => IsolateGroupRef(id: id);

IsolateGroup _isoGroup(String id, List<IsolateRef> isolates) =>
    IsolateGroup(id: id, isolates: isolates);

class FakeSentinelException implements SentinelException {
  @override
  dynamic noSuchMethod(Invocation invocation) {}
}

MockVmService _mockService(
  int majorVersion,
  int minorVersion, {
  Map<String, List<String>> isolateGroups = const {
    'isolateGroup': ['isolate'],
  },
}) {
  final service = MockVmService();
  final isoRefs = <IsolateRef>[];
  final isoGroupRefs = <IsolateGroupRef>[];
  final isoGroups = <IsolateGroup>[];
  for (final group in isolateGroups.entries) {
    isoGroupRefs.add(_isoGroupRef(group.key));
    final isosOfGroup = <IsolateRef>[];
    for (final isoId in group.value) {
      isosOfGroup.add(_isoRef(isoId, group.key));
    }
    isoGroups.add(_isoGroup(group.key, isosOfGroup));
    isoRefs.addAll(isosOfGroup);
  }
  when(service.getVM()).thenAnswer(
      (_) async => VM(isolates: isoRefs, isolateGroups: isoGroupRefs));
  for (final group in isoGroups) {
    when(service.getIsolateGroup(group.id)).thenAnswer((_) async => group);
  }
  when(service.getVersion()).thenAnswer(
      (_) async => Version(major: majorVersion, minor: minorVersion));
  return service;
}

void main() {
  group('Mock VM Service', () {
    test('Collect coverage', () async {
      final service = _mockService(4, 13);
      when(service.getSourceReport(
        'isolate',
        ['Coverage'],
        forceCompile: true,
        reportLines: true,
      )).thenAnswer((_) async => SourceReport(
            ranges: [
              _range(
                0,
                SourceReportCoverage(
                  hits: [12],
                  misses: [47],
                ),
              ),
              _range(
                1,
                SourceReportCoverage(
                  hits: [95],
                  misses: [52],
                ),
              ),
            ],
            scripts: [
              ScriptRef(
                uri: 'package:foo/foo.dart',
                id: 'foo',
              ),
              ScriptRef(
                uri: 'package:bar/bar.dart',
                id: 'bar',
              ),
            ],
          ));

      final jsonResult = await collect(Uri(), false, false, false, null,
          serviceOverrideForTesting: service);
      final result = await HitMap.parseJson(
          jsonResult['coverage'] as List<Map<String, dynamic>>);

      expect(result.length, 2);
      expect(result['package:foo/foo.dart']?.lineHits, {12: 1, 47: 0});
      expect(result['package:bar/bar.dart']?.lineHits, {95: 1, 52: 0});
    });

    test('Collect coverage, scoped output', () async {
      final service = _mockService(4, 13);
      when(service.getSourceReport(
        'isolate',
        ['Coverage'],
        forceCompile: true,
        reportLines: true,
        libraryFilters: ['package:foo/'],
      )).thenAnswer((_) async => SourceReport(
            ranges: [
              _range(
                0,
                SourceReportCoverage(
                  hits: [12],
                  misses: [47],
                ),
              ),
            ],
            scripts: [
              ScriptRef(
                uri: 'package:foo/foo.dart',
                id: 'foo',
              ),
            ],
          ));

      final jsonResult = await collect(Uri(), false, false, false, {'foo'},
          serviceOverrideForTesting: service);
      final result = await HitMap.parseJson(
          jsonResult['coverage'] as List<Map<String, dynamic>>);

      expect(result.length, 1);
      expect(result['package:foo/foo.dart']?.lineHits, {12: 1, 47: 0});
    });

    test('Collect coverage, fast isolate group deduping', () async {
      final service = _mockService(4, 13, isolateGroups: {
        'isolateGroupA': ['isolate1', 'isolate2'],
        'isolateGroupB': ['isolate3'],
      });
      when(service.getSourceReport(
        'isolate1',
        ['Coverage'],
        forceCompile: true,
        reportLines: true,
      )).thenAnswer((_) async => SourceReport(
            ranges: [
              _range(
                0,
                SourceReportCoverage(
                  hits: [12],
                  misses: [47],
                ),
              ),
              _range(
                1,
                SourceReportCoverage(
                  hits: [95],
                  misses: [52],
                ),
              ),
            ],
            scripts: [
              ScriptRef(
                uri: 'package:foo/foo.dart',
                id: 'foo',
              ),
              ScriptRef(
                uri: 'package:bar/bar.dart',
                id: 'bar',
              ),
            ],
          ));
      when(service.getSourceReport(
        'isolate3',
        ['Coverage'],
        forceCompile: true,
        reportLines: true,
      )).thenAnswer((_) async => SourceReport(
            ranges: [
              _range(
                0,
                SourceReportCoverage(
                  hits: [34],
                  misses: [61],
                ),
              ),
            ],
            scripts: [
              ScriptRef(
                uri: 'package:baz/baz.dart',
                id: 'baz',
              ),
            ],
          ));

      final jsonResult = await collect(Uri(), false, false, false, null,
          serviceOverrideForTesting: service);
      final result = await HitMap.parseJson(
          jsonResult['coverage'] as List<Map<String, dynamic>>);

      expect(result.length, 3);
      expect(result['package:foo/foo.dart']?.lineHits, {12: 1, 47: 0});
      expect(result['package:bar/bar.dart']?.lineHits, {95: 1, 52: 0});
      expect(result['package:baz/baz.dart']?.lineHits, {34: 1, 61: 0});
      verifyNever(service.getSourceReport('isolate2', ['Coverage'],
          forceCompile: true, reportLines: true));
      verifyNever(service.getIsolateGroup('isolateGroupA'));
      verifyNever(service.getIsolateGroup('isolateGroupB'));
    });

    test(
        'Collect coverage, no scoped output, '
        'handles SentinelException from getSourceReport', () async {
      final service = _mockService(4, 13);
      when(service.getSourceReport(
        'isolate',
        ['Coverage'],
        forceCompile: true,
        reportLines: true,
      )).thenThrow(FakeSentinelException());

      final jsonResult = await collect(Uri(), false, false, false, null,
          serviceOverrideForTesting: service);
      final result = await HitMap.parseJson(
          jsonResult['coverage'] as List<Map<String, dynamic>>);

      expect(result.length, 0);
    });

    test('Collect coverage, coverableLineCache', () async {
      // Expect that on the first getSourceReport call, librariesAlreadyCompiled
      // is empty.
      final service = _mockService(4, 13);
      when(service.getSourceReport(
        'isolate',
        ['Coverage'],
        forceCompile: true,
        reportLines: true,
        librariesAlreadyCompiled: [],
      )).thenAnswer((_) async => SourceReport(
            ranges: [
              _range(
                0,
                SourceReportCoverage(
                  hits: [12],
                  misses: [47],
                ),
              ),
              _range(
                1,
                SourceReportCoverage(
                  hits: [95],
                  misses: [52],
                ),
              ),
            ],
            scripts: [
              ScriptRef(
                uri: 'package:foo/foo.dart',
                id: 'foo',
              ),
              ScriptRef(
                uri: 'package:bar/bar.dart',
                id: 'bar',
              ),
            ],
          ));

      final coverableLineCache = <String, Set<int>>{};
      final jsonResult = await collect(Uri(), false, false, false, null,
          coverableLineCache: coverableLineCache,
          serviceOverrideForTesting: service);
      final result = await HitMap.parseJson(
          jsonResult['coverage'] as List<Map<String, dynamic>>);

      expect(result.length, 2);
      expect(result['package:foo/foo.dart']?.lineHits, {12: 1, 47: 0});
      expect(result['package:bar/bar.dart']?.lineHits, {95: 1, 52: 0});

      // The coverableLineCache should now be filled with all the lines that
      // were hit or missed.
      expect(coverableLineCache, {
        'package:foo/foo.dart': {12, 47},
        'package:bar/bar.dart': {95, 52},
      });

      // The second getSourceReport call should now list all the libraries we've
      // seen. The response won't contain any misses for these libraries,
      // because they won't be force compiled. We'll also return a 3rd library,
      // which will contain misses, as it hasn't been compiled yet.
      when(service.getSourceReport(
        'isolate',
        ['Coverage'],
        forceCompile: true,
        reportLines: true,
        librariesAlreadyCompiled: [
          'package:foo/foo.dart',
          'package:bar/bar.dart'
        ],
      )).thenAnswer((_) async => SourceReport(
            ranges: [
              _range(
                0,
                SourceReportCoverage(
                  hits: [47],
                ),
              ),
              _range(
                1,
                SourceReportCoverage(
                  hits: [95],
                ),
              ),
              _range(
                2,
                SourceReportCoverage(
                  hits: [36],
                  misses: [81],
                ),
              ),
            ],
            scripts: [
              ScriptRef(
                uri: 'package:foo/foo.dart',
                id: 'foo',
              ),
              ScriptRef(
                uri: 'package:bar/bar.dart',
                id: 'bar',
              ),
              ScriptRef(
                uri: 'package:baz/baz.dart',
                id: 'baz',
              ),
            ],
          ));

      final jsonResult2 = await collect(Uri(), false, false, false, null,
          coverableLineCache: coverableLineCache,
          serviceOverrideForTesting: service);
      final result2 = await HitMap.parseJson(
          jsonResult2['coverage'] as List<Map<String, dynamic>>);

      // The missed lines still appear in foo and bar, even though they weren't
      // returned in the response. They were read from the cache.
      expect(result2.length, 3);
      expect(result2['package:foo/foo.dart']?.lineHits, {12: 0, 47: 1});
      expect(result2['package:bar/bar.dart']?.lineHits, {95: 1, 52: 0});
      expect(result2['package:baz/baz.dart']?.lineHits, {36: 1, 81: 0});

      // The coverableLineCache should now also contain the baz library.
      expect(coverableLineCache, {
        'package:foo/foo.dart': {12, 47},
        'package:bar/bar.dart': {95, 52},
        'package:baz/baz.dart': {36, 81},
      });
    });

    test(
        'Collect coverage, scoped output, '
        'handles SourceReports that contain unfiltered ranges', () async {
      // Regression test for https://github.com/dart-lang/tools/issues/530
      final service = _mockService(4, 13);
      when(service.getSourceReport(
        'isolate',
        ['Coverage'],
        forceCompile: true,
        reportLines: true,
        libraryFilters: ['package:foo/'],
      )).thenAnswer((_) async => SourceReport(
            ranges: [
              _range(
                0,
                SourceReportCoverage(
                  hits: [12],
                  misses: [47],
                ),
              ),
              _range(
                1,
                SourceReportCoverage(
                  hits: [86],
                  misses: [91],
                ),
              ),
            ],
            scripts: [
              ScriptRef(
                uri: 'package:foo/foo.dart',
                id: 'foo',
              ),
              ScriptRef(
                uri: 'package:bar/bar.dart',
                id: 'bar',
              ),
            ],
          ));

      final jsonResult = await collect(Uri(), false, false, false, {'foo'},
          serviceOverrideForTesting: service);
      final result = await HitMap.parseJson(
          jsonResult['coverage'] as List<Map<String, dynamic>>);

      expect(result.length, 1);
      expect(result['package:foo/foo.dart']?.lineHits, {12: 1, 47: 0});
    });
  });
}
