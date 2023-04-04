// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

Version? versionFromString(String containsVersion) {
  final match = _semverRegex.firstMatch(containsVersion);
  if (match == null) {
    return null;
  }
  return Version(int.parse(match.group(1)!), int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      pre: match.group(4), build: match.group(5));
}

final _semverRegex = RegExp(
    r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?');
