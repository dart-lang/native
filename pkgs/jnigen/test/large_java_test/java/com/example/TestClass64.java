package com.example;
import java.util.*;

public record TestClass64<T extends Number>(String field)  implements Runnable {
  public void run() {}
}
