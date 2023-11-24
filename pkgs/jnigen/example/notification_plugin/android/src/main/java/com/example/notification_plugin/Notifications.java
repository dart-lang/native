// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example.notification_plugin;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.os.Build;
import androidx.annotation.Keep;
import androidx.core.app.NotificationCompat;

@Keep
public class Notifications {
  public static void showNotification(
      Context context, int notificationID, String title, String text) {
    @SuppressWarnings("deprecation")
    NotificationCompat.Builder builder =
        new NotificationCompat.Builder(context)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(text);
    NotificationManager notificationManager =
        (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.O) {
      String channelId = "my_channel";
      NotificationChannel channel =
          new NotificationChannel(
              channelId, "My App's notifications", NotificationManager.IMPORTANCE_HIGH);
      notificationManager.createNotificationChannel(channel);
      builder.setChannelId(channelId);
    }
    notificationManager.notify(notificationID, builder.build());
  }
}
