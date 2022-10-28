// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer;

import static com.github.dart_lang.jnigen.apisummarizer.util.ExceptionUtil.wrapCheckedException;

import com.github.dart_lang.jnigen.apisummarizer.disasm.AsmSummarizer;
import com.github.dart_lang.jnigen.apisummarizer.doclet.SummarizerDoclet;
import com.github.dart_lang.jnigen.apisummarizer.elements.ClassDecl;
import com.github.dart_lang.jnigen.apisummarizer.util.JsonUtil;
import com.github.dart_lang.jnigen.apisummarizer.util.Log;
import com.github.dart_lang.jnigen.apisummarizer.util.StreamUtil;
import java.io.*;
import java.util.*;
import java.util.jar.JarFile;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import javax.tools.DocumentationTool;
import javax.tools.ToolProvider;
import jdk.javadoc.doclet.Doclet;
import org.apache.commons.cli.*;

public class Main {
  public enum Backend {
    // Produce API descriptions from source files using Doclet API.
    DOCLET,
    // Produce API descriptions from class files under classpath.
    ASM,
    // Prefer source but fall back to JARs in classpath if sources not found.
    AUTO,
  }

  public static class SummarizerOptions {
    String sourcePath;
    String classPath;
    boolean useModules;
    Backend backend;
    String modulesList;
    boolean addDependencies;
    String toolArgs;
    boolean verbose;
    String outputFile;
    String[] args;

    SummarizerOptions() {}

    public static SummarizerOptions fromCommandLine(CommandLine cmd) {
      var opts = new SummarizerOptions();
      opts.sourcePath = cmd.getOptionValue("sources", ".");
      var backendString = cmd.getOptionValue("backend", "auto");
      opts.backend = Backend.valueOf(backendString.toUpperCase());
      opts.classPath = cmd.getOptionValue("classes", null);
      opts.useModules = cmd.hasOption("use-modules");
      opts.modulesList = cmd.getOptionValue("module-names", null);
      opts.addDependencies = cmd.hasOption("recursive");
      opts.toolArgs = cmd.getOptionValue("doctool-args", null);
      opts.verbose = cmd.hasOption("verbose");
      opts.outputFile = cmd.getOptionValue("output-file", null);
      opts.args = cmd.getArgs();
      return opts;
    }
  }

  private static final CommandLineParser parser = new DefaultParser();
  static SummarizerOptions options;

  public static SummarizerOptions parseArgs(String[] args) {
    var options = new Options();
    Option sources = new Option("s", "sources", true, "paths to search for source files");
    Option classes = new Option("c", "classes", true, "paths to search for compiled classes");
    Option backend =
        new Option(
            "b",
            "backend",
            true,
            "backend to use for summary generation ('doclet', 'asm' or 'auto' (default)).");
    Option useModules = new Option("M", "use-modules", false, "use Java modules");
    Option recursive = new Option("r", "recursive", false, "Include dependencies of classes");
    Option moduleNames =
        new Option("m", "module-names", true, "comma separated list of module names");
    Option doctoolArgs =
        new Option("D", "doctool-args", true, "Arguments to pass to the documentation tool");
    Option verbose = new Option("v", "verbose", false, "Enable verbose output");
    Option outputFile =
        new Option("o", "output-file", true, "Write JSON to file instead of stdout");
    for (Option opt :
        new Option[] {
          sources,
          classes,
          backend,
          useModules,
          recursive,
          moduleNames,
          doctoolArgs,
          verbose,
          outputFile,
        }) {
      options.addOption(opt);
    }

    HelpFormatter help = new HelpFormatter();

    CommandLine cmd;

    try {
      cmd = parser.parse(options, args);
      if (cmd.getArgs().length < 1) {
        throw new ParseException("Need to specify paths to source files");
      }
    } catch (ParseException e) {
      System.out.println(e.getMessage());
      help.printHelp(
          "java -jar <JAR> [-s <SOURCE_DIR=.>] "
              + "[-c <CLASSES_JAR>] <CLASS_OR_PACKAGE_NAMES>\n"
              + "Class or package names should be fully qualified.\n\n",
          options);
      System.exit(1);
      throw new RuntimeException("Unreachable code");
    }
    return SummarizerOptions.fromCommandLine(cmd);
  }

  public static List<ClassDecl> runDocletWithClass(
      Class<? extends Doclet> docletClass, List<File> javaFilePaths, SummarizerOptions options) {
    Log.setVerbose(options.verbose);

    var files = javaFilePaths.stream().map(File::getPath).toArray(String[]::new);

    DocumentationTool javadoc = ToolProvider.getSystemDocumentationTool();
    var fileManager = javadoc.getStandardFileManager(null, null, null);
    var fileObjects = fileManager.getJavaFileObjects(files);

    var cli = new ArrayList<String>();
    cli.add((options.useModules ? "--module-" : "--") + "source-path=" + options.sourcePath);
    if (options.classPath != null) {
      cli.add("--class-path=" + options.classPath);
    }
    if (options.addDependencies) {
      cli.add("--expand-requires=all");
    }
    cli.addAll(List.of("-encoding", "utf8"));

    if (options.toolArgs != null) {
      cli.addAll(List.of(options.toolArgs.split(" ")));
    }

    javadoc.getTask(null, fileManager, System.err::println, docletClass, cli, fileObjects).call();

    return SummarizerDoclet.getClasses();
  }

