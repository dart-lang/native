// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.util;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.FileSystem;
import java.nio.file.FileSystemAlreadyExistsException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.stream.Stream;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.Opcodes;

public class CoreClassFinder {

  private static List<String> findInnerClasses(InputStream inputStream, String fqcn)
      throws IOException {
    List<String> innerClasses = new ArrayList<>();
    ClassReader classReader = new ClassReader(inputStream);
    String internalName = fqcn.replace('.', '/');

    classReader.accept(
        new ClassVisitor(Opcodes.ASM9) {
          @Override
          public void visitInnerClass(String name, String outerName, String innerName, int access) {
            if (outerName != null && outerName.equals(internalName)) {
              innerClasses.add(name.replace('/', '.'));
            }
            super.visitInnerClass(name, outerName, innerName, access);
          }
        },
        0);
    return innerClasses;
  }

  private static InputStream findJavaCoreClass(String className) {
    String classResourcePath = "/" + className.replace('.', '/') + ".class";
    URI uri = URI.create("jrt:/");
    Map<String, String> env = Collections.emptyMap();
    FileSystem fs = null;
    boolean fsCreatedByUs = false;
    try {
      try {
        fs = FileSystems.newFileSystem(uri, env);
        fsCreatedByUs = true;
      } catch (FileSystemAlreadyExistsException e) {
        fs = FileSystems.getFileSystem(uri);
      }

      Path path = fs.getPath("modules/java.base" + classResourcePath);
      if (Files.notExists(path)) {
        return null;
      }
      return Files.newInputStream(path);
    } catch (IOException e) {
      return null;
    } finally {
      if (fsCreatedByUs && fs != null) {
        try {
          fs.close();
        } catch (IOException ignored) {
        }
      }
    }
  }

  private static InputStream findKotlinStdlibClass(String className) {
    String classResourcePath = className.replace('.', '/') + ".class";
    ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
    if (classLoader == null) {
      classLoader = CoreClassFinder.class.getClassLoader();
    }
    if (classLoader == null) {
      classLoader = ClassLoader.getSystemClassLoader();
    }
    if (classLoader == null) {
      return null;
    }
    return classLoader.getResourceAsStream(classResourcePath);
  }

  private static void collectClassAndInnerClasses(String fqcn, Map<String, InputStream> targetMap)
      throws IOException {
    if (targetMap.containsKey(fqcn)) { // Avoid reprocessing if already added.
      return;
    }

    InputStream classInputStream = findJavaCoreClass(fqcn);
    if (classInputStream == null) {
      classInputStream = findKotlinStdlibClass(fqcn);
    }

    if (classInputStream != null) {
      byte[] mainClassBytes;
      try {
        mainClassBytes = classInputStream.readAllBytes();
      } finally {
        try {
          classInputStream.close();
        } catch (IOException ignored) {
        }
      }
      targetMap.put(fqcn, new ByteArrayInputStream(mainClassBytes));

      try {
        List<String> innerClassNames =
            findInnerClasses(new ByteArrayInputStream(mainClassBytes), fqcn);
        for (String innerClassName : innerClassNames) {
          if (targetMap.containsKey(innerClassName)) continue;

          InputStream innerFinderStream = findJavaCoreClass(innerClassName);
          if (innerFinderStream == null) {
            innerFinderStream = findKotlinStdlibClass(innerClassName);
          }

          if (innerFinderStream != null) {
            byte[] innerClassBytes;
            try {
              innerClassBytes = innerFinderStream.readAllBytes();
            } finally {
              try {
                innerFinderStream.close();
              } catch (IOException ignored) {
              }
            }
            targetMap.put(innerClassName, new ByteArrayInputStream(innerClassBytes));
          }
        }
      } catch (IOException ignored) {
      }
    }
  }

