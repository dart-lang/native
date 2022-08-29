// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:path/path.dart';

class AndroidSdkTools {
  /// get path for android API sources
  static Future<String?> _getVersionDir(
      String relative, String? sdkRoot, List<int> versionOrder) async {
    sdkRoot ??= Platform.environment['ANDROID_SDK_ROOT'];
    if (sdkRoot == null) {
      throw ArgumentError('SDK Root not provided and ANDROID_SDK_ROOT not set');
    }
    final parent = join(sdkRoot, relative);
    for (var version in versionOrder) {
      final dir = Directory(join(parent, 'android-$version'));
      if (await dir.exists()) {
        return dir.path;
      }
    }
    return null;
  }

  static Future<String?> getAndroidSourcesPath(
      {String? sdkRoot, required List<int> versionOrder}) async {
    return _getVersionDir('sources', sdkRoot, versionOrder);
  }

  static Future<String?> _getFile(String relative, String file, String? sdkRoot,
      List<int> versionOrder) async {
    final platform = await _getVersionDir(relative, sdkRoot, versionOrder);
    if (platform == null) return null;
    final filePath = join(platform, file);
    if (await File(filePath).exists()) {
      return filePath;
    }
    return null;
  }

  static Future<String?> getAndroidJarPath(
          {String? sdkRoot, required List<int> versionOrder}) async =>
      await _getFile('platforms', 'android.jar', sdkRoot, versionOrder);
}
