// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import kotlinx.metadata.KmTypeProjection;
import kotlinx.metadata.KmVariance;

public class KotlinTypeProjection {
  public KotlinType type;
  public KmVariance variance;

  public static KotlinTypeProjection fromKmTypeProjection(KmTypeProjection t) {
    var proj = new KotlinTypeProjection();
    proj.type = KotlinType.fromKmType(t.getType());
    proj.variance = t.getVariance();
    if (proj.type == null) {
      return null;
    }
    return proj;
  }
}
