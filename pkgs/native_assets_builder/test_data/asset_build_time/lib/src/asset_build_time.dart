// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffi/ffi.dart';

import 'asset_build_time_bindings_generated.dart' as bindings;

DateTime get buildTime =>
    DateTime.parse(bindings.buildTime.cast<Utf8>().toDartString());
