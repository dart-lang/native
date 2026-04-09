package com.example;
import java.util.*;

public interface TestClass53<T>  extends Runnable, Cloneable {
  <S extends Number> byte[] setFoo(byte[] p1, int p2);
  public static record NestedRecord(int x) {}
}
