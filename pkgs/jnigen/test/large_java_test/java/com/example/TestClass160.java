package com.example;
import java.util.*;

public interface TestClass160<T, U>  extends Runnable {
  default <S extends Number> String[] setFoo(String[] p1, int p2) { return null; }
  public enum NestedEnum { V1 }

}
