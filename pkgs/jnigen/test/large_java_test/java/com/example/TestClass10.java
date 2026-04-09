package com.example;
import java.util.*;

public interface TestClass10<T>  {
  default <S> Object[] isFoo(Object[] p1, int p2) { return null; }
  public static interface Nested {}

}
