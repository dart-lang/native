package com.example;

public interface DagD extends DagA, DagB, DagC {
  int D_FIELD = 6;
  default void dMethod() {}
}
