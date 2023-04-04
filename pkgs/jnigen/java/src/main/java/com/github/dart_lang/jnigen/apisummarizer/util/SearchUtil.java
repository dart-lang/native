package com.github.dart_lang.jnigen.apisummarizer.util;

import java.io.File;
import java.io.FileFilter;
import java.util.*;
import java.util.function.BiFunction;
import java.util.function.Function;
import java.util.jar.JarFile;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import javax.tools.JavaFileObject;
import javax.tools.StandardJavaFileManager;

public class SearchUtil {
  public static Optional<List<File>> findFilesInPath(
      String qualifiedName, String searchPath, String suffix) {
    var s = qualifiedName.replace(".", File.separator);
    var f = new File(searchPath, s + suffix);
    if (f.exists() && f.isFile()) {
      return Optional.of(List.of(f));
    }

    var d = new File(searchPath, s);
    if (d.exists() && d.isDirectory()) {
      return Optional.of(recursiveListFiles(d, file -> file.getName().endsWith(".java")));
    }

    return Optional.empty();
  }

  public static Optional<List<ZipEntry>> findFilesInJar(
      String qualifiedName, JarFile jar, String suffix) {
    String relativePath = qualifiedName.replace(".", "/");
    var classEntry = jar.getEntry(relativePath + suffix);
    if (classEntry != null) {
      return Optional.of(List.of(classEntry));
    }
    var dirPath = relativePath.endsWith("/") ? relativePath : relativePath + "/";
    var dirEntry = jar.getEntry(dirPath);
    if (dirEntry != null && dirEntry.isDirectory()) {
      var result =
          jar.stream()
              .map(je -> (ZipEntry) je)
              .filter(
                  entry -> {
                    var name = entry.getName();
                    return name.endsWith(suffix) && name.startsWith(dirPath);
                  })
              .collect(Collectors.toList());
      return Optional.of(result);
    }
    return Optional.empty();
  }

  public static <T> Optional<List<T>> find(
      String qualifiedName,
      List<String> searchPaths,
      String suffix,
      Function<List<File>, List<T>> fileMapper,
      BiFunction<JarFile, List<ZipEntry>, List<T>> entryMapper) {
    for (var searchPath : searchPaths) {
      File searchFile = new File(searchPath);
      if (searchFile.isDirectory()) {
        var result = findFilesInPath(qualifiedName, searchPath, suffix);
        if (result.isPresent()) {
          var mappedResult = fileMapper.apply(result.get());
          return Optional.of(mappedResult);
        }
      }
      if (searchFile.isFile() && searchPath.endsWith(".jar")) {
        var jarFile = ExceptionUtil.wrapCheckedException(JarFile::new, searchPath);
        var result = findFilesInJar(qualifiedName, jarFile, suffix);
        if (result.isPresent()) {
          var mappedResult = entryMapper.apply(jarFile, result.get());
          return Optional.of(mappedResult);
        }
      }
    }
    return Optional.empty();
  }

  private static List<JavaFileObject> getJavaFileObjectsFromFiles(
      List<File> files, StandardJavaFileManager fm) {
    var result = new ArrayList<JavaFileObject>();
    fm.getJavaFileObjectsFromFiles(files).forEach(result::add);
    return result;
  }

  private static List<JavaFileObject> getJavaFileObjectsFromJar(
      JarFile jarFile, List<ZipEntry> entries) {
    return StreamUtil.map(entries, (entry) -> new JarEntryFileObject(jarFile, entry));
  }

  private static List<InputStreamProvider> getInputStreamProvidersFromFiles(List<File> files) {
    return StreamUtil.map(files, FileInputStreamProvider::new);
  }

  private static List<InputStreamProvider> getInputStreamProvidersFromJar(
      JarFile jarFile, List<ZipEntry> entries) {
    return StreamUtil.map(entries, entry -> new JarEntryInputStreamProvider(jarFile, entry));
  }

  public static Optional<List<JavaFileObject>> findJavaSources(
      String qualifiedName, List<String> searchPaths, StandardJavaFileManager fm) {
    return find(
        qualifiedName,
        searchPaths,
        ".java",
        files -> getJavaFileObjectsFromFiles(files, fm),
        SearchUtil::getJavaFileObjectsFromJar);
  }

  public static Optional<List<InputStreamProvider>> findJavaClasses(
      String qualifiedName, List<String> searchPaths) {
    return find(
        qualifiedName,
        searchPaths,
        ".class",
        SearchUtil::getInputStreamProvidersFromFiles,
        SearchUtil::getInputStreamProvidersFromJar);
  }

  /**
   * Lists all files under given directory, which satisfy the condition of filter. <br>
   * The order of listing will be deterministic.
   */
  public static List<File> recursiveListFiles(File file, FileFilter filter) {
    if (!file.exists()) {
      throw new RuntimeException("File not found: " + file.getPath());
    }

    if (!file.isDirectory()) {
      return List.of(file);
    }

    // List files using a breadth-first traversal.
    var files = new ArrayList<File>();
    var queue = new ArrayDeque<File>();
    queue.add(file);
    while (!queue.isEmpty()) {
      var dir = queue.poll();
      var list = dir.listFiles(entry -> entry.isDirectory() || filter.accept(entry));
      if (list == null) throw new IllegalArgumentException("File.listFiles returned null!");
      Arrays.sort(list);
      for (var path : list) {
        if (path.isDirectory()) {
          queue.add(path);
        } else {
          files.add(path);
        }
      }
    }
    return files;
  }
}
