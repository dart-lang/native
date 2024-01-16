// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../api/link_mode.dart' as api;

class LinkMode implements api.LinkMode {
  final String name;

  const LinkMode._(this.name);

  static const LinkMode dynamic = LinkMode._('dynamic');
  static const LinkMode static = LinkMode._('static');

  /// Known values for [LinkMode].
  static const List<LinkMode> values = [
    dynamic,
    static,
  ];

  factory LinkMode.fromName(String name) =>
      values.where((element) => element.name == name).first;

  @override
  String toString() => name;
}
