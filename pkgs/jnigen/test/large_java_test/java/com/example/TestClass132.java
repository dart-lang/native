package com.example;
import java.util.*;

public interface TestClass132<T extends Number>  extends Runnable, Cloneable {
  <S extends Number> short setFoo(short p1);
  public static class Nested {}
}
