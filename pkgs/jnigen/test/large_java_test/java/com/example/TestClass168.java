package com.example;
import java.util.*;

public interface TestClass168<T>  {
  default <S, V> Set<String>[] isFoo() { return null; }
  public static record NestedRecord(int x) {}

}
