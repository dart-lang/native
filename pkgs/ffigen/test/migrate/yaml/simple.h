// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Color values for drawing.
typedef enum {
  Red = 0,
  Green = 1,
  Blue = 2,
} Color;

/// A 2D point with X and Y coordinates.
typedef struct {
  double x;
  double y;
} Point;

/// Calculates the Euclidean distance between two points.
double distance(Point a, Point b);
