// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// A union that is declared but never defined.
union Blob;
typedef Blob BlobAlias;

class Widget {
 public:
  Widget();

  // Bindable: these must survive.
  int good() const;
  Widget* self();
  Blob* blobPtr();

  // A C++ reference has no Dart mapping.
  int& badRef();
  const Widget& badConstRef() const;

  // An incomplete compound returned by value, directly and via a typedef.
  Blob badUnionByValue();
  BlobAlias badAliasByValue();
};
