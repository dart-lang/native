// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Certain methods are not allowed to be overriden in swift.
// TODO(https://github.com/dart-lang/native/issues/2954): Support hash()
const disallowedMethods = {'hashValue', 'hash'};
