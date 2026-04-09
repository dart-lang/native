package com.example;
import java.util.*;

public record TestClass4<T>(Map<String, String>[] field)  implements Runnable {
  public void run() {}
}
