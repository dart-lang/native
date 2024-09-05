/* Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package com.github.dart_lang.jnigen

// Regression test for https://github.com/dart-lang/native/issues/1263.

interface MeasureUnit {
    val sign: String
    val coefficient: Float
}

enum class SpeedUnit(override val sign: String, override val coefficient: Float) : MeasureUnit {
    KmPerHour("km/h", 1000 / 3600f),
    MetrePerSec("m/s", 1f),
}

abstract class Measure<T : MeasureUnit>(open val value: Float, open val unit: T) {
    fun convertValue(unit: T): Float = value * this.unit.coefficient / unit.coefficient
}

data class Speed(override val value: Float, override val unit: SpeedUnit): Measure<SpeedUnit>(value, unit) {
    override fun toString(): String = super.toString()
}
