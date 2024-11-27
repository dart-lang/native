package com.github.dart_lang.jnigen

class Nullabilty<T: Any?, U>(val t: T, val u: U, val nullableU: U?) {
    fun hello(): String {
        return "hello"
    }

    fun nullableHello(returnNull: Boolean): String? {
        return if (returnNull) null else "hello"
    }

    fun <V>methodGenericEcho(v: V): V {
        return v
    }

    fun <V: Any?>methodGenericNullableEcho(v: V): V {
        return v
    }

    fun classGenericEcho(u: U): U {
        return u
    }

    fun classGenericNullableEcho(t: T): T {
        return t
    }

    inner class InnerClass<V> {
        fun f(t: T, u: U, v: V) {}
    }
}