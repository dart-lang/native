package com.example;
import java.util.*;

public record TestClass16<T, U>(Set<String>[] field)  implements Runnable {
  public void run() {}
}
