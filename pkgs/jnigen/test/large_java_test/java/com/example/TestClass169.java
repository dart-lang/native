package com.example;
import java.util.*;

public interface TestClass169<T>  extends List<String> {
  default <S, V> ArrayList<String> getFoo() { return null; }
  public static interface Nested {}

}
