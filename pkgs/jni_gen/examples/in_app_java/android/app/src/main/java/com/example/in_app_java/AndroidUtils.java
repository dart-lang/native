package com.example.in_app_java;

import android.app.Activity;
import android.widget.Toast;
import androidx.annotation.Keep;

@Keep
public class AndroidUtils {
  static void showToast(Activity mainActivity, CharSequence text, int duration) {
    mainActivity.runOnUiThread(() -> Toast.makeText(mainActivity, text, duration).show());
  }
}
