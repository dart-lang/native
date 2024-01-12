// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

import '../model/asset.dart' as model;
import '../model/build_output.dart' as model;
import '../model/dependencies.dart' as model;
import '../model/metadata.dart' as model;
import 'asset.dart';
import 'dependencies.dart';
import 'metadata.dart';

abstract class BuildOutput {
  factory BuildOutput({
    DateTime? timestamp,
    List<Asset>? assets,
    Dependencies? dependencies,
    Metadata? metadata,
  }) =>
      model.BuildOutput(
        timestamp: timestamp,
        assets: assets?.map((e) => e as model.Asset).toList(),
        dependencies: dependencies as model.Dependencies?,
        metadata: metadata as model.Metadata?,
      );

  /// The version of [BuildOutput].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through `build.dart` invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the YAML
  /// representation in the protocol.
  static Version get version => model.BuildOutput.version;

  Future<void> writeToFile({required Uri outDir});
}
