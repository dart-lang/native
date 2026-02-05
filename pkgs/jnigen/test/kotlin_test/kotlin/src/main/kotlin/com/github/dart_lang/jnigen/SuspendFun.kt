/* Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package com.github.dart_lang.jnigen

import kotlinx.coroutines.*
import kotlin.coroutines.Continuation

public class SuspendFun {
    suspend fun sayHelloWithoutDelay(): String {
        return "Hello!"
    }

    suspend fun failWithoutDelay(): String {
        throw Error()
    }

    suspend fun fail(): String {
        delay(100L)
        throw Error()
    }

    suspend fun sayHello(): String {
        delay(100L)
        return "Hello!"
    }

    suspend fun sayHello(name: String): String {
        delay(100L)
        return "Hello $name!"
    }

    suspend fun nullableHello(returnNull: Boolean): String? {
        delay(100L)
        if (returnNull) {
            return null
        }
        return "Hello!"
    }

    suspend fun nullableHelloWithoutDelay(returnNull: Boolean): String? {
        if (returnNull) {
            return null
        }
        return "Hello!"
    }

    var result: Int = 0
    suspend fun noReturn() {
        delay(100L)
        this.result = 123
    }
}

public interface SuspendInterface {
    suspend fun sayHello(): String
    suspend fun sayHello(name: String): String
    suspend fun nullableHello(returnNull: Boolean): String?
    suspend fun sayInt(): Integer
    suspend fun sayInt(value: Integer): Integer
    suspend fun nullableInt(returnNull: Boolean): Integer?
    suspend fun noReturn()
}

suspend fun consumeOnAnotherThread(itf: SuspendInterface): String {
    return withContext(Dispatchers.Default) {
        consumeOnSameThread(itf)
    }
}

suspend fun consumeOnSameThread(itf: SuspendInterface): String {
    return """
${itf.sayHello()}
${itf.sayHello("Alice")}
${itf.nullableHello(false)}
${itf.sayInt()}
${itf.sayInt(Integer(789))}
${itf.nullableInt(false)}
${itf.noReturn()}
""".trim();
}
