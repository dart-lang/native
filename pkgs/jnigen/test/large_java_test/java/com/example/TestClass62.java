package com.example;
import java.util.*;

public abstract interface TestClass62<T, U>  extends Runnable {
  <S extends Number> Object myMethod(Object p1, int p2);
  public enum NestedEnum { V1 }
}
