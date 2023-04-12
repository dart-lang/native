// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

import 'tool.dart';

class ToolInstance implements Comparable<ToolInstance> {
  /// The name of the tool.
  final Tool tool;

  /// The path of the native tool on the system.
  final Uri uri;

  /// The version of the native tool.
  ///
  /// Can be null if version is hard to determine.
  final Version? version;

  ToolInstance({
    required this.tool,
    required this.uri,
    this.version,
  });

  ToolInstance copyWith({Uri? uri, Version? version}) => ToolInstance(
        tool: tool,
        uri: uri ?? this.uri,
        version: version ?? this.version,
      );

  @override
  String toString() => 'ToolInstance(${tool.name}, $version, $uri)';

  /// Compares this tool instance to [other].
  ///
  /// When used in sorting, orders [ToolInstance]s according to:
  /// 1. [tool] name, alphabetically; then
  /// 2. [version], newest first and preferring having a version; then
  /// 3. [uri], alphabetically.
  @override
  int compareTo(ToolInstance other) {
    final nameCompare = tool.name.compareTo(other.tool.name);
    if (nameCompare != 0) {
      return nameCompare;
    }
    final version = this.version;
    final otherVersion = other.version;
    if (version != null || otherVersion != null) {
      if (version == null) {
        return 1;
      }
      if (otherVersion == null) {
        return -1;
      }
      final versionCompare = version.compareTo(otherVersion);
      if (versionCompare != 0) {
        return -versionCompare;
      }
    }
    return uri.toFilePath().compareTo(other.uri.toFilePath());
  }

  @override
  bool operator ==(Object other) =>
      other is ToolInstance &&
      tool == other.tool &&
      uri == other.uri &&
      version == other.version;

  @override
  int get hashCode => Object.hash(tool, uri, version);
}
