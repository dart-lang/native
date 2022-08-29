package com.github.dart_lang.jni_gen.simple_package;

public class Example {
  public static final int ON = 1;
  public static final int OFF = 0;

  public static Aux aux;
  public static int num;

  static {
    aux = new Aux(true);
    num = 121;
  }

  public static Aux getAux() {
    return aux;
  }

  public static int addInts(int a, int b) {
    return a + b;
  }

  public Example getSelf() {
    return this;
  }

  public int getNum() {
    return num;
  }

  public void setNum(int num) {
    this.num = num;
  }

  public static class Aux {
    public boolean value;

    public Aux(boolean value) {
      this.value = value;
    }

    public boolean getValue() {
      return value;
    }

    public void setValue(boolean value) {
      this.value = value;
    }
  }
}
