package com.github.dart_lang.jnigen.apisummarizer.util;

import java.io.File;
import java.io.FileFilter;
import java.util.*;
import java.util.function.BiFunction;
import java.util.function.Function;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import javax.tools.JavaFileObject;
import javax.tools.StandardJavaFileManager;

public class ClassFinder {
  public static <E> void findFilesInPath(
      String searchPath,
      String suffix,
      Map<String, List<E>> classes,
      Function<List<File>, List<E>> mapper) {

    for (var binaryName : classes.keySet()) {
      if (classes.get(binaryName) != null) {
        continue;
      }
      var s = binaryName.replace(".", File.separator);
      var f = new File(searchPath, s + suffix);
      if (f.exists() && f.isFile()) {
        classes.put(binaryName, mapper.apply(List.of(f)));
      }

      var d = new File(searchPath, s);
      if (d.exists() && d.isDirectory()) {
        var files = recursiveListFiles(d, file -> file.getName().endsWith(suffix));
        classes.put(binaryName, mapper.apply(files));
      }
    }
  }

  public static <E> void findFilesInJar(
      Map<String, List<E>> classes,
      JarFile jar,
      String suffix,
      BiFunction<JarFile, List<ZipEntry>, List<E>> mapper) {
    var entries =
        jar.stream().map(JarEntry::getName).collect(Collectors.toCollection(TreeSet::new));
    for (var binaryName : classes.keySet()) {
      if (classes.get(binaryName) != null) {
        continue;
      }
      var relativePath = binaryName.replace('.', '/');

      var filePath = relativePath + suffix;
      if (entries.contains(filePath)) {
        var found = List.of(jar.getEntry(filePath));
        classes.put(binaryName, mapper.apply(jar, found));
      }

      // Obtain set of all strings prefixed with relativePath + '/'
      var dirPath = relativePath + '/';
      var children =
          entries.tailSet(dirPath).stream()
              .takeWhile(e -> e.startsWith(dirPath))
              .filter(e -> e.endsWith(suffix))
              .map(jar::getEntry)
              .collect(Collectors.toList());
      if (!children.isEmpty()) {
        var mapped = mapper.apply(jar, children);
        classes.put(binaryName, mapped);
      }
    }
  }

  public static <T> void find(
      Map<String, List<T>> classes,
      List<String> searchPaths,
      String suffix,
      Function<List<File>, List<T>> fileMapper,
      BiFunction<JarFile, List<ZipEntry>, List<T>> entryMapper) {
    for (var searchPath : searchPaths) {
      File searchFile = new File(searchPath);
      if (searchFile.isDirectory()) {
        findFilesInPath(searchPath, suffix, classes, fileMapper);
      } else if (searchFile.isFile() && searchPath.endsWith(".jar")) {
        var jarFile = ExceptionUtil.wrapCheckedException(JarFile::new, searchPath);
        findFilesInJar(classes, jarFile, suffix, entryMapper);
      }
    }
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

  public static void findJavaSources(
      Map<String, List<JavaFileObject>> classes,
      List<String> searchPaths,
      StandardJavaFileManager fm) {
    find(
        classes,
        searchPaths,
        ".java",
        files -> getJavaFileObjectsFromFiles(files, fm),
        ClassFinder::getJavaFileObjectsFromJar);
  }

  public static void findJavaClasses(
      Map<String, List<InputStreamProvider>> classes, List<String> searchPaths) {
    find(
        classes,
        searchPaths,
        ".class",
        ClassFinder::getInputStreamProvidersFromFiles,
        ClassFinder::getInputStreamProvidersFromJar);
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
