/* Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package com.github.dart_lang.jnigen

import kotlinx.coroutines.delay
import kotlin.coroutines.Continuation

public class SuspendFun {
    suspend fun sayHello(): String {
        delay(100L)
        return "Hello!"
    }

    suspend fun sayHello(name: String): String {
        delay(100L)
        return "Hello $name!"
    }
}