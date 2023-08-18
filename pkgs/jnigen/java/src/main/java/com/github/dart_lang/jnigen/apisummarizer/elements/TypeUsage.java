// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import java.util.List;

public class TypeUsage {
  public TypeUsage(String shorthand, Kind kind, ReferredType type) {
    this.shorthand = shorthand;
    this.kind = kind;
    this.type = type;
  }

  public TypeUsage() {}

  public enum Kind {
    DECLARED,
    TYPE_VARIABLE,
    WILDCARD,
    ARRAY,
    INTERSECTION,
    PRIMITIVE,
  }

  // Could've made it just a type hierarchy, but client code parsing JSON
  // needs to know the type beforehand, before it can deserialize the `type` field.
  public String shorthand;
  public Kind kind;
  public ReferredType type;

  public abstract static class ReferredType {}

  public static class PrimitiveType extends ReferredType {
    public String name;

    public PrimitiveType(String name) {
      this.name = name;
    }
  }

  public static class DeclaredType extends ReferredType {
    public String binaryName;
    public String simpleName;
    public List<TypeUsage> params;

    public DeclaredType(String binaryName, String simpleName, List<TypeUsage> params) {
      this.binaryName = binaryName;
      this.simpleName = simpleName;
      this.params = params;
    }
  }

  public static class TypeVar extends ReferredType {
    public String name;

    public TypeVar(String name) {
      this.name = name;
    }
  }

  public static class Wildcard extends ReferredType {
    public TypeUsage extendsBound, superBound;

    public Wildcard(TypeUsage extendsBound, TypeUsage superBound) {
      this.extendsBound = extendsBound;
      this.superBound = superBound;
    }
  }

  public static class Intersection extends ReferredType {
    public List<TypeUsage> types;

    public Intersection(List<TypeUsage> types) {
      this.types = types;
    }
  }

  public static class Array extends ReferredType {
    public TypeUsage type;

    public Array(TypeUsage type) {
      this.type = type;
    }
  }
}
