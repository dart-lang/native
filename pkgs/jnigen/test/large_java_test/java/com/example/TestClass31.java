package com.example;
import java.util.*;

public interface TestClass31<T extends Number>  {
  <S> S[] myMethod(S[] p1, int p2);
  public enum NestedEnum { V1 }
}
