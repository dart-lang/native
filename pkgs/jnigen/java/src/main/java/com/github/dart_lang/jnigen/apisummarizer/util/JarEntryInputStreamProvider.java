package com.github.dart_lang.jnigen.apisummarizer.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.jar.JarFile;
import java.util.zip.ZipEntry;

public class JarEntryInputStreamProvider implements InputStreamProvider {

  private final JarFile jarFile;
  private final ZipEntry zipEntry;

  public JarEntryInputStreamProvider(JarFile jarFile, ZipEntry zipEntry) {
    this.jarFile = jarFile;
    this.zipEntry = zipEntry;
  }

  @Override
  public InputStream getInputStream() {
    try {
      return jarFile.getInputStream(zipEntry);
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  @Override
  public void close() {}
}
