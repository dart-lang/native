package com.github.dart_lang.jnigen.apisummarizer.elements;

import java.util.List;
import java.util.stream.Collectors;
import kotlinx.metadata.KmPackage;

public class KotlinPackage {
  public List<KotlinFunction> functions;

  public static KotlinPackage fromKmPackage(KmPackage p) {
    var pkg = new KotlinPackage();
    pkg.functions =
        p.getFunctions().stream().map(KotlinFunction::fromKmFunction).collect(Collectors.toList());
    return pkg;
  }
}
