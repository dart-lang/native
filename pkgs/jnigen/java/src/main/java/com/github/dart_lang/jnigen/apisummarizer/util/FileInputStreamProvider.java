package com.github.dart_lang.jnigen.apisummarizer.util;

import java.io.*;

/** Implementation of InputStreamProvider backed by a File. */
public class FileInputStreamProvider implements InputStreamProvider {
  File file;
  InputStream stream;

  public FileInputStreamProvider(File file) {
    this.file = file;
  }

  @Override
  public InputStream getInputStream() {
    if (stream == null) {
      try {
        stream = new FileInputStream(file);
      } catch (FileNotFoundException e) {
        throw new RuntimeException(e);
      }
    }
    return stream;
  }

  @Override
  public void close() {
    if (stream == null) {
      return;
    }
    try {
      stream.close();
      stream = null;
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }
}
