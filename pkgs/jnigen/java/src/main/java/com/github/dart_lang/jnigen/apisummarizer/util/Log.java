// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.util;

public class Log {
  private static long lastPrinted = System.currentTimeMillis();

  public static void setVerbose(boolean verbose) {
    Log.verboseLogs = verbose;
  }

  private static boolean verboseLogs = false;

  public static void verbose(String format, Object... args) {
    if (!verboseLogs) {
      return;
    }
    System.err.printf(format + "\n", args);
  }

  public static void timed(String format, Object... args) {
    long now = System.currentTimeMillis();
    System.err.printf("[%6d ms] ", now - lastPrinted);
    lastPrinted = now;
    System.err.printf(format + "\n", args);
  }

  public static void always(String format, Object... args) {
    System.err.printf(format + "\n", args);
  }
}
