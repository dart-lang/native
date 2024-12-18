// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import java.util.List;
import java.util.stream.Collectors;
import kotlinx.metadata.Flag;
import kotlinx.metadata.KmClassifier;
import kotlinx.metadata.KmType;

public class KotlinType {
  public int flags;
  public String kind;
  public String name;
  public int id;
  public List<KotlinTypeProjection> arguments;
  public boolean isNullable;

  public static KotlinType fromKmType(KmType t) {
    if (t == null) return null;
    var type = new KotlinType();
    type.flags = t.getFlags();
    // Processing the information needed from the flags.
    type.isNullable = Flag.Type.IS_NULLABLE.invoke(type.flags);
    var classifier = t.getClassifier();
    if (classifier instanceof KmClassifier.Class) {
      type.kind = "class";
      type.name = ((KmClassifier.Class) classifier).getName();
    } else if (classifier instanceof KmClassifier.TypeAlias) {
      type.kind = "typeAlias";
      type.name = ((KmClassifier.TypeAlias) classifier).getName();
    } else if (classifier instanceof KmClassifier.TypeParameter) {
      type.kind = "typeParameter";
      type.id = ((KmClassifier.TypeParameter) classifier).getId();
    }
    type.arguments =
        t.getArguments().stream()
            .map(KotlinTypeProjection::fromKmTypeProjection)
            .collect(Collectors.toList());
    return type;
  }
}
