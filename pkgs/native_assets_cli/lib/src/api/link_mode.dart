// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model/link_mode.dart' as model;

abstract class LinkMode {
  static const LinkMode dynamic = model.LinkMode.dynamic;
  static const LinkMode static = model.LinkMode.static;

  /// Known values for [LinkMode].
  static const List<LinkMode> values = [
    dynamic,
    static,
  ];
}
