// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/link_mode.dart';

class LinkModeImpl implements LinkMode {
  final String name;

  const LinkModeImpl._(this.name);

  static const LinkModeImpl dynamic = LinkModeImpl._('dynamic');
  static const LinkModeImpl static = LinkModeImpl._('static');

  /// Known values for [LinkModeImpl].
  static const List<LinkModeImpl> values = [
    dynamic,
    static,
  ];

  factory LinkModeImpl.fromName(String name) =>
      values.where((element) => element.name == name).first;

  @override
  String toString() => name;
}
