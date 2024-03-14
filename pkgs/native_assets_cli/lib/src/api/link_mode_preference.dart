// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'asset.dart';

part '../model/link_mode_preference.dart';

/// The preferred linkMode method for [NativeCodeAsset]s.
abstract final class LinkModePreference {
  /// The name for this link mode.
  String get name;

  /// Provide native assets as dynamic libraries.
  ///
  /// Fails if not all native assets can only be provided as static library.
  /// Required to run Dart in JIT mode.
  static const LinkModePreference dynamic = LinkModePreferenceImpl.dynamic;

  /// Provide native assets as static libraries.
  ///
  /// Fails if not all native assets can only be provided as dynamic library.
  /// Required for potential link-time tree-shaking of native code.
  /// Therefore, preferred to in Dart AOT mode.
  static const LinkModePreference static = LinkModePreferenceImpl.static;

  /// Provide native assets as dynamic libraries, if possible.
  ///
  /// Otherwise, build native assets as static libraries
  static const LinkModePreference preferDynamic =
      LinkModePreferenceImpl.preferDynamic;

  /// Provide native assets as static libraries, if possible.
  ///
  /// Otherwise, build native assets as dynamic libraries. Preferred for AOT
  /// compilation, if there are any native assets which can only be provided as
  /// dynamic libraries.
  static const LinkModePreference preferStatic =
      LinkModePreferenceImpl.preferStatic;
}
