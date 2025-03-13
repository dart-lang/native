// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.util;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.Opcodes;

public class JavaCoreClassFinder {
  private static List<String> findInnerClasses(InputStream inputStream) throws IOException {
    List<String> innerClasses = new ArrayList<>();
    ClassReader classReader = new ClassReader(inputStream);

    classReader.accept(
        new ClassVisitor(Opcodes.ASM9) {
          @Override
          public void visitInnerClass(String name, String outerName, String innerName, int access) {
            innerClasses.add(name.replace('/', '.'));
            super.visitInnerClass(name, outerName, innerName, access);
          }
        },
        0);

    return innerClasses;
  }

  private static InputStream find(String className) {
    String classPath = "/" + className.replace('.', '/') + ".class";
    URI uri = URI.create("jrt:/");
    Map<String, String> env = new HashMap<>();
    try (var fs = FileSystems.newFileSystem(uri, env)) {
      Path path = fs.getPath("modules/java.base", classPath);
      if (Files.notExists(path)) {
        return null;
      }
      return Files.newInputStream(path);
    } catch (IOException e) {
      return null;
    }
  }

  /// Finds the class and all its inner classes.
  public static Map<String, InputStream> findAll(String className) throws IOException {
    var classes = new HashMap<String, InputStream>();
    var classInputStream = find(className);
    if (classInputStream == null) {
      return null;
    }
    var bytes = classInputStream.readAllBytes();
    classInputStream.close();
    classes.put(className, new ByteArrayInputStream(bytes));
    try {
      var innerClasses = findInnerClasses(new ByteArrayInputStream(bytes));
      for (var innerClass : innerClasses) {
        var innerClassInputStream = find(innerClass);
        if (innerClassInputStream != null) {
          classes.put(innerClass, innerClassInputStream);
        }
      }
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
    return classes;
  }
}
