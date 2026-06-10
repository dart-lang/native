// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'code_asset.dart';

import 'config.dart';
import 'syntax.g.dart';

/// The preferred link mode for [CodeAsset]s in [CodeConfig.linkModePreference].
final class LinkModePreference {
  /// The name for this link mode.
  final String name;

  const LinkModePreference._(this.name);

  /// Creates a [LinkModePreference] from a string.
  ///
  /// The [name] must be one of [LinkModePreference.values].
  factory LinkModePreference.fromString(String name) => values.firstWhere(
    (e) => e.name == name,
    orElse: () => LinkModePreference._(name),
  );

  /// Provide native assets as dynamic libraries.
  ///
  /// Fails if not all native assets can only be provided as static library.
  /// Required to run Dart in JIT mode.
  static const dynamic = LinkModePreference._('dynamic');

  /// Provide native assets as static libraries.
  ///
  /// Fails if not all native assets can only be provided as dynamic library.
  /// Required for potential link-time tree-shaking of native code.
  /// Therefore, preferred to in Dart AOT mode.
  static const static = LinkModePreference._('static');

  /// Provide native assets as dynamic libraries, if possible.
  ///
  /// Otherwise, build native assets as static libraries
  static const preferDynamic = LinkModePreference._('prefer_dynamic');

  /// Provide native assets as static libraries, if possible.
  ///
  /// Otherwise, build native assets as dynamic libraries. Preferred for AOT
  /// compilation, if there are any native assets which can only be provided as
  /// dynamic libraries.
  static const preferStatic = LinkModePreference._('prefer_static');

  /// All possible values for [LinkModePreference].
  static const values = [dynamic, static, preferDynamic, preferStatic];

  @override
  bool operator ==(Object other) =>
      other is LinkModePreference && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}

/// Extension methods for [LinkModePreference] to convert to and from the
/// syntax model.
extension LinkModePreferenceSyntaxExtension on LinkModePreference {
  /// Converts this [LinkModePreference] to its corresponding
  /// [LinkModePreferenceSyntax].
  LinkModePreferenceSyntax toSyntax() =>
      LinkModePreferenceSyntax.fromJson(name);

  /// Converts a [LinkModePreferenceSyntax] to its corresponding
  /// [LinkModePreference].
  static LinkModePreference fromSyntax(LinkModePreferenceSyntax syntax) =>
      LinkModePreference.fromString(syntax.name);
}
