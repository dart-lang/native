// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'third_party/stb_image.g.dart';

/// Reads the information from an image file without decoding the full image.
({int x, int y, int comp}) getInfo(String fileName) => using((arena) {
  final fileName_ = fileName.toNativeUtf8(allocator: arena);
  final x = arena<Int>();
  final y = arena<Int>();
  final comp = arena<Int>();
  final result = stbi_info(fileName_.cast(), x, y, comp);
  if (result != 1) {
    throw Exception(
      'Failed to read the info from "$fileName". Error code: $result.',
    );
  }
  return (x: x.value, y: y.value, comp: comp.value);
});
