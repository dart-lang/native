package com;

public class Example {

    public enum Operation {
        ADD,
        SUBTRACT,
    }

    public static int has$dollar$sign = 1;
    public static int _startsWithUnderscore = 2;

    public String greet(String name) {
        return "Hello " + name;
    }

    public String enumValueToString(Operation operation) {
        switch (operation) {
            case ADD:
                return "Addition";
            case SUBTRACT:
                return "Subtraction";
            default:
                return "Unknown operation";
        }
    }
}
