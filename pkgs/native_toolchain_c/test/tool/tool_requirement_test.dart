// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_toolchain_c/src/tool/tool.dart';
import 'package:native_toolchain_c/src/tool/tool_instance.dart';
import 'package:native_toolchain_c/src/tool/tool_requirement.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  test('toString', () {
    final requirement = ToolRequirement(
      Tool(name: 'clang'),
      minimumVersion: Version(10, 0, 0),
    );
    expect(requirement.toString(), contains('clang'));
    expect(requirement.toString(), contains('10.0.0'));
  });

  test('RequireOne', () {
    final requirement = RequireOne([
      ToolRequirement(Tool(name: 'bar'), minimumVersion: Version(10, 0, 0)),
      ToolRequirement(Tool(name: 'foo'), minimumVersion: Version(10, 0, 0)),
    ]);
    final toolInstances = [
      ToolInstance(
        tool: Tool(name: 'bar'),
        version: Version(10, 0, 0),
        uri: Uri.file('path/to/bar'),
      ),
      ToolInstance(
        tool: Tool(name: 'foo'),
        version: Version(9, 0, 0),
        uri: Uri.file('path/to/foo'),
      ),
    ];
    final result = requirement.satisfy(toolInstances);
    expect(result, [
      ToolInstance(
        tool: Tool(name: 'bar'),
        version: Version(10, 0, 0),
        uri: Uri.file('path/to/bar'),
      ),
    ]);
  });
}
