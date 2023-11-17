// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.util;

import java.util.logging.Level;
import java.util.logging.Logger;

public class Log {
  private static final Logger logger = Logger.getLogger("ApiSummarizer");

  private static void log(Level level, String format, Object... args) {
    String formatted = String.format(format, args);
    logger.log(level, formatted);
  }

  public static void info(String format, Object... args) {
    log(Level.INFO, format, args);
  }

  public static void warning(String format, Object... args) {
    log(Level.WARNING, format, args);
  }
}
