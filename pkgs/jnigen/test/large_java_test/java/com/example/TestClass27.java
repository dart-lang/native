package com.example;
import java.util.*;

public interface TestClass27<T extends Number>  extends List {
  default long[] setFoo(long[] p1, int p2) { return null; }
  public static record NestedRecord(int x) {}
}
