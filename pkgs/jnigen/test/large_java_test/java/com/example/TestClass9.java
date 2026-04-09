package com.example;
import java.util.*;

public interface TestClass9<T extends Number>  extends List<String> {
  default short isFoo(short p1, int p2) { return 0; }
}
