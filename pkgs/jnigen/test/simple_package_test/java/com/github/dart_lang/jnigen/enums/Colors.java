// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jnigen.enums;

import java.util.Objects;

public enum Colors {
  red(0xFF0000),
  green(0x00FF00),
  blue(0x0000FF);

  public final int code;

  Colors(int code) {
    this.code = code;
  }

  public static class RGB {
    public int red;
    public int green;
    public int blue;

    public RGB(int red, int green, int blue) {
      this.red = red;
      this.green = green;
      this.blue = blue;
    }

    @Override
    public boolean equals(Object o) {
      if (this == o) return true;
      if (o == null || getClass() != o.getClass()) return false;
      RGB rgb = (RGB) o;
      return red == rgb.red && green == rgb.green && blue == rgb.blue;
    }

    @Override
    public int hashCode() {
      return Objects.hash(red, green, blue);
    }
  }

  public RGB toRGB() {
    return new RGB(code >> 16, (code >> 8) & 0xFF, code & 0xFF);
  }
}
