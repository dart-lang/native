// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'link_mode.dart';

class LinkModePreference {
  final String name;
  final String description;
  final LinkMode preferredLinkMode;
  final List<LinkMode> potentialLinkMode;

  const LinkModePreference(
    this.name,
    this.description, {
    required this.preferredLinkMode,
    required this.potentialLinkMode,
  });

  factory LinkModePreference.fromString(String name) =>
      values.where((element) => element.name == name).first;

  static const dynamic = LinkModePreference(
    'dynamic',
    '''Provide native assets as dynamic libraries.
Fails if not all native assets can only be provided as static library.
Required to run Dart in JIT mode.''',
    preferredLinkMode: LinkMode.dynamic,
    potentialLinkMode: [LinkMode.dynamic],
  );

  static const static = LinkModePreference(
    'static',
    '''Provide native assets as static libraries.
Fails if not all native assets can only be provided as dynamic library.
Required for potential link-time tree-shaking of native code.
Therefore, preferred to in Dart AOT mode.''',
    preferredLinkMode: LinkMode.static,
    potentialLinkMode: [LinkMode.static],
  );

  static const preferDynamic = LinkModePreference(
    'prefer-dynamic',
    '''Provide native assets as dynamic libraries, if possible.
Otherwise, build native assets as static libraries.''',
    preferredLinkMode: LinkMode.dynamic,
    potentialLinkMode: LinkMode.values,
  );

  static const preferStatic = LinkModePreference(
    'prefer-static',
    '''Provide native assets as static libraries, if possible.
Otherwise, build native assets as dynamic libraries.
Preferred for AOT compilation, if there are any native assets which can only be
provided as dynamic libraries.''',
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
