// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'config.dart';
import 'hooks/syntax.g.dart';

/// The user-defines for [HookInputBuilder].
///
/// Currently only holds [workspacePubspec]. (In the future this class will also
/// take command-line arguments and a working directory for the command-line
/// argument paths to be resolved against.)
final class PackageUserDefines {
  final PackageUserDefinesSource? workspacePubspec;

  PackageUserDefines({required this.workspacePubspec});

  @override
  String toString() =>
      'PackageUserDefines(workspacePubspec: $workspacePubspec)';
}

extension PackageUserDefinesSyntaxExtension on PackageUserDefines {
  static PackageUserDefines fromSyntax(UserDefinesSyntax syntaxNode) =>
      PackageUserDefines(
        workspacePubspec: switch (syntaxNode.workspacePubspec) {
          null => null,
          final o => PackageUserDefinesSourceSyntaxExtension.fromSyntax(o),
        },
      );

  UserDefinesSyntax toSyntax() {
    final result = UserDefinesSyntax(
      workspacePubspec: workspacePubspec?.toSyntax(),
    );

    return result;
  }
}

/// A source of user-defines in a [PackageUserDefines].
final class PackageUserDefinesSource {
  final Map<String, Object?> defines;

  /// The base path for relative paths in [defines].
  final Uri basePath;

  PackageUserDefinesSource({required this.defines, required this.basePath});

  @override
  String toString() =>
      'PackageUserDefinesSource(defines: $defines, basePath: $basePath)';
}

extension PackageUserDefinesSourceSyntaxExtension on PackageUserDefinesSource {
  static PackageUserDefinesSource fromSyntax(
    UserDefinesSourceSyntax syntaxNode,
  ) => PackageUserDefinesSource(
    defines: syntaxNode.defines.json,
    basePath: syntaxNode.basePath,
  );

  UserDefinesSourceSyntax toSyntax() => UserDefinesSourceSyntax(
    basePath: basePath,
    defines: JsonObjectSyntax.fromJson(defines),
  );
}
