// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../api/link_mode_preference.dart' as api;
import 'link_mode.dart';

class LinkModePreference implements api.LinkModePreference {
  @override
  final String name;

  @override
  final LinkMode preferredLinkMode;

  @override
  final List<LinkMode> potentialLinkMode;

  const LinkModePreference(
    this.name, {
    required this.preferredLinkMode,
    required this.potentialLinkMode,
  });

  factory LinkModePreference.fromString(String name) =>
      values.where((element) => element.name == name).first;

  static const dynamic = LinkModePreference(
    'dynamic',
    preferredLinkMode: LinkMode.dynamic,
    potentialLinkMode: [LinkMode.dynamic],
  );

  static const static = LinkModePreference(
    'static',
    preferredLinkMode: LinkMode.static,
    potentialLinkMode: [LinkMode.static],
  );

  static const preferDynamic = LinkModePreference(
    'prefer-dynamic',
    preferredLinkMode: LinkMode.dynamic,
    potentialLinkMode: LinkMode.values,
  );

  static const preferStatic = LinkModePreference(
    'prefer-static',
    preferredLinkMode: LinkMode.static,
    potentialLinkMode: LinkMode.values,
  );

  static const values = [
    dynamic,
    static,
    preferDynamic,
    preferStatic,
  ];

  /// The `package:config` key preferably used.
  static const String configKey = 'link_mode_preference';

  @override
  String toString() => name;
}
