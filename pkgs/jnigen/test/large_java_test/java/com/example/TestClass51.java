package com.example;
import java.util.*;

public interface TestClass51<T>  extends Runnable {
  default short getFoo() { return 0; }
  public static class Nested {}
}
