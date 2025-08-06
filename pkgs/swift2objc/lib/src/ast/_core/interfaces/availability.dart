// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A Swift declaration's availability info.
abstract interface class Availability {
  abstract final List<AvailabilityInfo> availability;
}

/// The availability for a single domain.
class AvailabilityInfo {
  String domain;
  bool unavailable;
  AvailabilityVersion? introduced;
  AvailabilityVersion? deprecated;
  AvailabilityVersion? obsoleted;

  AvailabilityInfo({
    required this.domain,
    required this.unavailable,
    required this.introduced,
    required this.deprecated,
    required this.obsoleted,
  });
}

/// A version for availability.
class AvailabilityVersion {
  int major;
  int? minor;
  int? patch;

  AvailabilityVersion(
      {required this.major, required this.minor, required this.patch});

  @override
  String toString() => [major, minor, patch].nonNulls.join('.');
}
