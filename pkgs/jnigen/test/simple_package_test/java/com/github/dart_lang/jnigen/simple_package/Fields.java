// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.simple_package;

import java.util.*;

public class Fields {
  // static fields - non-final primitive & string
  public static int amount = 500;
  public static double pi = 3.14159;
  public static char asterisk = '*';
  public static String name = "Earl Haraldson";

  // Static fields - object
  public Integer i = 100;

  // Instance fields - primitive and string
  public long trillion = 1024L * 1024L * 1024L * 1024L;
  public boolean isAchillesDead = false;
  public String bestFighterInGreece = "Achilles";

  // Instance fields - object
  public Random random = new Random();

  // Static and instance fields in nested class.
  public static class Nested {
    public long hundred = 100L;
    public static String BEST_GOD = "Pallas Athena";
  }

  public static char euroSymbol = '\u20ac';
}
