package com.github.dart_lang.jnigen

class Nullability<T, U: Any>(val t: T, val u: U, var nullableU: U?) {
    fun hello(): String {
        return "hello"
    }

    fun nullableHello(returnNull: Boolean): String? {
        return if (returnNull) null else "hello"
    }

    fun <V: Any> methodGenericEcho(v: V): V {
        return v
    }

    fun <V : Any?> methodGenericNullableEcho(v: V): V {
        return v
    }

    fun classGenericEcho(u: U): U {
        return u
    }

    fun classGenericNullableEcho(t: T): T {
        return t
    }

    fun firstOf(list: List<String>): String {
        return list.first();
    }

    fun firstOfNullable(list: List<String?>): String? {
        return list.first();
    }

    fun classGenericFirstOf(list: List<U>): U {
        return list.first();
    }

    fun classGenericFirstOfNullable(list: List<T>): T {
        return list.first();
    }

    fun <V: Any> methodGenericFirstOf(list: List<V>): V {
        return list.first();
    }

    fun <V> methodGenericFirstOfNullable(list: List<V>): V {
        return list.first();
    }

    fun stringListOf(element: String): List<String> {
        return listOf(element)
    }

    fun nullableListOf(element: String?): List<String?> {
        return listOf(element)
    }

    fun classGenericListOf(element: U): List<U> {
        return listOf(element)
    }

    fun classGenericNullableListOf(element: T): List<T> {
        return listOf(element)
    }

    fun <V: Any> methodGenericListOf(element: V): List<V> {
        return listOf(element)
    }

    fun <V> methodGenericNullableListOf(element: V): List<V> {
        return listOf(element)
    }

    inner class InnerClass<V> {
        fun f(t: T, u: U, v: V) {}
    }
}
