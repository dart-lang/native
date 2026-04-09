package com.example;
import java.util.*;

public final class TestClass3<T extends Number>  {
  public native <S, V> byte setFoo(byte p1, int p2);
  public static record NestedRecord(int x) {}
}
