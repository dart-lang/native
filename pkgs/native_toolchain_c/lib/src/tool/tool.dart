// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'tool_resolver.dart';

class Tool {
  final String name;

  ToolResolver? defaultResolver;

  Tool({
    required this.name,
    this.defaultResolver,
  });

  @override
  bool operator ==(Object other) => other is Tool && name == other.name;

  @override
  int get hashCode => Object.hash(name, 133709);

  @override
  String toString() => 'Tool($name)';
}
