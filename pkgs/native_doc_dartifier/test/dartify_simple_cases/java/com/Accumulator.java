package com;

public class Accumulator {
    public int accumulator;

    public Accumulator() {
        this.accumulator = 0;
    }

    public Accumulator(int initialValue) {
        this.accumulator = initialValue;
    }

    public Accumulator(Accumulator other) {
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

    public void add(Accumulator other) {
        this.accumulator += other.accumulator;
    }
}
