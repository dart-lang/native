package com.example;
import java.util.*;

public record TestClass111<T>(Map<String, String>[] field)  implements Runnable {
  public void run() {}
}
