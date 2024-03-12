// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/link_mode.dart';

final class LinkModeImpl implements LinkMode {
  final String name;

  const LinkModeImpl._(this.name);

  static const LinkModeImpl dynamicLoading = LinkModeImpl._('dynamic');
  static const LinkModeImpl static = LinkModeImpl._('static');

  /// Known values for [LinkModeImpl].
  static const List<LinkModeImpl> _values = [
    dynamicLoading,
    static,
  ];

  factory LinkModeImpl.fromName(String name) =>
      _values.where((element) => element.name == name).first;

  @override
  String toString() => name;
}
