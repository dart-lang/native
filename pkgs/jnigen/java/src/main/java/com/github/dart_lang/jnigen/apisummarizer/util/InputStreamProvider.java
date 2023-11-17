package com.github.dart_lang.jnigen.apisummarizer.util;

import java.io.InputStream;

/**
 * Implementers of this interface provide an InputStream on-demand for writing, and provide a way to
 * close the same. <br>
 * The implementation doesn't need to be thread-safe, since this is only used in AsmSummarizer,
 * which reads the classes serially.
 */
public interface InputStreamProvider {
  /** Return the input stream, initializing it if needed. */
  InputStream getInputStream();

  /** close the underlying InputStream. */
  void close();
}
