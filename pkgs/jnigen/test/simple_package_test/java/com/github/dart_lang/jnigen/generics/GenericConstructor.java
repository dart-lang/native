package com.github.dart_lang.jnigen.generics;

public class GenericConstructor<T extends Number> {
  public Object field;
  public <S> GenericConstructor(S[] p1) {
    field = p1;
  }
  public T identity(T value) {
    return value;
  }
}
