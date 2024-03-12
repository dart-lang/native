// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'asset.dart';

part '../model/link_mode.dart';

/// The link mode for [NativeCodeAsset]s.
abstract final class LinkMode {
  /// Dynamic loading.
  ///
  /// Supported in the Dart and Flutter SDK.
  ///
  /// Note: Dynamic loading is not equal to dynamic linking. Dynamic linking
  /// would have to run the linker at compile-time, which is currently not
  /// supported in the Dart and Flutter SDK.
  static const LinkMode dynamic = LinkModeImpl.dynamic;

  /// Static linking.
  ///
  /// Not yet supported in the Dart and Flutter SDK.
  // TODO(https://github.com/dart-lang/sdk/issues/49418): Support static linking.
  static const LinkMode static = LinkModeImpl.static;

  /// Known values for [LinkMode].
  static const List<LinkMode> values = [
    dynamic,
    static,
  ];
}
