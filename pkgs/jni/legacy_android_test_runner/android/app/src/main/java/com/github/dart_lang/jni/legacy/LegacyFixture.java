// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni.legacy;

import android.content.Context;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class LegacyFixture {
  public static final int CONSTANT_INT = 42;
  public static final String CONSTANT_STRING = "legacy";
  public static int staticCounter = 0;

  public int intValue;
  public String textValue;
  private String label = "initial";

  public LegacyFixture() {
    this.intValue = 0;
    this.textValue = "default";
  }

  public LegacyFixture(int intValue, String textValue) {
    this.intValue = intValue;
    this.textValue = textValue;
  }

  public LegacyFixture(boolean shouldThrow) throws LegacyException {
    if (shouldThrow) {
      throw new LegacyException("constructor failed");
    }
    this.intValue = 1;
    this.textValue = "ok";
  }

  public static class Nested {
    public final String tag;

    public Nested(String tag) {
      this.tag = tag;
    }

    public String describe() {
      return "Nested:" + tag;
    }
  }

  public static String getPackageName(Context context) {
    return context.getPackageName();
  }

  public static Object asObject(LegacyFixture fixture) {
    return fixture;
  }

  public static boolean negate(boolean value) {
    return !value;
  }

  public static int add(int a, int b) {
    return a + b;
  }

  public static double multiply(double a, double b) {
    return a * b;
  }

  public static char nextChar(char c) {
    return (char) (c + 1);
  }

  public static String nullableEcho(String input) {
    return input == null ? null : "echo:" + input;
  }

  public void reset() {
    this.intValue = 0;
    this.textValue = "";
  }

  public String getLabel() {
    return label;
  }

  public void setLabel(String label) {
    this.label = label;
  }

  public static <T> T identity(T value) {
    return value;
  }

  public static int sumIntArray(int[] values) {
    int sum = 0;
    for (int v : values) {
      sum += v;
    }
    return sum;
  }

  public static int countFixtures(LegacyFixture[] fixtures) {
    return fixtures.length;
  }

  public static List<String> makeList(String a, String b) {
    List<String> list = new ArrayList<>();
    list.add(a);
    list.add(b);
    return list;
  }

  public static Map<String, Integer> makeMap(String key, int value) {
    Map<String, Integer> map = new HashMap<>();
    map.put(key, value);
    return map;
  }

  public static Set<String> makeSet(String a, String b) {
    Set<String> set = new HashSet<>();
    set.add(a);
    set.add(b);
    return set;
  }

  public static int sumByteBuffer(ByteBuffer buffer) {
    int sum = 0;
    for (int i = buffer.position(); i < buffer.limit(); i++) {
      sum += buffer.get(i) & 0xFF;
    }
    return sum;
  }

  public static void throwCustom(String message) throws LegacyException {
    throw new LegacyException(message);
  }

  public static int invokeTransformer(IntTransformer transformer, int value) {
    return transformer.transform(value);
  }

  public static void invokeListenerOnBackgroundThread(StringListener listener, String message)
      throws InterruptedException {
    Thread thread = new Thread(() -> listener.onEvent(message));
    thread.start();
    thread.join();
  }

  public static int invokeMultiInterface(Object proxy, int value, String message) {
    ((StringListener) proxy).onEvent(message);
    return ((IntTransformer) proxy).transform(value);
  }

  public static String invokeAndCatch(ThrowingCallback callback) {
    try {
      return callback.call();
    } catch (Exception e) {
      return "caught:" + e.getMessage();
    }
  }
}