  public static List<ClassDecl> runDoclet(List<File> javaFilePaths, SummarizerOptions options) {
    return runDocletWithClass(SummarizerDoclet.class, javaFilePaths, options);
  }

  /**
   * Lists all files under given directory, which satisfy the condition of filter. The order of
   * listing shall be deterministic.
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

  /**
   * Finds and returns source file (s) corresponding to qualified name. It's assumed that package
   * hierarchy in Java is same as the filesystem hierarchy, i.e. each package corresponds to a
   * directory and each class corresponds to a file in its respective package. If the respective
   * file or directory does not exist, the returned optional is empty.
   */
  public static Optional<List<File>> findSourceFiles(String qualifiedName, String[] sourcePaths) {
    return findFiles(qualifiedName, sourcePaths, ".java");
  }

  public static Optional<List<File>> findFiles(
      String qualifiedName, String[] searchPaths, String suffix) {
    var s = qualifiedName.replace(".", "/");
    for (var folder : searchPaths) {
      var f = new File(folder, s + suffix);
      if (f.exists() && f.isFile()) {
        return Optional.of(List.of(f));
      }
      var d = new File(folder, s);
      if (d.exists() && d.isDirectory()) {
        return Optional.of(recursiveListFiles(d, file -> file.getName().endsWith(".java")));
      }
    }
    return Optional.empty();
  }

  public static Optional<List<InputStream>> findClassInputStreamsInJar(
      JarFile jar, String relativePath) {
    var suffix = ".class";
    var classEntry = jar.getEntry(relativePath + suffix);
    if (classEntry != null) {
      return Optional.of(List.of(wrapCheckedException(jar::getInputStream, classEntry)));
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
              .map(entry -> wrapCheckedException(jar::getInputStream, entry))
              .collect(Collectors.toList());
      return Optional.of(result);
    }
    return Optional.empty();
  }

  /**
   * Finds and returns class file(s) corresponding to qualified name from JAR files in classpath.
   */
  public static Optional<List<InputStream>> findClassInputStreams(
      String binaryName, String[] classPaths) {
    String relativePath = binaryName.replace(".", "/");
    for (var path : classPaths) {
      var file = new File(path);
      // A path in classpath can be a directory or JAR. These cases require different logic.
      if (file.isDirectory()) {
        var directorySearchResult = findFiles(binaryName, classPaths, ".class");
        if (directorySearchResult.isPresent()) {
          var list = directorySearchResult.get();
          return Optional.of(
              StreamUtil.map(
                  list, fileElement -> wrapCheckedException(FileInputStream::new, fileElement)));
        }
        continue;
      }
      try {
        JarFile jar = new JarFile(file);
        var inJar = findClassInputStreamsInJar(jar, relativePath);
        if (inJar.isPresent()) {
          return inJar;
        } else {
          jar.close();
        }
      } catch (IOException e) {
        throw new RuntimeException(e);
      }
    }
    return Optional.empty();
  }

  public static void main(String[] args) throws FileNotFoundException {
    options = parseArgs(args);
    OutputStream output;
    if (options.outputFile == null || options.outputFile.equals("-")) {
      output = System.out;
    } else {
      output = new FileOutputStream(options.outputFile);
    }
    var sourcePaths =
        options.sourcePath != null ? options.sourcePath.split(File.pathSeparator) : new String[] {};
    var classPaths =
        options.classPath != null ? options.classPath.split(File.pathSeparator) : new String[] {};
    var classStreams = new ArrayList<InputStream>();
    var sourceFiles = new ArrayList<File>();
    var notFound = new ArrayList<String>();
    for (var qualifiedName : options.args) {
      var found = false;
      if (options.backend != Backend.ASM) {
        var sources = findSourceFiles(qualifiedName, sourcePaths);
        if (sources.isPresent()) {
          sourceFiles.addAll(sources.get());
          found = true;
        }
      }
      if (options.backend != Backend.DOCLET && !found) {
        var classes = findClassInputStreams(qualifiedName, classPaths);
        if (classes.isPresent()) {
          classStreams.addAll(classes.get());
          found = true;
        }
      }
      if (!found) {
        notFound.add(qualifiedName);
      }
    }

    if (!notFound.isEmpty()) {
      System.err.println("Not found: " + notFound);
      System.exit(1);
    }

    switch (options.backend) {
      case DOCLET:
        JsonUtil.writeJSON(runDoclet(sourceFiles, options), output);
        break;
      case ASM:
        JsonUtil.writeJSON(AsmSummarizer.run(classStreams), output);
        break;
      case AUTO:
        var decls = runDoclet(sourceFiles, options);
        decls.addAll(AsmSummarizer.run(classStreams));
        JsonUtil.writeJSON(decls, output);
        break;
    }
  }
}
