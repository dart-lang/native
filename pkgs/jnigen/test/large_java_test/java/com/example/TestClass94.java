package com.example;
import java.util.*;

public interface TestClass94<T, U>  {
  default <S> ArrayList<String> getFoo(ArrayList<String> p1) { return null; }
  public static record NestedRecord(int x) {}
}
