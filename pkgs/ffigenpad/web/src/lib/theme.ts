// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import { Compartment } from "@codemirror/state";
import { oneDark } from "@codemirror/theme-one-dark";
import { EditorView } from "codemirror";
import { createEffect, createMemo, createRoot, createSignal } from "solid-js";

const editorLightTheme = EditorView.baseTheme({});
const editorDarkTheme = oneDark;

export const editorThemeConfig = new Compartment();

const themeSignal = () => {
  const darkMode = createSignal(
    window.matchMedia("(prefers-color-scheme: dark)").matches,
  );
  const editorTheme = createMemo(() =>
    darkMode[0]() ? editorDarkTheme : editorLightTheme,
  );

  createEffect(() => {
    if (darkMode[0]()) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
  });

  const editorThemeTransaction = createMemo(() => ({
    effects: editorThemeConfig.reconfigure([editorTheme()]),
  }));

  return { darkMode, editorTheme, editorThemeTransaction };
};

export const $theme = createRoot(themeSignal);
