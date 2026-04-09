package com.example;
import java.util.*;

public interface TestClass32<T>  extends List {
  <S extends Number> Set<String> setFoo(Set<String> p1);
}
