package com.example;
import java.util.*;

public interface TestClass123<T, U>  extends Runnable, Cloneable {
  long[] setFoo();
  public static record NestedRecord(int x) {}
}
