package com.example;
import java.util.*;

public interface TestClass113<T, U>  {
  default Map.Entry<String, String> getFoo(Map.Entry<String, String> p1, int p2) { return null; }
  public static record NestedRecord(int x) {}
}
