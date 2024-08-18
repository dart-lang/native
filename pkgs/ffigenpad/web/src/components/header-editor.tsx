import { cpp } from "@codemirror/lang-cpp";
import { basicSetup, EditorView } from "codemirror";
import { createEffect, onMount } from "solid-js";
import { Box } from "styled-system/jsx";
import { $filesystem } from "~/lib/filesystem";
import { $theme, editorThemeConfig } from "~/lib/theme";

/**
 * Codemirror editor for header files, modifying the file that is currently selected
 */
export const HeaderEditor = () => {
  let editorRef: HTMLDivElement;
  let editor: EditorView;

  const [selectedFile] = $filesystem.selectedFile;

  /**
   * file content of the selected file read from MemFS
   */
  const selectedFileContent = () =>
    globalThis.FS.readFile(selectedFile(), { encoding: "utf8" });

  onMount(() => {
    editor = new EditorView({
      doc: selectedFileContent(),
      extensions: [
        basicSetup,
        cpp(),
        EditorView.domEventHandlers({
          // write to MemFS file on editor blur to prevent frequent updates
          blur: (_, view) => {
            globalThis.FS.writeFile(selectedFile(), view.state.doc.toString());
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
      // update the editor content whenever a new file is selected.
      editor.dispatch({
        changes: {
          from: 0,
          to: editor.state.doc.length,
          insert: selectedFileContent(),
        },
      });
    }
  });

  createEffect(() => {
    if (editor) editor.dispatch($theme.editorThemeTransaction());
  });

  return <Box height="full" flexGrow={1} ref={editorRef} />;
};
