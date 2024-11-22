// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/shared/referred_type.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/token_list.dart';
import '../../_core/utils.dart';
import '../parse_type.dart';

ReferredType parseTypeAfterSeparator(
  TokenList fragments,
  ParsedSymbolgraph symbolgraph,
) {
  // fragments = [..., ': ', type tokens...]
  final separatorIndex =
      fragments.indexWhere((token) => matchFragment(token, 'text', ': '));
  final (type, suffix) =
      parseType(symbolgraph, fragments.slice(separatorIndex + 1));
  assert(suffix.isEmpty, '$suffix');
  return type;
}
