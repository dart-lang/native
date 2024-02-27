// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.doclet;

import com.github.dart_lang.jnigen.apisummarizer.elements.ClassDecl;
import com.github.dart_lang.jnigen.apisummarizer.elements.Method;
import com.github.dart_lang.jnigen.apisummarizer.elements.Package;
import com.github.dart_lang.jnigen.apisummarizer.util.Log;
import com.github.dart_lang.jnigen.apisummarizer.util.SkipException;
import java.util.*;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.*;
import javax.lang.model.util.ElementScanner9;
import jdk.javadoc.doclet.Doclet;
import jdk.javadoc.doclet.DocletEnvironment;
import jdk.javadoc.doclet.Reporter;

public class SummarizerDoclet implements Doclet {
  private AstEnv utils;

  @Override
  public void init(Locale locale, Reporter reporter) {}

  @Override
  public String getName() {
    return "ApiSummarizer";
  }

  @Override
  public Set<? extends Option> getSupportedOptions() {
    return Collections.emptySet();
  }

  @Override
  public SourceVersion getSupportedSourceVersion() {
    return SourceVersion.RELEASE_11;
  }

  public static Map<String, ClassDecl> getClasses() {
    return classes;
  }

  public static Map<String, ClassDecl> classes;

  @Override
  public boolean run(DocletEnvironment docletEnvironment) {
    Log.info("Initializing doclet");
    utils = AstEnv.fromEnvironment(docletEnvironment);
    SummarizingScanner scanner = new SummarizingScanner();
    docletEnvironment.getSpecifiedElements().forEach(e -> scanner.scan(e, new SummaryCollector()));
    classes = scanner.types;
    return true;
  }

  public static class SummaryCollector {
    Stack<Package> packages = new Stack<>();
    Stack<ClassDecl> types = new Stack<>();
    Method method;
  }

  public class SummarizingScanner extends ElementScanner9<Void, SummaryCollector> {
    List<Package> packages = new ArrayList<>();
    Map<String, ClassDecl> types = new HashMap<>();
    ElementBuilders builders = new ElementBuilders(utils);

    // Each element in collector is a stack
    // which is used to get topmost element
    // and append the child to it.
    // Eg: A variable element is always appended to topmost
    // class
    @Override
    public Void scan(Element e, SummaryCollector collector) {
      return super.scan(e, collector);
    }

    @Override
    public Void visitPackage(PackageElement e, SummaryCollector collector) {
      Log.info("Visiting package: %s", e.getQualifiedName());
      collector.packages.push(new Package());
      System.out.println("package: " + e.getQualifiedName());
      var result = super.visitPackage(e, collector);
      var collectedPackage = collector.packages.pop();
      packages.add(collectedPackage);
      return result;
    }

    @Override
    public Void visitType(TypeElement e, SummaryCollector collector) {
      if (!collector.types.isEmpty()) {
        return null;
      }
      Log.info("Visiting class: %s, %s", e.getQualifiedName(), collector.types);
      switch (e.getKind()) {
        case CLASS:
        case INTERFACE:
        case ENUM:
          try {
            var cls = builders.classDecl(e);
            collector.types.push(cls);
            super.visitType(e, collector);
            var puttingClass = collector.types.pop();
            types.put(puttingClass.binaryName, puttingClass);
          } catch (SkipException skip) {
            Log.info("Skip type: %s", e.getQualifiedName());
          }
          break;
        case ANNOTATION_TYPE:
          Log.info("Skip annotation type: %s", e.getQualifiedName());
          break;
      }
      return null;
    }

    @Override
    public Void visitVariable(VariableElement e, SummaryCollector collector) {
      var vk = e.getKind();
      var cls = collector.types.peek();
      switch (vk) {
        case ENUM_CONSTANT:
          cls.values.add(e.getSimpleName().toString());
          break;
        case FIELD:
          cls.fields.add(builders.field(e));
          break;
        case PARAMETER:
          if (collector.method == null) {
            throw new RuntimeException("Parameter encountered outside executable element");
          }
          var method = collector.method;
          method.params.add(builders.param(e));
          break;
        default:
          System.out.println("Unknown type of variable element: " + vk);
      }
      return null;
    }

    @Override
    public Void visitExecutable(ExecutableElement element, SummaryCollector collector) {
      var cls = collector.types.peek();
      switch (element.getKind()) {
        case METHOD:
        case CONSTRUCTOR:
          try {
            var method = builders.method(element);
            collector.method = method;
            super.visitExecutable(element, collector);
            collector.method = null;
            cls.methods.add(method);
          } catch (SkipException skip) {
            Log.info("Skip method: %s", element.getSimpleName());
          }
          break;
        case STATIC_INIT:
          cls.hasStaticInit = true;
          break;
        case INSTANCE_INIT:
          cls.hasInstanceInit = true;
          break;
      }
      return null;
    }
  }
}
