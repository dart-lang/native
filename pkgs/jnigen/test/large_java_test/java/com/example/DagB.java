package com.example;

public interface DagB extends DagA {
  int B_FIELD = 4;
  default void bMethod() {}
}
