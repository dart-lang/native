// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer;

import com.github.dart_lang.jnigen.apisummarizer.disasm.AsmSummarizer;
import com.github.dart_lang.jnigen.apisummarizer.doclet.SummarizerDoclet;
import com.github.dart_lang.jnigen.apisummarizer.elements.ClassDecl;
import com.github.dart_lang.jnigen.apisummarizer.util.ClassFinder;
import com.github.dart_lang.jnigen.apisummarizer.util.InputStreamProvider;
import com.github.dart_lang.jnigen.apisummarizer.util.JsonWriter;
import com.github.dart_lang.jnigen.apisummarizer.util.StreamUtil;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import javax.tools.DocumentationTool;
import javax.tools.JavaFileObject;
import javax.tools.ToolProvider;
import jdk.javadoc.doclet.Doclet;

public class Main {
  public enum Backend {
    /** Produce API descriptions from source files using Doclet API. */
    DOCLET,
    /** Produce API descriptions from class files under classpath. */
    ASM,
    /** Prefer source but fall back to JARs in classpath if sources not found. */
    AUTO,
  }

  static SummarizerOptions options;

  public static Map<String, ClassDecl> runDocletWithClass(
      DocumentationTool javaDoc,
      Class<? extends Doclet> docletClass,
      List<JavaFileObject> fileObjects,
      SummarizerOptions options) {
    var fileManager = javaDoc.getStandardFileManager(null, null, null);
    var cli = new ArrayList<String>();
    cli.add((options.useModules ? "--module-" : "--") + "source-path=" + options.sourcePath);
    if (options.classPath != null) {
      cli.add("--class-path=" + options.classPath);
    }
    cli.addAll(List.of("-encoding", "utf8"));

    if (options.toolArgs != null) {
      cli.addAll(List.of(options.toolArgs.split(" ")));
    }

    javaDoc.getTask(null, fileManager, stderr::println, docletClass, cli, fileObjects).call();

    return SummarizerDoclet.getClasses();
  }

  public static Map<String, ClassDecl> runDoclet(
      DocumentationTool javaDoc, List<JavaFileObject> javaFileObjects, SummarizerOptions options) {
    return runDocletWithClass(javaDoc, SummarizerDoclet.class, javaFileObjects, options);
  }

  static final PrintStream stderr = new PrintStream(System.err, true, StandardCharsets.UTF_8);

  public static void main(String[] args) throws FileNotFoundException {
    options = SummarizerOptions.parseArgs(args);
    OutputStream output;

    if (options.outputFile == null || options.outputFile.equals("-")) {
      output = new PrintStream(System.out, true, StandardCharsets.UTF_8);
    } else {
      output = new FileOutputStream(options.outputFile);
    }
    List<String> sourcePaths =
        options.sourcePath != null
            ? Arrays.asList(options.sourcePath.split(File.pathSeparator))
            : List.of();
    List<String> classPaths =
        options.classPath != null
            ? Arrays.asList(options.classPath.split(File.pathSeparator))
            : List.of();

    var javaDoc = ToolProvider.getSystemDocumentationTool();

    var sourceClasses = new LinkedHashMap<String, List<JavaFileObject>>();
    var binaryClasses = new LinkedHashMap<String, List<InputStreamProvider>>();

    for (var qualifiedName : options.args) {
      sourceClasses.put(qualifiedName, null);
      binaryClasses.put(qualifiedName, null);
    }

    if (options.backend != Backend.ASM) {
      ClassFinder.findJavaSources(
          sourceClasses, sourcePaths, javaDoc.getStandardFileManager(null, null, null));
    }

    if (options.backend != Backend.DOCLET) {
      ClassFinder.findJavaClasses(binaryClasses, classPaths);
    }

    var notFound = new ArrayList<String>();
    for (var qualifiedName : options.args) {
      var foundSource = sourceClasses.get(qualifiedName) != null;
      var foundBinary = binaryClasses.get(qualifiedName) != null;
      if (!foundBinary && !foundSource) {
        notFound.add(qualifiedName);
      }
    }

    if (!notFound.isEmpty()) {
      stderr.println("Not found: " + notFound);
      System.exit(1);
    }

    var classStreamProviders = StreamUtil.flattenListValues(binaryClasses);
    var sourceFiles = StreamUtil.flattenListValues(sourceClasses);

    switch (options.backend) {
      case DOCLET:
        JsonWriter.writeJSON(runDoclet(javaDoc, sourceFiles, options).values(), output);
        break;
      case ASM:
        JsonWriter.writeJSON(AsmSummarizer.run(classStreamProviders).values(), output);
        break;
      case AUTO:
        Map<String, ClassDecl> classes = new LinkedHashMap<>();
        // Preferring DOCLET as the source of summary a class exists in
        // both ASM and DOCLET.
        if (!classStreamProviders.isEmpty()) {
          classes.putAll(AsmSummarizer.run(classStreamProviders));
        }
        if (!sourceFiles.isEmpty()) {
          classes.putAll(runDoclet(javaDoc, sourceFiles, options));
        }
        JsonWriter.writeJSON(classes.values(), output);
        break;
    }
  }
}
