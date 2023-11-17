package com.github.dart_lang.jnigen.apisummarizer.util;

public class ExceptionUtil {
  @FunctionalInterface
  public interface CheckedFunction<T, R> {
    R function(T value) throws Exception;
  }

  @FunctionalInterface
  public interface CheckedRunnable {
    void run() throws Exception;
  }

  /**
   * Wraps a function throwing a checked exception and throws all checked exceptions as runtime
   * exceptions.
   */
  public static <T, R> R wrapCheckedException(CheckedFunction<T, R> function, T value) {
    try {
      return function.function(value);
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  public static void wrapCheckedException(CheckedRunnable runnable) {
    try {
      runnable.run();
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }
}
