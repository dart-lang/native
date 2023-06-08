// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class BuildMode {
  final String name;

  const BuildMode._(this.name);

  static const debug = BuildMode._('debug');
  static const release = BuildMode._('release');

  static const values = [
    debug,
    release,
  ];

  factory BuildMode.fromString(String target) =>
      values.firstWhere((e) => e.name == target);

  /// The `package:config` key preferably used.
  static const String configKey = 'build_mode';

  @override
  String toString() => name;
}
