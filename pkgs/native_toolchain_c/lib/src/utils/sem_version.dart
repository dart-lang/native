// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

/// Reads a version out of a string.
///
/// If no semantic version is found, tries to read find a version number
/// that doesn't follow semantic versioning. It will default [Version.minor]
/// and [Version.patch] to `0` if the relaxed version doesn't contain them.
Version? versionFromString(String containsVersion) {
  final match = _semverRegex.firstMatch(containsVersion);
  if (match != null) {
    return Version(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      pre: match.group(4),
      build: match.group(5),
    );
  }

  final relaxedMatch = _semverRegexReleaxed.firstMatch(containsVersion);
  if (relaxedMatch != null) {
    return Version(
      int.parse(relaxedMatch.group(1)!),
      int.parse(relaxedMatch.group(2) ?? '0'),
      int.parse(relaxedMatch.group(3) ?? '0'),
      pre: relaxedMatch.group(4),
      build: relaxedMatch.group(5),
    );
  }

  return null;
}

final _semverRegex = RegExp(
  r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?',
);

final _semverRegexReleaxed = RegExp(
  r'(0|[1-9]\d*)(?:\.(0|[1-9]\d*))?(?:\.(0|[1-9]\d*))?(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?',
);
