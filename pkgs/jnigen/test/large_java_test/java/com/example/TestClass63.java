package com.example;
import java.util.*;

public interface TestClass63<T>  extends Runnable, Cloneable {
  <S extends Number> float[] myMethod(float[] p1, int p2);
  public static record NestedRecord(int x) {}

}
