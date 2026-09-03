// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/config_provider/utils.dart';

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Uri.directory(Directory.current.path);
  final testDir = packageRoot.resolve('test/native_objc_test/');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: testDir.resolve('sdk_variable_test_bindings.dart'),
      ),
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(
      entryPoints: [
        Uri.file(
          substituteVars(
            r'$XCODE/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/AppKit.framework/Headers/NSColorPicker.h',
          ),
        ),
        Uri.file(
          substituteVars(
            r'$IOS_SDK/System/Library/Frameworks/UIKit.framework/Headers/UIPickerView.h',
          ),
        ),
        Uri.file(
          substituteVars(
            r'$MACOS_SDK/System/Library/Frameworks/AppKit.framework/Headers/NSTextList.h',
          ),
        ),
      ],
    ),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) {
          const include = {'NSColorPicker', 'UIPickerView', 'NSTextList'};
          node.isIncluded = include.contains(node.originalName);
        },
        objCMethod: (node) {
          final parent = node.parent;
          if (parent is ObjCInterface &&
              parent.originalName == 'NSTextList' &&
              node.selector == 'includesTextListMarkers') {
            node.isIncluded = false;
          }
        },
      ),
    ],
  );
}
