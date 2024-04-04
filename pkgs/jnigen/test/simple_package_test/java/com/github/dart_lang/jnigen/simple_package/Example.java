// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.simple_package;

import java.util.*;

public class Example {
  static {
    // This turns into a <clinit> method in the bytecode. Making sure jnigen
    // does not generate it.
  }

  // static fields - primitive & string
  public static final int ON = 1;
  public static final int OFF = 0;
  public static final double PI = 3.14159;
  public static final char SEMICOLON = ';';
  public static final String SEMICOLON_STRING = ";";

  public static final Random unusedRandom = new Random();

  private static int amount = 500;
  private static double pi = 3.14159;
  private static char asterisk = '*';
  private static String name = "Ragnar Lothbrok";

  // Static fields - object
  private static Nested nested = new Nested(true);

  // static methods
  public static int getAmount() {
    return amount;
  }

  public static double getPi() {
    return pi;
  }

  public static char getAsterisk() {
    return asterisk;
  }

  public static String getName() {
    return name;
  }

  public static Nested getNestedInstance() {
    return nested;
  }

  // void functions with 1 parameter
  public static void setAmount(int newAmount) {
    amount = newAmount;
  }

  public static void setName(String newName) {
    name = newName;
  }

  public static void setNestedInstance(Nested newNested) {
    nested = newNested;
  }

  // void functions with many parameters
  public static int max4(int a, int b, int c, int d) {
    return Integer.max(Integer.max(a, b), Integer.max(c, d));
  }

  public static int max8(int a, int b, int c, int d, int e, int f, int g, int h) {
    return Integer.max(max4(a, b, c, d), max4(e, f, g, h));
  }

  // Instance fields - primitive and string
  private int number = 0;
  private boolean isUp = false;
  private String codename = "achilles";

  // Instance fields - object
  private Random random = new Random();

  // Instance methods
  public int getNumber() {
    return number;
  }

  public void setNumber(int number) {
    this.number = number;
  }

  public boolean getIsUp() {
    return isUp;
  }

  public void setUp(boolean isUp) {
    this.isUp = isUp;
  }

  public String getCodename() {
    return codename;
  }

  public void setCodename(String codename) {
    this.codename = codename;
  }

  public Random getRandom() {
    return random;
  }

  public void setRandom(Random random) {
    this.random = random;
  }

  public long getRandomLong() {
    return random.nextLong();
  }

  public long add4Longs(long a, long b, long c, long d) {
    return a + b + c + d;
  }

  public long add8Longs(long a, long b, long c, long d, long e, long f, long g, long h) {
    return a + b + c + d + e + f + g + h;
  }

  public String getRandomNumericString(Random random) {
    return String.format(
        "%d%d%d%d", random.nextInt(10), random.nextInt(10), random.nextInt(10), random.nextInt(10));
  }

  private void privateMethod(String a, String b) {}

  protected void protectedMethod(String a, String b) {}

  protected Random protectedField;

  public final void finalMethod() {}

  public List<String> getList() {
    return null;
  }

  /** Joins the strings in the list using the given delimiter. */
  public String joinStrings(List<String> values, String delim) {
    return null;
  }

  public <T extends CharSequence> void methodWithSeveralParams(
      char ch, String s, int[] a, T t, List<T> lt, Map<String, ? extends CharSequence> wm) {}

  public Example() {
    this(0);
  }

  public Example(int number) {
    this(number, true);
  }

  public Example(int number, boolean isUp) {
    this(number, isUp, "achilles");
  }

  public Example(int number, boolean isUp, String codename) {
    this.number = number;
    this.isUp = isUp;
    this.codename = codename;
  }

  public Example(int a, int b, int c, int d, int e, int f, int g, int h) {
    this(a + b + c + d + e + f + g + h);
  }

  public int whichExample() {
    return 0;
  }

  public static int addInts(int a, int b) {
    return a + b;
  }

  public static int[] getArr() {
    return new int[] {1, 2, 3};
  }

  public static int addAll(int[] arr) {
    return Arrays.stream(arr).sum();
  }

  public Example getSelf() {
    return this;
  }

  public static void throwException() {
    throw new RuntimeException("Hello");
  }

  public void overloaded() {}

  public void overloaded(int a, String b) {}

  public void overloaded(int a) {}

  public void overloaded(List<Integer> a, String b) {}

  public void overloaded(List<Integer> a) {}

  public class NonStaticNested {
    public boolean ok;
  }

  public static class Nested {
    private boolean value;

    public Nested(boolean value) {
      this.value = value;
    }

    public void usesAnonymousInnerClass() {
      new Thread(
              new Runnable() {
                @Override
                public void run() {
                  System.out.println("2982157093127690243");
                }
              })
          .start();
    }

    public boolean getValue() {
      return value;
    }

    public void setValue(boolean value) {
      this.value = value;
    }

    public static class NestedTwice {
      public static int ZERO = 0;
    }
  }
}
