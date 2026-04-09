package com.example;
import java.util.*;

public interface TestClass177  extends List<String> {
  default <S, V> byte setFoo() { return 0; }
  public enum NestedEnum { V1 }
}
