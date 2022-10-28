package com.github.dart_lang.jnigen.apisummarizer.util;

public class ExceptionUtil {
  @FunctionalInterface
  public interface FunctionThrowingException<T, R> {
    R function(T value) throws Exception;
  }

  /**
   * Wraps a function throwing a checked exception and throws all checked exceptions as runtime
   * exceptions.
   */
  public static <T, R> R wrapCheckedException(FunctionThrowingException<T, R> function, T value) {
    try {
      return function.function(value);
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }
}
