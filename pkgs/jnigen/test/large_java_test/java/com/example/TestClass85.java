package com.example;
import java.util.*;

public record TestClass85<T>(ArrayList<String>[] field)  implements Runnable {
  public void run() {}
}
