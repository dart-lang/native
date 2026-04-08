// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:yaml/yaml.dart';

Map<String, Object?> loadJson(String relativePath) {
  final packageRoot = findPackageRoot('pub_formats');
  final pubspecFile = File.fromUri(packageRoot.resolve(relativePath));
  final json = jsonDecode(pubspecFile.readAsStringSync());
  return json as Map<String, Object?>;
}

Map<String, Object?> loadYamlAsJson(String relativePath) {
  final packageRoot = findPackageRoot('pub_formats');
  final pubspecFile = File.fromUri(packageRoot.resolve(relativePath));
  final json = convertYamlMapToJsonMap(
    loadYaml(pubspecFile.readAsStringSync()) as YamlMap,
  );
  return json;
}

/// A list of valid SemVer versions that parsing should accept.
final List<String> validSemVers = [
  // Varied version numbers.
  for (final major in ['0', '19', '9999990'])
    for (final minor in ['0', '19', '9999990'])
      for (final patch in ['0', '19', '9999990']) ...[
        '$major.$minor.$patch',
        '$major.$minor.$patch-preRel',
        '$major.$minor.$patch+build',
        '$major.$minor.$patch-preRel+build',
      ],
  // Varied pre-release identifiers.
  for (final preRel in _dotSeparated(3, _validPreReleaseParts)) ...[
    '1.1.1-$preRel',
    '1.1.1-$preRel+build',
  ],
  // Varied build identifiers.
  for (final build in _dotSeparated(3, _validBuildParts)) ...[
    '1.1.1-$build',
    '1.1.1-preRel+$build',
  ],
];

// Some dot-separated parts of a pre-release identifier, which can be:
// - numeric identifiers (decimal numerals without leading zeros except `0`).
// - alphanumeric identifiers (sequences of `a`-`z`, `A`-`Z`, `0`-`9` and `-`)
//   with at least one non-digit.
// (So any combination of `a`-`z`, `A`-`Z`, `0`-`9`, and `-` other than
// `0` followed by only digits.)
const _validPreReleaseParts = [
  '0', '9', // Digits.
  'a', 'Z', // Letters.
  '-', // Dash.
  '1234567890', 'abz', 'ABZ', '---', // Repeats of same kind.
  // Combinations
  '059aZ', '059Za', '059-', // Digit and other.
  'aqZ09', 'ZQa--', // Letter and other.
  '--09', '00Az', // Dash and other.
  '0a-Z9', 'A-0-z', '-0Z9-', // All three.
];

// Some dot-separated parts of a build identifier.
///
// Any combination of `a`-`z`, `A`-`Z`, `0`-`9`, and `-`,
// including numerals with leading zeros.
const _validBuildParts = [
  ..._validPreReleaseParts,
  // Also allows a leading zero, `0<digits>`.
  '007',
];

/// Creates dot-separated sequences of up to [length] [validParts].
List<String> _dotSeparated(int length, List<String> validParts) {
  if (length <= 1) return validParts;
  final validContinuations = _dotSeparated(length - 1, validParts);
  return [
    for (final part in validParts) ...[
      part,
      for (final continuation in validContinuations) '$part.$continuation',
    ],
  ];
}
