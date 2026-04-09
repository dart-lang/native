package com.example;
import java.util.*;

public record TestClass6<T>(String field)  implements Runnable {
  public void run() {}
}
