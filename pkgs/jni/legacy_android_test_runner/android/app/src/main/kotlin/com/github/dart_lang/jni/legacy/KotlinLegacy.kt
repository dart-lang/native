// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni.legacy

import kotlinx.coroutines.delay

interface SuspendProvider {
  suspend fun fetch(key: String): String
}

class KotlinLegacy {
  suspend fun greet(name: String): String {
    delay(10)
    return "Hello, $name!"
  }

  suspend fun doNothing() {
    delay(10)
  }

  suspend fun failSuspend(message: String): String {
    delay(10)
    throw IllegalStateException(message)
  }

  suspend fun callProvider(provider: SuspendProvider, key: String): String {
    return provider.fetch(key)
  }
}
