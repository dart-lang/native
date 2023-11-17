// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.generics;

import java.util.HashMap;
import java.util.Map;

public class MyMap<K, V> {
  public class MyEntry {
    public K key;
    public V value;

    public MyEntry(K key, V value) {
      this.key = key;
      this.value = value;
    }
  }

  private Map<K, V> map;

  public MyMap() {
    map = new HashMap<>();
  }

  public V get(K key) {
    return map.get(key);
  }

  public V put(K key, V value) {
    return map.put(key, value);
  }

  public MyStack<MyEntry> entryStack() {
    var stack = new MyStack<MyEntry>();
    map.entrySet().stream()
        .map(e -> new MyEntry(e.getKey(), e.getValue()))
        .forEach(e -> stack.push(e));
    return stack;
  }
}
