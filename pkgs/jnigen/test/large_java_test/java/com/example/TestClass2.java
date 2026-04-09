package com.example;
import java.util.*;

public record TestClass2<T>(List<String> field)  implements Runnable {
  public void run() {}
}
