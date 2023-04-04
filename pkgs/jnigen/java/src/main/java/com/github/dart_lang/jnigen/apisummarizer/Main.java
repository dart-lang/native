// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer;

import com.github.dart_lang.jnigen.apisummarizer.disasm.AsmSummarizer;
import com.github.dart_lang.jnigen.apisummarizer.doclet.SummarizerDoclet;
import com.github.dart_lang.jnigen.apisummarizer.elements.ClassDecl;
import com.github.dart_lang.jnigen.apisummarizer.util.InputStreamProvider;
import com.github.dart_lang.jnigen.apisummarizer.util.JsonUtil;
import com.github.dart_lang.jnigen.apisummarizer.util.Log;
import com.github.dart_lang.jnigen.apisummarizer.util.SearchUtil;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
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

  public static List<ClassDecl> runDocletWithClass(
      DocumentationTool javaDoc,
      Class<? extends Doclet> docletClass,
      List<JavaFileObject> fileObjects,
      SummarizerOptions options) {
    Log.setVerbose(options.verbose);
    var fileManager = javaDoc.getStandardFileManager(null, null, null);
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

    javaDoc.getTask(null, fileManager, System.err::println, docletClass, cli, fileObjects).call();

    return SummarizerDoclet.getClasses();
  }

  public static List<ClassDecl> runDoclet(
      DocumentationTool javaDoc, List<JavaFileObject> javaFileObjects, SummarizerOptions options) {
    return runDocletWithClass(javaDoc, SummarizerDoclet.class, javaFileObjects, options);
  }

  public static void main(String[] args) throws FileNotFoundException {
    options = SummarizerOptions.parseArgs(args);
    OutputStream output;

    if (options.outputFile == null || options.outputFile.equals("-")) {
      output = System.out;
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

    var classStreamProviders = new ArrayList<InputStreamProvider>();
    var sourceFiles = new ArrayList<JavaFileObject>();
    var notFound = new ArrayList<String>();

    var javaDoc = ToolProvider.getSystemDocumentationTool();

    for (var qualifiedName : options.args) {
      var found = false;
      if (options.backend != Backend.ASM) {
        var sources =
            SearchUtil.findJavaSources(
                qualifiedName, sourcePaths, javaDoc.getStandardFileManager(null, null, null));
        if (sources.isPresent()) {
          sourceFiles.addAll(sources.get());
          found = true;
        }
      }
      if (options.backend != Backend.DOCLET && !found) {
        var classes = SearchUtil.findJavaClasses(qualifiedName, classPaths);
        if (classes.isPresent()) {
          classStreamProviders.addAll(classes.get());
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
        JsonUtil.writeJSON(runDoclet(javaDoc, sourceFiles, options), output);
        break;
      case ASM:
        JsonUtil.writeJSON(AsmSummarizer.run(classStreamProviders), output);
        break;
      case AUTO:
        List<ClassDecl> decls = new ArrayList<>();
        if (!sourceFiles.isEmpty()) {
          decls.addAll(runDoclet(javaDoc, sourceFiles, options));
        }
        if (!classStreamProviders.isEmpty()) {
          decls.addAll(AsmSummarizer.run(classStreamProviders));
        }
        JsonUtil.writeJSON(decls, output);
        break;
    }
  }
}
