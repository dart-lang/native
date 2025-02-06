/* Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package com.github.dart_lang.jnigen

public class Nullability<T, U: Any>(val t: T, val u: U, var nullableU: U?) {
    public fun hello(): String {
        return "hello"
    }

    public fun nullableHello(returnNull: Boolean): String? {
        return if (returnNull) null else "hello"
    }

    public fun list(): List<*> {
        return listOf("hello", 42)
    }

    public fun <V: Any> methodGenericEcho(v: V): V {
        return v
    }

    public fun <V : Any?> methodGenericNullableEcho(v: V): V {
        return v
    }

    public fun classGenericEcho(u: U): U {
        return u
    }

    public fun classGenericNullableEcho(t: T): T {
        return t
    }

    public fun firstOf(list: List<String>): String {
        return list.first();
    }

    public fun firstOfNullable(list: List<String?>): String? {
        return list.first();
    }

    public fun classGenericFirstOf(list: List<U>): U {
        return list.first();
    }

    public fun classGenericFirstOfNullable(list: List<T>): T {
        return list.first();
    }

    public fun <V: Any> methodGenericFirstOf(list: List<V>): V {
        return list.first();
    }

    public fun <V> methodGenericFirstOfNullable(list: List<V>): V {
        return list.first();
    }

    public fun stringListOf(element: String): List<String> {
        return listOf(element)
    }

    public fun nullableListOf(element: String?): List<String?> {
        return listOf(element)
    }

    public fun classGenericListOf(element: U): List<U> {
        return listOf(element)
    }

    public fun classGenericNullableListOf(element: T): List<T> {
        return listOf(element)
    }

    public fun <V: Any> methodGenericListOf(element: V): List<V> {
        return listOf(element)
    }

    public fun <V> methodGenericNullableListOf(element: V): List<V> {
        return listOf(element)
    }

    public inner class InnerClass<V> {
        public fun f(t: T, u: U, v: V) {}
    }
}
