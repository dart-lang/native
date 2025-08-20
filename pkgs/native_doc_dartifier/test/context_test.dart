// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_doc_dartifier/src/context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  Context? context;
  setUpAll(() async {
    context = await Context.create(
      Directory.current.path,
      p.absolute('test/dartify_simple_cases/bindings.dart'),
    );
    final logFile = File('output.txt');
    await logFile.writeAsString(context!.toDartLikeRepresentation());
  });

  test('Get imported packages only', () {
    expect(context!.importedPackages.length, 2);
    expect(context!.importedPackages.contains('package:jni/jni.dart'), isTrue);
    expect(
      context!.importedPackages.contains('package:jni/_internal.dart'),
      isTrue,
    );
    expect(context!.importedPackages.contains('dart:core'), isFalse);
  });

  test('Get public classes from package', () {
    final jniSummary = context!.packageSummaries.firstWhere(
      (package) => package.packageName == 'package:jni/jni.dart',
    );
    expect(
      jniSummary.classesSummaries.any(
        (classSummary) => classSummary.classDeclerationDisplay.contains(
          'class JArray<E extends JObject?>',
        ),
      ),
      isTrue,
    );

    expect(
      jniSummary.classesSummaries.any(
        (classSummary) => classSummary.classDeclerationDisplay.contains(
          'class JSet<\$E extends JObject?>',
        ),
      ),
      isTrue,
    );

    expect(
      jniSummary.classesSummaries.any(
        (classSummary) => classSummary.classDeclerationDisplay.contains(
          'class Arena implements Allocator',
        ),
      ),
      isTrue,
    );
  });

  test('Get top level functions', () {
    final jniSummary = context!.packageSummaries.firstWhere(
      (package) => package.packageName == 'package:jni/jni.dart',
    );
    expect(
      jniSummary.topLevelFunctions.any(
        (function) => function.contains(
          // ignore: lines_longer_than_80_chars
          'using<R>(R Function(Arena) computation, [Allocator wrappedAllocator = calloc])',
        ),
      ),
      isTrue,
    );
  });
}
