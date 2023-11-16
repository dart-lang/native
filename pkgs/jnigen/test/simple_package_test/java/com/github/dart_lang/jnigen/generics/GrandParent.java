// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.generics;

public class GrandParent<T> {
  public T value;

  public GrandParent(T value) {
    this.value = value;
  }

  public Parent<String> stringParent() {
    return new Parent<>("Hello");
  }

  public <S> Parent<S> varParent(S nestedValue) {
    return new Parent<>(nestedValue);
  }

  public static StaticParent<String> stringStaticParent() {
    return new StaticParent<>("Hello");
  }

  public static <S> StaticParent<S> varStaticParent(S value) {
    return new StaticParent<>(value);
  }

  public StaticParent<T> staticParentWithSameType() {
    return new StaticParent<>(value);
  }

  // This doesn't have access to T
  public static class StaticParent<S> {
    public S value;

    public StaticParent(S value) {
      this.value = value;
    }

    public class Child<U> {
      public S parentValue;
      public U value;

      public Child(S parentValue, U value) {
        this.parentValue = parentValue;
        this.value = value;
      }
    }
  }

  public class Parent<S> {
    public T parentValue;
    public S value;

    public Parent(S newValue) {
      parentValue = GrandParent.this.value;
      value = newValue;
    }

    public class Child<U> {
      public T grandParentValue;
      public S parentValue;
      public U value;

      public Child(U newValue) {
        this.grandParentValue = GrandParent.this.value;
        this.parentValue = Parent.this.value;
        this.value = newValue;
      }
    }
  }
}
