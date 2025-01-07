// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: deprecated_member_use

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  await build(args, (buildInput, _) async {
    final someValue =
        buildInput.metadatum('package_with_metadata', 'some_key');
    assert(someValue != null);
    final someInt = buildInput.metadatum('package_with_metadata', 'some_int');
    assert(someInt != null);
    print({
      'some_int': someInt,
      'some_key': someValue,
    });
  });
}
