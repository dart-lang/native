package com.github.dart_lang.jnigen.apisummarizer.util;

import static com.github.dart_lang.jnigen.apisummarizer.util.ExceptionUtil.wrapCheckedException;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
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
  // If class is A$B$C, simpleName can be B$C or A$B$C. Doesn't matter much, because
  // A can't be anonymous class.
  private static boolean isNonAnonymousNestedClassName(String simpleName) {
    String[] nestedParts = simpleName.split("\\$");
    return Arrays.stream(nestedParts).allMatch(part -> part.matches("[a-zA-Z_][a-zA-Z0-9_]*"));
  }

  public static boolean isNestedClassOf(String pathString, String fqnWithSlashes, String suffix) {
    var fqnWithSlashesDollarSign = fqnWithSlashes + "$";
    if (!pathString.startsWith(fqnWithSlashesDollarSign) || !pathString.endsWith(suffix)) {
      return false;
    }
    String nested =
        pathString.substring(
            fqnWithSlashesDollarSign.length(), pathString.length() - suffix.length());
    return isNonAnonymousNestedClassName(nested);
  }

  private static boolean isNonAnonymousClassFullPath(String path) {
    String[] pathParts = path.split("[/\\\\]");
    String simpleNameWithExt = pathParts[pathParts.length - 1];
    int extIndex = simpleNameWithExt.indexOf('.');
    assert extIndex != -1 : "Should've passed full path with extension to this method";
    String simpleName = simpleNameWithExt.substring(0, extIndex);
    return isNonAnonymousNestedClassName(simpleName);
  }

  // Finds [fqn] and its children with [suffix] in [entries].
  public static Optional<List<String>> findClassAndChildren(
      TreeSet<String> entries, String fqn, String sep, String suffix) {
    String fqnWithSlashes = fqn.replace(".", sep);
    String fqnWithSlashesSuffix = fqnWithSlashes + suffix;
    String fqnWithSlashesSlash = fqnWithSlashes + sep;
    String fqnWithSlashesDollarSign = fqnWithSlashes + "$";
    if (entries.contains(fqnWithSlashesSuffix)) {
      List<String> classes = new ArrayList<>();
      // Add nested classes first, because they're alphabetically first
      entries.tailSet(fqnWithSlashesDollarSign).stream()
          .takeWhile(entry -> entry.startsWith(fqnWithSlashesDollarSign))
          // Note: filter comes after takeWhile, because it can filter out additional elements
          // eg: Class$1 - but there may be valid nested classes after Class$1.
          .filter(entry -> isNestedClassOf(entry, fqnWithSlashes, suffix))
          .forEach(classes::add);
      classes.add(fqnWithSlashesSuffix);
      return Optional.of(classes);
    }
    // consider fqnWithSlashes as a directory
    List<String> children =
        entries.tailSet(fqnWithSlashesSlash).stream()
            // takeWhile instead of filter - the difference is O(log n + k) instead of O(n)
            // so always use takeWhile when doing a treeSet subset stream.
            .takeWhile(entry -> entry.startsWith(fqnWithSlashesSlash))
            .filter(entry -> entry.endsWith(suffix))
            .filter(ClassFinder::isNonAnonymousClassFullPath)
            .collect(Collectors.toList());
    return children.isEmpty() ? Optional.empty() : Optional.of(children);
  }

  public static <E> void findFilesInPath(
      Map<String, List<E>> classes,
      String searchLocation,
      String suffix,
      Function<List<Path>, List<E>> mapper) {
    Path searchPath = Path.of(searchLocation);

    TreeSet<String> filePaths;
    try (var walk = Files.walk(searchPath)) {
      filePaths =
          walk.map(searchPath::relativize)
              .map(Path::toString)
              .collect(Collectors.toCollection(TreeSet::new));
    } catch (IOException e) {
      throw new RuntimeException(e);
    }

    for (var className : classes.keySet()) {
      if (classes.get(className) != null) { // Already found by other method of searching
        continue;
      }
      var resultPaths = findClassAndChildren(filePaths, className, File.separator, suffix);
      if (resultPaths.isPresent()) {
        // [filePaths] and [resultPaths] are relativized to searchPath.
        // perform opposite operation (resolve) to get full paths.
        var fullPaths =
            resultPaths.get().stream().map(searchPath::resolve).collect(Collectors.toList());
        classes.put(className, mapper.apply(fullPaths));
      }
    }
  }

  public static <E> boolean findFilesInJar(
      Map<String, List<E>> classes,
      JarFile jar,
      String suffix,
      BiFunction<JarFile, List<ZipEntry>, List<E>> mapper) {

    // It appears JAR file entries are always separated by "/"
    var jarSeparator = "/";
    var entryNames =
        jar.stream().map(JarEntry::getName).collect(Collectors.toCollection(TreeSet::new));
    boolean foundClassesInThisJar = false;
    for (var fqn : classes.keySet()) {
      if (classes.get(fqn) != null) { // already found
        continue;
      }
      var resultPaths = findClassAndChildren(entryNames, fqn, jarSeparator, suffix);
      if (resultPaths.isPresent()) {
        var jarEntries = resultPaths.get().stream().map(jar::getEntry).collect(Collectors.toList());
        classes.put(fqn, mapper.apply(jar, jarEntries));
        foundClassesInThisJar = true;
      }
    }
    return foundClassesInThisJar;
  }

  public static <T> void find(
      Map<String, List<T>> classes,
      List<String> searchPaths,
      String suffix,
      Function<List<Path>, List<T>> fileMapper,
      BiFunction<JarFile, List<ZipEntry>, List<T>> entryMapper) {
    for (var searchPath : searchPaths) {
      File searchFile = new File(searchPath);
      if (searchFile.isDirectory()) {
        findFilesInPath(classes, searchPath, suffix, fileMapper);
      } else if (searchFile.isFile() && searchPath.endsWith(".jar")) {
        var jarFile = wrapCheckedException(JarFile::new, searchPath);
        var useful = findFilesInJar(classes, jarFile, suffix, entryMapper);
        if (!useful) {
          wrapCheckedException(jarFile::close);
        }
      }
    }
  }

  private static List<JavaFileObject> getJavaFileObjectsFromFiles(
      List<Path> paths, StandardJavaFileManager fm) {
    var result = new ArrayList<JavaFileObject>();
    var files = StreamUtil.map(paths, Path::toFile);
    fm.getJavaFileObjectsFromFiles(files).forEach(result::add);
    return result;
  }

  private static List<JavaFileObject> getJavaFileObjectsFromJar(
      JarFile jarFile, List<ZipEntry> entries) {
    return StreamUtil.map(entries, (entry) -> new JarEntryFileObject(jarFile, entry));
  }

  private static List<InputStreamProvider> getInputStreamProvidersFromFiles(List<Path> files) {
    return StreamUtil.map(files, (path) -> new FileInputStreamProvider(path.toFile()));
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
}
