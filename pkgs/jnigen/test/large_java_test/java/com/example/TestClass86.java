package com.example;
import java.util.*;

public interface TestClass86<T>  {
  <S extends Number> S isFoo(S p1);
  public static record NestedRecord(int x) {}

}
