// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let package = Package(
    name: "swift2objc",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift2objc",
            targets: ["swift2objc"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift2objc"),
        .testTarget(
            name: "swift2objcTests",
            dependencies: ["swift2objc"]),
    ]
)
