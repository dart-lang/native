// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

import 'tool.dart';
import 'tool_instance.dart';

abstract class Requirement {
  /// Tries to satisfy this requirement.
  ///
  /// If the requirement can be satisfied, returns the set of tools that
  /// satisfy the requirement.
  ///
  /// Currently does not check that we only use a single version of a tool.
  List<ToolInstance>? satisfy(List<ToolInstance> allAvailableTools);
}

class ToolRequirement implements Requirement {
  final Tool tool;

  final Version? minimumVersion;

  ToolRequirement(
    this.tool, {
    this.minimumVersion,
  });

  @override
  String toString() =>
      'ToolRequirement(${tool.name}, minimumVersion: $minimumVersion)';

  @override
  List<ToolInstance>? satisfy(List<ToolInstance> availableToolInstances) {
    final candidates = <ToolInstance>[];
    for (final instance in availableToolInstances) {
      if (instance.tool == tool) {
        final minimumVersion_ = minimumVersion;
        if (minimumVersion_ == null) {
          candidates.add(instance);
        } else {
          final version = instance.version;
          if (version != null && version >= minimumVersion_) {
            candidates.add(instance);
          }
        }
      }
    }
    if (candidates.isEmpty) {
      return null;
    }
    candidates.sort();
    return [candidates.last];
  }
}

class RequireOne implements Requirement {
  final List<Requirement> alternatives;

  RequireOne(this.alternatives);

  @override
  List<ToolInstance>? satisfy(List<ToolInstance> allAvailableTools) {
    for (final alternative in alternatives) {
      final result = alternative.satisfy(allAvailableTools);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

class RequireAll implements Requirement {
  final List<Requirement> requirements;

  RequireAll(this.requirements);

  @override
  List<ToolInstance>? satisfy(List<ToolInstance> allAvailableTools) {
    final result = <ToolInstance>[];
    for (final requirement in requirements) {
      final requirementResult = requirement.satisfy(allAvailableTools);
      if (requirementResult == null) {
        return null;
      }
      result.addAll(requirementResult);
    }
    return result;
  }
}
