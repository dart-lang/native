// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  await build(args, (input, _) async {
    final someValue = input.metadata['package_with_metadata']['some_key'];
    assert(someValue != null);
    final someInt = input.metadata['package_with_metadata']['some_int'];
    assert(someInt != null);
    print({'some_int': someInt, 'some_key': someValue});

    // ignore: deprecated_member_use
    final someValueOld = input.metadatum('package_with_metadata', 'some_key');
    assert(someValueOld != null);
    // ignore: deprecated_member_use
    final someIntOld = input.metadatum('package_with_metadata', 'some_int');
    assert(someIntOld != null);
  });
}
