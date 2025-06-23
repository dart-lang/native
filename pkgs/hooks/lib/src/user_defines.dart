// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'config.dart';
import 'hooks/syntax.g.dart';

/// The user-defines for [HookInputBuilder.setupShared].
///
/// Currently only holds [workspacePubspec]. (In the future this class will also
/// take command-line arguments and a working directory for the command-line
/// argument paths to be resolved against.)
final class PackageUserDefines {
  /// User-defines originating from the `pubspec.yaml` in the workspace root.
  final PackageUserDefinesSource? workspacePubspec;

  /// Creates a [PackageUserDefines].
  PackageUserDefines({required this.workspacePubspec});

  @override
  String toString() =>
      'PackageUserDefines(workspacePubspec: $workspacePubspec)';
}

/// Extension methods for [PackageUserDefines] to convert to and from syntax
/// nodes.
extension PackageUserDefinesSyntaxExtension on PackageUserDefines {
  /// Creates a [PackageUserDefines] from a [UserDefinesSyntax] node.
  static PackageUserDefines fromSyntax(UserDefinesSyntax syntaxNode) =>
      PackageUserDefines(
        workspacePubspec: switch (syntaxNode.workspacePubspec) {
          null => null,
          final o => PackageUserDefinesSourceSyntaxExtension.fromSyntax(o),
        },
      );

  /// Converts this [PackageUserDefines] to a [UserDefinesSyntax] node.
  UserDefinesSyntax toSyntax() {
    final result = UserDefinesSyntax(
      workspacePubspec: workspacePubspec?.toSyntax(),
    );

    return result;
  }
}

/// A source of user-defines in a [PackageUserDefines].
final class PackageUserDefinesSource {
  /// The user-defined values.
  final Map<String, Object?> defines;

  /// The base path for relative paths in [defines].
  final Uri basePath;

  /// Creates a [PackageUserDefinesSource].
  PackageUserDefinesSource({required this.defines, required this.basePath});

  @override
  String toString() =>
      'PackageUserDefinesSource(defines: $defines, basePath: $basePath)';
}

/// Extension methods for [PackageUserDefinesSource] to convert to and from
/// syntax nodes.
extension PackageUserDefinesSourceSyntaxExtension on PackageUserDefinesSource {
  /// Creates a [PackageUserDefinesSource] from a [UserDefinesSourceSyntax]
  /// node.
  static PackageUserDefinesSource fromSyntax(
    UserDefinesSourceSyntax syntaxNode,
  ) => PackageUserDefinesSource(
    defines: syntaxNode.defines.json,
    basePath: syntaxNode.basePath,
  );

  /// Converts this [PackageUserDefinesSource] to a [UserDefinesSourceSyntax]
  /// node.
  UserDefinesSourceSyntax toSyntax() => UserDefinesSourceSyntax(
    basePath: basePath,
    defines: JsonObjectSyntax.fromJson(defines),
  );
}
