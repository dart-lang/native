// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/* @refresh reload */
import { render } from 'solid-js/web'

import App from './App'

const root = document.getElementById('root')

render(() => <App />, root)
