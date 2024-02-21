// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/link_mode_preference.dart';

final class LinkModePreferenceImpl implements LinkModePreference {
  @override
  final String name;

  @override
  final LinkModeImpl preferredLinkMode;

  @override
  final List<LinkModeImpl> potentialLinkMode;

  const LinkModePreferenceImpl(
    this.name, {
    required this.preferredLinkMode,
    required this.potentialLinkMode,
  });

  factory LinkModePreferenceImpl.fromString(String name) =>
      values.where((element) => element.name == name).first;

  static const dynamic = LinkModePreferenceImpl(
    'dynamic',
    preferredLinkMode: LinkModeImpl.dynamic,
    potentialLinkMode: [LinkModeImpl.dynamic],
  );

  static const static = LinkModePreferenceImpl(
    'static',
    preferredLinkMode: LinkModeImpl.static,
    potentialLinkMode: [LinkModeImpl.static],
  );

  static const preferDynamic = LinkModePreferenceImpl(
    'prefer-dynamic',
    preferredLinkMode: LinkModeImpl.dynamic,
    potentialLinkMode: LinkModeImpl.values,
  );

  static const preferStatic = LinkModePreferenceImpl(
    'prefer-static',
    preferredLinkMode: LinkModeImpl.static,
    potentialLinkMode: LinkModeImpl.values,
  );

  static const values = [
    dynamic,
    static,
    preferDynamic,
    preferStatic,
  ];

  static const String configKey = 'link_mode_preference';

  @override
  String toString() => name;
}