  public static Map<String, InputStream> findAll(String name) throws IOException {
    Map<String, InputStream> results = new HashMap<>();
    boolean nameIsLikelyFQCN = false;

    // Test if 'name' can be resolved as a class directly
    InputStream testStream = findJavaCoreClass(name);
    if (testStream != null) {
      nameIsLikelyFQCN = true;
      try {
        testStream.close();
      } catch (IOException ignored) {
      }
    } else {
      testStream = findKotlinStdlibClass(name);
      if (testStream != null) {
        nameIsLikelyFQCN = true;
        try {
          testStream.close();
        } catch (IOException ignored) {
        }
      }
    }

    if (nameIsLikelyFQCN) {
      // 'name' resolves to a class, so collect it and its inner classes.
      collectClassAndInnerClasses(name, results);
    } else {
      // 'name' does not resolve to a class directly, treat it as a package name.
      List<String> topLevelClassNamesInPackage = new ArrayList<>();
      topLevelClassNamesInPackage.addAll(findTopLevelClassesInPackageJRT(name));
      topLevelClassNamesInPackage.addAll(findTopLevelClassesInPackageClasspath(name));

      if (topLevelClassNamesInPackage.isEmpty()) {
        // No specific class found for 'name', and no top-level classes found if 'name' is a
        // package.
        return null;
      }

      for (String topLevelClassName : topLevelClassNamesInPackage) {
        collectClassAndInnerClasses(topLevelClassName, results);
      }
    }

    return results.isEmpty() ? null : results;
  }

  private static List<String> findTopLevelClassesInPackageJRT(String packageName) {
    List<String> classNames = new ArrayList<>();
    String packageAsPath = "/" + packageName.replace('.', '/');
    URI uri = URI.create("jrt:/");
    Map<String, String> env = Collections.emptyMap();
    FileSystem fs = null;
    boolean fsCreatedByUs = false;

    try {
      try {
        fs = FileSystems.newFileSystem(uri, env);
        fsCreatedByUs = true;
      } catch (FileSystemAlreadyExistsException e) {
        fs = FileSystems.getFileSystem(uri);
      }

      Path dirPath = fs.getPath("modules/java.base" + packageAsPath);
      if (Files.isDirectory(dirPath)) {
        try (Stream<Path> stream = Files.list(dirPath)) {
          stream
              .filter(
                  path ->
                      path.getFileName().toString().endsWith(".class")
                          && !path.getFileName().toString().contains("$"))
              .forEach(
                  path -> {
                    String fileName = path.getFileName().toString();
                    String className =
                        packageName
                            + "."
                            + fileName.substring(0, fileName.length() - ".class".length());
                    classNames.add(className);
                  });
        }
      }
    } catch (IOException ignored) {
    } finally {
      if (fsCreatedByUs && fs != null) {
        try {
          fs.close();
        } catch (IOException ignored) {
        }
      }
    }
    return classNames;
  }

  private static List<String> findTopLevelClassesInPackageClasspath(String packageName) {
    List<String> classNames = new ArrayList<>();
    String packagePath = packageName.replace('.', '/');
    ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
    if (classLoader == null) classLoader = CoreClassFinder.class.getClassLoader();
    if (classLoader == null) classLoader = ClassLoader.getSystemClassLoader();
    if (classLoader == null) return classNames;

    try {
      Enumeration<URL> resources = classLoader.getResources(packagePath);
      while (resources.hasMoreElements()) {
        URL resourceUrl = resources.nextElement();
        if ("file".equals(resourceUrl.getProtocol())) {
          try {
            File directory = Paths.get(resourceUrl.toURI()).toFile();
            if (directory.isDirectory()) {
              File[] files =
                  directory.listFiles(
                      (dir, name) -> name.endsWith(".class") && !name.contains("$"));
              if (files != null) {
                for (File file : files) {
                  String simpleClassName =
                      file.getName().substring(0, file.getName().length() - ".class".length());
                  classNames.add(packageName + "." + simpleClassName);
                }
              }
            }
          } catch (URISyntaxException | SecurityException ignored) {
          }
        } else if ("jar".equals(resourceUrl.getProtocol())) {
          String jarUrlPath = resourceUrl.getPath();
          String jarFilePath = jarUrlPath.substring("file:".length(), jarUrlPath.indexOf("!"));
          try (JarFile jarFile = new JarFile(jarFilePath)) {
            Enumeration<JarEntry> entries = jarFile.entries();
            while (entries.hasMoreElements()) {
              JarEntry entry = entries.nextElement();
              String entryName = entry.getName();
              if (entryName.startsWith(packagePath + "/")
                  && entryName.endsWith(".class")
                  && !entryName.contains("$")) {
                String namePart =
                    entryName.substring(packagePath.isEmpty() ? 0 : packagePath.length() + 1);
                if (!namePart.contains("/")) { // Ensure it's directly in the package
                  String simpleClassName =
                      namePart.substring(0, namePart.length() - ".class".length());
                  classNames.add(packageName + "." + simpleClassName);
                }
              }
            }
          } catch (IOException ignored) {
          }
        }
      }
    } catch (IOException ignored) {
    }
    return classNames;
  }
}
