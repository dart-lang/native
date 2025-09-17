// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import { yaml } from "@codemirror/lang-yaml";
import { basicSetup, EditorView } from "codemirror";
import { createEffect, onMount } from "solid-js";
import { Box } from "styled-system/jsx";
import { $ffigenConfig } from "~/lib/ffigen-config";
import { $theme, editorThemeConfig } from "~/lib/theme";

/**
 * Codemirror editor used for editing ffigen config yaml file
 */
export const ConfigEditor = () => {
  let editorRef: HTMLDivElement;
  let editor: EditorView;

  const [ffigenConfig, setFfigenConfig] = $ffigenConfig;

  onMount(() => {
    editor = new EditorView({
      doc: ffigenConfig(),
      extensions: [
        basicSetup,
        yaml(),
        EditorView.domEventHandlers({
          // update the config when editor is not in focus to prevent frequent updates
          blur: (_, view) => {
            setFfigenConfig(view.state.doc.toString());
          },
        }),
        editorThemeConfig.of([$theme.editorTheme()]),
        EditorView.theme({
          "&": {
            height: "100%",
          },
        }),
      ],
      parent: editorRef!,
    });

    return () => {
      editor.destroy();
    };
  });

  createEffect(() => {
    if (editor) {
      editor.dispatch($theme.editorThemeTransaction());
    }
  });

  return <Box height="full" flexGrow={1} ref={editorRef} />;
};
