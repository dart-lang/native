// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import java.util.List;
import java.util.stream.Collectors;
import kotlin.metadata.KmTypeParameter;
import kotlin.metadata.KmVariance;

public class KotlinTypeParameter {
  public String name;
  public int id;
  public List<KotlinType> upperBounds;
  public KmVariance variance;

  public static KotlinTypeParameter fromKmTypeParameter(KmTypeParameter t) {
    var typeParam = new KotlinTypeParameter();
    typeParam.name = t.getName();
    typeParam.id = t.getId();
    typeParam.upperBounds =
        t.getUpperBounds().stream().map(KotlinType::fromKmType).collect(Collectors.toList());
    typeParam.variance = t.getVariance();
    return typeParam;
  }
}
