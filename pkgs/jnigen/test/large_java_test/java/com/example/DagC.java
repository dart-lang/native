package com.example;

public interface DagC extends DagA, DagB {
  int C_FIELD = 5;
  default void cMethod() {}
}
