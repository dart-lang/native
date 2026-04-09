package com.example;
import java.util.*;

public record TestClass64<T extends Number>(T[] field)  implements Runnable {
  public void run() {}
}
