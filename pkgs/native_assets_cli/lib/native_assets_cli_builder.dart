// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Support for hook invokers (e.g. building / bundling tools).
library;

export 'native_assets_cli.dart' hide build, link;
export 'src/config.dart'
    show
        BuildConfigBuilder,
        BuildOutput,
        HookConfigBuilder,
        HookOutput,
        LinkConfigBuilder,
        LinkOutput;
export 'src/model/dependencies.dart';
export 'src/model/resource_identifiers.dart';
export 'src/model/target.dart' show Target;
export 'src/validation.dart'
    show
        ValidationErrors,
        validateBuildConfig,
        validateBuildOutput,
        validateLinkConfig,
        validateLinkOutput;
