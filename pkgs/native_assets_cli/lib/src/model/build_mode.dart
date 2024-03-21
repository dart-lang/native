// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/build_mode.dart';

final class BuildModeImpl implements BuildMode {
  @override
  final String name;

  const BuildModeImpl._(this.name);

  static const debug = BuildModeImpl._('debug');
  static const release = BuildModeImpl._('release');

  static const values = [
    debug,
    release,
  ];

  factory BuildModeImpl.fromString(String target) =>
      values.firstWhere((e) => e.name == target);

  static const String configKey = 'build_mode';

  @override
  String toString() => name;
}
