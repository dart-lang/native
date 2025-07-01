package com;

public class Accumelator {
    public int accumulator;

    public Accumelator() {
        this.accumulator = 0;
    }

    public Accumelator(int initialValue) {
        this.accumulator = initialValue;
    }

    public Accumelator(Accumelator other) {
        this.accumulator = other.accumulator;
    }

    public void add(int value) {
        this.accumulator += value;
    }

    public void add(int value1, int value2) {
        this.accumulator += value1 + value2;
    }

    public void add(int value1, int value2, int value3) {
        this.accumulator += value1 + value2 + value3;
    }

    public void add(Accumelator other) {
        this.accumulator += other.accumulator;
    }
}
