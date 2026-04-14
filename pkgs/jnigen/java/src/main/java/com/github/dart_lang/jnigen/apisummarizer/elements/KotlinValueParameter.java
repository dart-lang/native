// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.apisummarizer.elements;

import kotlin.metadata.KmValueParameter;

public class KotlinValueParameter {
  public String name;
  public KotlinType type;
  public KotlinType varargElementType;

  public static KotlinValueParameter fromKmValueParameter(KmValueParameter p) {
    if (p == null) return null;
    var param = new KotlinValueParameter();
    param.name = p.getName();
    param.type = KotlinType.fromKmType(p.getType());
    param.varargElementType = KotlinType.fromKmType(p.getVarargElementType());
    return param;
  }
}
