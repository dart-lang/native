// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'asset.dart';

part '../model/link_mode.dart';

/// The link mode for [CCodeAsset]s.
abstract class LinkMode {
  /// Dynamic loading.
  static const LinkMode dynamic = LinkModeImpl.dynamic;

  /// Static linking.
  static const LinkMode static = LinkModeImpl.static;

  /// Known values for [LinkMode].
  static const List<LinkMode> values = [
    dynamic,
    static,
  ];
}
