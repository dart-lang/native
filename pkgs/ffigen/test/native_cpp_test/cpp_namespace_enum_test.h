// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

namespace outer {
// Unscoped enum in a single namespace.
enum Color { red, green, blue };

namespace inner {
// Scoped enum (`enum class`) in a nested namespace. Shares the leaf name
// `Color` with `outer::Color` and `other::Color`.
enum class Color { cyan = 10, magenta = 20 };
}  // namespace inner
}  // namespace outer

namespace other {
// Another `Color`, in a different namespace, to exercise leaf-name collisions.
enum Color { black = 100, white = 200 };
}  // namespace other
