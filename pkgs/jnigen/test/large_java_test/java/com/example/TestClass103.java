package com.example;
import java.util.*;

public interface TestClass103<T extends Number>  extends Runnable {
  double[] getFoo(double[] p1, int p2);
  public static record NestedRecord(int x) {}
}
