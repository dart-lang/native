/* Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package com.github.dart_lang.jnigen

// Kotlin classes with default parameters should not expose the
// DefaultConstructorMarker in generated Dart bindings.

class DefaultParams(
    val x: Int = 42,
    val y: String = "hello"
) {
    fun greet(): String = "x=$x, y=$y"
}

class MixedParams(
    val required: String,
    val optional: Int = 100
) {
    fun describe(): String = "required=$required, optional=$optional"
}

class AllDefaults(
    val a: Int = 1,
    val b: String = "two",
    val c: Boolean = true
) {
    fun summary(): String = "a=$a, b=$b, c=$c"
}
