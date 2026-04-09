package com.example;
import java.util.*;

public record TestClass104<T>(Set<String>[] field)  implements Runnable {
  public void run() {}
}
