// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni;

import java.lang.ref.PhantomReference;
import java.lang.ref.ReferenceQueue;

/// A registry of Java objects with associated Dart resources that cleans up the
/// resources after they get unreachable and collected by the garbage collector.
///
/// A simple alternative to [java.lang.ref.Cleaner] which is only available in
/// Android API level 33+.
class PortCleaner {
  static {
    System.loadLibrary("dartjni");
  }

  private final ReferenceQueue<Object> queue = new ReferenceQueue<>();
  private final PortPhantom list = new PortPhantom();

  private class PortPhantom extends PhantomReference<Object> {
    final long port;

    /// Form a linked list.
    PortPhantom prev = this, next = this;

    PortPhantom(Object referent, long port) {
      super(referent, queue);
      this.port = port;
      insert();
    }

    /// Only used for the head of the list.
    PortPhantom() {
      super(null, null);
      this.port = 0;
    }

    void insert() {
      synchronized (list) {
        prev = list;
        next = list.next;
        next.prev = this;
        list.next = this;
      }
    }

    private void remove() {
      synchronized (list) {
        next.prev = prev;
        prev.next = next;
        prev = this;
        next = this;
      }
    }
  }

  PortCleaner() {
    // Only a single PortCleaner and therefore thread will be created.
    Thread thread =
        new Thread(
            () -> {
              while (true) {
                try {
                  PortPhantom portPhantom = (PortPhantom) queue.remove();
                  portPhantom.remove();
                  if (portPhantom.port != 0) {
                    clean(portPhantom.port);
                  }
                } catch (Throwable e) {
                  // Ignore.
                }
              }
            },
            "PortCleaner");
    thread.setDaemon(true);
    thread.start();
  }

  /// Registers [obj] to be cleaned up later by sending a signal through [port].
  void register(Object obj, long port) {
    new PortPhantom(obj, port);
  }

  private static native void clean(long port);
}
