// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

/**
 * A class or interface declaration.
 *
 * <p>Here's an example for various kinds of names stored in this structure: { simpleName :
 * "Example", binaryName : "dev.dart.sample.Example", parentName : null, packageName :
 * "dev.dart.sample", }
 */
public class ClassDecl {
  public DeclKind declKind;

  /** Modifiers eg: static, public and abstract. */
  public Set<String> modifiers;

  /** Unqualified name of the class. For example `ClassDecl` */
  public String simpleName;

  /**
   * Unique, fully qualified name of the class, it's like a qualified name used in a program but
   * uses $ instead of dot (.) before nested classes.
   */
  public String binaryName;

  public String parentName;
  public String packageName;
  public List<TypeParam> typeParams = new ArrayList<>();
  public List<Method> methods = new ArrayList<>();
  public List<Field> fields = new ArrayList<>();
  public TypeUsage superclass;
  public List<TypeUsage> interfaces = new ArrayList<>();
  public boolean hasStaticInit;
  public boolean hasInstanceInit;
  public JavaDocComment javadoc;
  public List<JavaAnnotation> annotations;

  /** In case of enum, names of enum constants */
  public List<String> values = new ArrayList<>();
}
