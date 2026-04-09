package com.example;
import java.util.*;

public interface TestClass100<T>  {
  default <S> S[] setFoo(S[] p1, int p2) { return null; }
  public enum NestedEnum { V1 }
}
