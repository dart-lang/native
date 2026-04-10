package com.example;

public interface DagE extends DagB, DagD {
  int E_FIELD = 7;
  default void eMethod() {}
}
