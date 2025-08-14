// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_doc_dartifier/src/context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('Get imported packages summary', () async {
    final context = await Context.create(
      Directory.current.path,
      p.absolute('test/dartify_simple_cases/bindings.dart'),
    );
    expect(context.importedPackages.contains('package:jni/jni.dart'), isTrue);
    expect(
      context.importedPackages.contains('package:jni/_internal.dart'),
      isTrue,
    );
    expect(context.libraryClassesSummaries.isNotEmpty, isTrue);
  });
}
