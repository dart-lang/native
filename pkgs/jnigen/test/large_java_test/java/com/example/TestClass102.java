package com.example;
import java.util.*;

public interface TestClass102<T, U>  extends List {
  default Object myMethod() { return null; }
  public static interface Nested {}
}
