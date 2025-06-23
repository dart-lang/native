package com.github.dart_lang.jnigen

class Operators(var value: Int) {
    operator fun plus(op: Operators): Operators {
        return Operators(value + op.value)
    }

    operator fun plus(int: Int): Operators {
        return Operators(value + int)
    }

    operator fun minus(op: Operators): Operators {
        return Operators(value - op.value)
    }

    operator fun times(op: Operators): Operators {
        return Operators(value * op.value)
    }

    operator fun div(op: Operators): Operators {
        return Operators(value / op.value)
    }

    operator fun rem(op: Operators): Operators {
        return Operators(value % op.value)
    }

    operator fun get(index: Int): Boolean {
        return ((value shr index) and 1)  == 1
    }

    operator fun set(index: Int, bit: Boolean) {
        if (get(index) == bit) {
            return
        }
        value = (value xor (1 shl index))
    }

    fun compareTo(op: Operators): Int {
        return value.compareTo(op.value)
    }
}
