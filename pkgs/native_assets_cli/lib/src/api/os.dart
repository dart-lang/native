// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' show Abi;
import 'dart:io';

import '../model/target.dart';
import 'architecture.dart';
import 'asset.dart';

part '../model/os.dart';

/// An operating system the Dart VM runs on.
abstract final class OS {
  /// The
  /// [Android](https://en.wikipedia.org/wiki/Android_%28operating_system%29)
  /// operating system.
  static const OS android = OSImpl.android;

  /// The [Fuchsia](https://en.wikipedia.org/wiki/Google_Fuchsia) operating
  /// system.
  static const OS fuchsia = OSImpl.fuchsia;

  /// The [iOS](https://en.wikipedia.org/wiki/IOS) operating system.
  static const OS iOS = OSImpl.iOS;

  /// The [Linux](https://en.wikipedia.org/wiki/Linux) operating system.
  static const OS linux = OSImpl.linux;

  /// The [macOS](https://en.wikipedia.org/wiki/MacOS) operating system.
  static const OS macOS = OSImpl.macOS;

  /// The
  /// [Microsoft Windows](https://en.wikipedia.org/wiki/Microsoft_Windows)
  /// operating system.
  static const OS windows = OSImpl.windows;

  /// Known values for [OS].
  static const List<OS> values = OSImpl.values;

  /// The default dynamic library file name on this os.
  String dylibFileName(String name);

  /// The default static library file name on this os.
  String staticlibFileName(String name);

  /// The default library file name on this os.
  String libraryFileName(String name, LinkMode linkMode);

  /// The default executable file name on this os.
  String executableFileName(String name);

  /// The current [OS].
  ///
  /// Consisten with the [Platform.version] string.
  static OS get current => OSImpl.current;
}
