// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:c_compiler/src/tool/tool.dart';
import 'package:c_compiler/src/tool/tool_instance.dart';
import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  test('equals and hashCode', () {
    final barToolInstance =
        ToolInstance(tool: Tool(name: 'bar'), uri: Uri.file('path/to/bar'));
    final fooToolInstance =
        ToolInstance(tool: Tool(name: 'foo'), uri: Uri.file('path/to/foo'));

    expect(barToolInstance, barToolInstance);
    expect(barToolInstance != fooToolInstance, true);

    expect(barToolInstance.hashCode, barToolInstance.hashCode);
    expect(barToolInstance.hashCode != fooToolInstance.hashCode, true);

    expect(
        ToolInstance(
                tool: Tool(name: 'bar'),
                version: Version(1, 0, 0),
                uri: Uri.file('path/to/bar')) !=
            ToolInstance(
                tool: Tool(name: 'bar'),
                version: Version(1, 0, 1),
                uri: Uri.file('path/to/bar')),
        true);
  });

  test('compareTo', () {
    final toolInstances = [
      ToolInstance(
        tool: Tool(name: 'bar'),
        version: Version(2, 0, 0),
        uri: Uri.file('path/to/bar'),
      ),
      ToolInstance(
          tool: Tool(name: 'bar'),
          version: Version(1, 0, 0),
          uri: Uri.file('path/to/bar')),
      ToolInstance(
        tool: Tool(name: 'bar'),
        uri: Uri.file('path/to/bar'),
      ),
      ToolInstance(
        tool: Tool(name: 'bar'),
        uri: Uri.file('path/to/some/other/bar'),
      ),
      ToolInstance(
        tool: Tool(name: 'baz'),
        uri: Uri.file('path/to/baz'),
      ),
    ];

    final toolInstancesSorted = [...toolInstances]..sort();
    expect(DeepCollectionEquality().equals(toolInstancesSorted, toolInstances),
        true);
  });

  test('toString', () {
    final instance = ToolInstance(
      tool: Tool(name: 'bar'),
      version: Version(1, 0, 0),
      uri: Uri.file('path/to/bar'),
    );

    expect(instance.toString(), contains('bar'));
    expect(instance.toString(), contains('1.0.0'));
    expect(instance.toString(), contains('path/to/bar'));
  });

  test('copyWith', () {
    final instance = ToolInstance(
      tool: Tool(name: 'bar'),
      version: Version(1, 0, 0),
      uri: Uri.file('path/to/bar'),
    );

    expect(instance.copyWith(), instance);
    expect(instance.copyWith(uri: Uri.file('foo/bar')) != instance, true);
  });
}
