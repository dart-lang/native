package com.example;
import java.util.*;

public interface TestClass36<T extends Number>  extends List<String> {
  default <S extends Number> Runnable isFoo() { return null; }
  public static record NestedRecord(int x) {}
}
