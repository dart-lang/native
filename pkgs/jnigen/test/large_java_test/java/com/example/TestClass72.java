package com.example;
import java.util.*;

public interface TestClass72<T extends Number>  extends Runnable {
  <S> T[] isFoo(T[] p1);
  public enum NestedEnum { V1 }

}
