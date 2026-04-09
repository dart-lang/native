package com.example;
import java.util.*;

public enum TestClass25  implements Runnable {
  VALUE1(null, 0), VALUE2(null, 0);
  public void run() {}
  private <S, V> TestClass25(long[] p1, int p2) {}
  public static record NestedRecord(int x) {}

}
