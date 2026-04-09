package com.example;
import java.util.*;

public abstract interface TestClass20<T, U>  extends List<String> {
  T[] isFoo();
  public static record NestedRecord(int x) {}

}
