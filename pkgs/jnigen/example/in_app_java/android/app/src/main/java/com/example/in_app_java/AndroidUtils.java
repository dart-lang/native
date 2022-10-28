// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example.in_app_java;

import android.app.Activity;
import android.widget.Toast;
import androidx.annotation.Keep;

@Keep
public abstract class AndroidUtils {
  // Hide constructor
  private AndroidUtils() {}

  public static void showToast(Activity mainActivity, CharSequence text, int duration) {
    mainActivity.runOnUiThread(() -> Toast.makeText(mainActivity, text, duration).show());
  }
}
