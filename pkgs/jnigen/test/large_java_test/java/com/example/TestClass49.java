package com.example;
import java.util.*;

public interface TestClass49<T extends Number>  extends Runnable {
  default Object[] myMethod() { return null; }
  public static interface Nested {}
}
