import { cpp } from "@codemirror/lang-cpp";
import { basicSetup, EditorView } from "codemirror";
import { createEffect, onMount } from "solid-js";
import { Box } from "styled-system/jsx";
import { $filesystem } from "~/lib/filesystem";
import { $theme, editorThemeConfig, editorThemeTransaction } from "~/lib/theme";

export const HeaderEditor = () => {
  let editorRef: HTMLDivElement;
  let editor: EditorView;

  const [selectedFile] = $filesystem.selectedFile;

  const selectedFileContent = () =>
    globalThis.FS.readFile(selectedFile(), { encoding: "utf8" });

  onMount(() => {
    editor = new EditorView({
      doc: selectedFileContent(),
      extensions: [
        basicSetup,
        cpp(),
        EditorView.domEventHandlers({
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
    if (editor) editor.dispatch(editorThemeTransaction());
  });

  return <Box height="full" flexGrow={1} ref={editorRef} />;
};
