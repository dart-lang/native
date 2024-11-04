// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.annotations;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Annotated<T, U extends @NotNull Object, @NotNull W> {
  public T t;
  public U u;
  public W w;

  public Annotated(T t, U u, W w) {
    this.t = t;
    this.u = u;
    this.w = w;
  }

  public @NotNull String hello() {
    return "hello";
  }

  public String nullableHello(boolean returnNull) {
    return returnNull ? null : hello();
  }

  public @NotNull String echo(@NotNull String string) {
    return string;
  }

  public String nullableEcho(String string) {
    return string;
  }

  public @NotNull String @NotNull [] array() {
    return new String[] {"hello"};
  }

  public String @NotNull [] arrayOfNullable() {
    return new String[] {null};
  }

  public @NotNull String[] nullableArray(boolean returnNull) {
    return returnNull ? null : array();
  }

  public String[] nullableArrayOfNullable(boolean returnNull) {
    return returnNull ? null : arrayOfNullable();
  }

  public @NotNull List<@NotNull String> list() {
    return List.of("hello");
  }

  public @NotNull List<String> listOfNullable() {
    var list = new ArrayList<String>();
    list.add(null);
    return list;
  }

  public List<@NotNull String> nullableList(boolean returnNull) {
    return returnNull ? null : list();
  }

  public List<String> nullableListOfNullable(boolean returnNull) {
    return returnNull ? null : listOfNullable();
  }

  public @NotNull T classGenericEcho(@NotNull T value) {
    return value;
  }

  public T nullableClassGenericEcho(T value) {
    return value;
  }

  public <V> @NotNull V methodGenericEcho(@NotNull V value) {
    return value;
  }

  public <@NotNull V> V methodGenericEcho2(V value) {
    return value;
  }

  public <V extends @NotNull Object> V methodGenericEcho3(V value) {
    return value;
  }

  public <V> V nullableReturnMethodGenericEcho(@NotNull V value, boolean returnNull) {
    return returnNull ? null : value;
  }

  public <V> V nullableMethodGenericEcho(V value) {
    return value;
  }

  public <V> @NotNull V nullableArgMethodGenericEcho(V value) {
    if (value == null) {
      throw new NullPointerException();
    }
    return value;
  }

  public @NotNull List<@NotNull T> classGenericList() {
    return List.of(t);
  }

  public @NotNull List<T> classGenericListOfNullable() {
    var list = new ArrayList<T>();
    list.add(null);
    return list;
  }

  public List<@NotNull T> nullableClassGenericList(boolean returnNull) {
    return returnNull ? null : classGenericList();
  }

  public List<T> nullableClassGenericListOfNullable(boolean returnNull) {
    return returnNull ? null : classGenericListOfNullable();
  }

  public <V> @NotNull List<@NotNull V> methodGenericList(@NotNull V value) {
    return List.of(value);
  }

  public <V> @NotNull List<V> methodGenericListOfNullable() {
    var list = new ArrayList<V>();
    list.add(null);
    return list;
  }

  public <V> List<@NotNull V> nullableMethodGenericList(@NotNull V value, boolean returnNull) {
    return returnNull ? null : methodGenericList(value);
  }

  public <V> List<V> nullableMethodGenericListOfNullable(boolean returnNull) {
    return returnNull ? null : methodGenericListOfNullable();
  }

  public T firstOfClassGenericList(@NotNull List<@NotNull T> list) {
    if (list.isEmpty()) {
      return null;
    }
    return list.get(0);
  }

  public T firstOfClassGenericNullableList(List<@NotNull T> list) {
    if (list == null || list.isEmpty()) {
      return null;
    }
    return list.get(0);
  }

  public T firstOfClassGenericListOfNullable(@NotNull List<T> list) {
    if (list.isEmpty()) {
      return null;
    }
    return list.get(0);
  }

  public T firstOfClassGenericNullableListOfNullable(List<T> list) {
    if (list == null || list.isEmpty()) {
      return null;
    }
    return list.get(0);
  }

  public <V> V firstOfMethodGenericList(@NotNull List<@NotNull V> list) {
    if (list.isEmpty()) {
      return null;
    }
    return list.get(0);
  }

  public <V> V firstOfMethodGenericNullableList(List<@NotNull V> list) {
    if (list == null || list.isEmpty()) {
      return null;
    }
    return list.get(0);
  }

  public <V> V firstOfMethodGenericListOfNullable(@NotNull List<V> list) {
    if (list.isEmpty()) {
      return null;
    }
    return list.get(0);
  }

  public <V> V firstOfMethodGenericNullableListOfNullable(List<V> list) {
    if (list == null || list.isEmpty()) {
      return null;
    }
    return list.get(0);
  }

  public <V> T firstKeyOfComboMap(@NotNull Map<@NotNull T, @NotNull V> map) {
    return map.keySet().stream().findFirst().orElse(null);
  }

  public <V> V firstValueOfComboMap(@NotNull Map<@NotNull T, @NotNull V> map) {
    return map.values().stream().findFirst().orElse(null);
  }

  public <V> T firstKeyOfComboMapNullableKey(@NotNull Map<T, @NotNull V> map) {
    return map.keySet().stream().findFirst().orElse(null);
  }

  public <V> V firstValueOfComboMapNullableKey(@NotNull Map<T, @NotNull V> map) {
    return map.values().stream().findFirst().orElse(null);
  }

  public <V> T firstKeyOfComboMapNullableValue(@NotNull Map<@NotNull T, V> map) {
    return map.keySet().stream().findFirst().orElse(null);
  }

  public <V> V firstValueOfComboMapNullableValue(@NotNull Map<@NotNull T, V> map) {
    return map.values().stream().findFirst().orElse(null);
  }

  public <V> T firstKeyOfComboMapNullableKeyAndValue(@NotNull Map<T, V> map) {
    return map.keySet().stream().findFirst().orElse(null);
  }

  public <V> V firstValueOfComboMapNullableKeyAndValue(@NotNull Map<T, V> map) {
    return map.values().stream().findFirst().orElse(null);
  }

  public <V> Map.Entry<@NotNull T, @NotNull V> firstEntryOfComboMap(
      @NotNull Map<@NotNull T, @NotNull V> map) {
    return map.entrySet().stream().findFirst().orElse(null);
  }

  public W getW() {
    return w;
  }

  public @Nullable W nullableGetW(boolean returnNull) {
    return returnNull ? null : w;
  }

  public @NotNull List<@NotNull List<@NotNull List<T>>> list3dOfT() {
    List<T> list = new ArrayList<>();
    list.add(t);
    return List.of(List.of(list));
  }

  public @NotNull List<@NotNull List<@NotNull List<U>>> list3dOfU() {
    return List.of(List.of(List.of(u)));
  }

  public @NotNull List<@NotNull List<@NotNull List<W>>> list3dOfW() {
    return List.of(List.of(List.of(w)));
  }

  public @NotNull List<@NotNull List<@NotNull List<@Nullable U>>> list3dOfNullableU(
      boolean returnNull) {
    List<@Nullable U> list = new ArrayList<>();
    list.add(returnNull ? null : u);
    return List.of(List.of(list));
  }

  public @NotNull List<@NotNull List<@NotNull List<@Nullable W>>> list3dOfNullableW(
      boolean returnNull) {
    List<@Nullable W> list = new ArrayList<>();
    list.add(returnNull ? null : w);
    return List.of(List.of(list));
  }

  public class Nested<V> {
    public V v;
    public @NotNull U u;

    public Nested(V v) {
      this.v = v;
      this.u = Annotated.this.u;
    }
  }

  public Annotated<T, U, W>.Nested<@NotNull Integer> nested() {
    return new Nested<>(42);
  }

  public @NotNull List<? extends @NotNull Integer> intList() {
    return List.of(42);
  }
}
