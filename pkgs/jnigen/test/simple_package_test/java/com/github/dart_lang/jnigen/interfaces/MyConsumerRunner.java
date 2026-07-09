// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.interfaces;

import java.lang.ref.WeakReference;

public class MyConsumerRunner {
  private final MyConsumer consumer;
  private WeakReference<Object> weakArg;
  private boolean finished = false;
  private Thread thread;

  public MyConsumerRunner(MyConsumer consumer) {
    this.consumer = consumer;
  }

  private static class ConsumerRunnable implements Runnable {
    private final MyConsumerRunner runner;
    private final MyConsumer consumer;
    private Object localArg;

    public ConsumerRunnable(MyConsumerRunner runner, MyConsumer consumer, Object arg) {
      this.runner = runner;
      this.consumer = consumer;
      this.localArg = arg;
    }

    @Override
    public void run() {
      try {
        consumer.consume(localArg);
      } finally {
        localArg = null;
        synchronized (runner) {
          runner.finished = true;
          runner.notifyAll();
        }
      }
    }
  }

  public void runOnAnotherThread(Object arg) {
    this.weakArg = new WeakReference<>(arg);
    this.thread = new Thread(new ConsumerRunnable(this, consumer, arg));
    this.thread.start();
  }

  public void runOnAnotherThreadAndJoin(Object arg) throws InterruptedException {
    runOnAnotherThread(arg);
    joinThread();
  }

  public void joinThread() throws InterruptedException {
    if (thread != null) {
      thread.join(2000);
    }
  }

  public synchronized boolean isFinished() {
    return finished;
  }

  public synchronized boolean waitForFinished(long timeoutMs) throws InterruptedException {
    long deadline = System.currentTimeMillis() + timeoutMs;
    while (!finished) {
      long remaining = deadline - System.currentTimeMillis();
      if (remaining <= 0) break;
      wait(remaining);
    }
    return finished;
  }

  public boolean isArgCollected() {
    return weakArg != null && weakArg.get() == null;
  }
}
