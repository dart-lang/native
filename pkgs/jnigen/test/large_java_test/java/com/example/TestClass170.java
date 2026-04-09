package com.example;
import java.util.*;

public interface TestClass170<T>  extends List<String> {
  default <S extends Number> double[] myMethod(double[] p1, int p2) { return null; }
}
