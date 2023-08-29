// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.interfaces;

public class MyRunnableRunner {
  final MyRunnable runnable;

  public Throwable error;

  public MyRunnableRunner(MyRunnable runnable) {
    this.runnable = runnable;
  }

  public void runOnSameThread() {
    try {
      runnable.run();
    } catch (Throwable e) {
      error = e;
    }
  }

  public void runOnAnotherThread() {
    var thread = new Thread(this::runOnSameThread);
    thread.start();
  }
}
