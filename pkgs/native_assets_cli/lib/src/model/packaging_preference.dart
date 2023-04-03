// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'packaging.dart';

class PackagingPreference {
  final String name;
  final String description;
  final List<Packaging> preferredPackaging;
  final List<Packaging> potentialPackaging;

  const PackagingPreference(
    this.name,
    this.description, {
    required this.preferredPackaging,
    required this.potentialPackaging,
  });

  factory PackagingPreference.fromString(String name) =>
      values.where((element) => element.name == name).first;

  static const dynamic = PackagingPreference(
    'dynamic',
    '''Provide native assets as dynamic libraries.
Fails if not all native assets can only be provided as static library.
Required to run Dart in JIT mode.''',
    preferredPackaging: [Packaging.dynamic],
    potentialPackaging: [Packaging.dynamic],
  );
  static const static = PackagingPreference(
    'static',
    '''Provide native assets as static libraries.
Fails if not all native assets can only be provided as dynamic library.
Required for potential link-time tree-shaking of native code.
Therefore, preferred to in Dart AOT mode.''',
    preferredPackaging: [Packaging.static],
    potentialPackaging: [Packaging.static],
  );
  static const preferDynamic = PackagingPreference(
    'prefer-dynamic',
    '''Provide native assets as dynamic libraries, if possible.
Otherwise, build native assets as static libraries.''',
    preferredPackaging: [Packaging.dynamic],
    potentialPackaging: Packaging.values,
  );
  static const preferStatic = PackagingPreference(
    'prefer-static',
    '''Provide native assets as static libraries, if possible.
Otherwise, build native assets as dynamic libraries.
Preferred for AOT compilation, if there are any native assets which can only be
provided as dynamic libraries.''',
    preferredPackaging: [Packaging.static],
    potentialPackaging: Packaging.values,
  );
  static const all = PackagingPreference(
    'all',
    '''Provide native assets as both dynamic and static libraries if supported.
Mostly useful for testing the build scripts.''',
    preferredPackaging: Packaging.values,
    potentialPackaging: Packaging.values,
  );

  static const values = [
    dynamic,
    static,
    preferDynamic,
    preferStatic,
    all,
  ];

  /// The `package:config` key preferably used.
  static const String configKey = 'packaging';

  @override
  String toString() => name;
}
