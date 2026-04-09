package com.example;
import java.util.*;

public record TestClass124<T extends Number>(double[] field)  implements Runnable {
  public void run() {}
}
