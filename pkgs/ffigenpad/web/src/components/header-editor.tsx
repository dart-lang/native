import { cpp } from "@codemirror/lang-cpp";
import { basicSetup, EditorView } from "codemirror";
import { createEffect, onMount } from "solid-js";
import { Box } from "styled-system/jsx";
import { $filesystem, filePathSegments } from "~/lib/filesystem";

export const HeaderEditor = () => {
  let editorRef: HTMLDivElement;
  let editor: EditorView;

  const [selectedFile] = $filesystem.selectedFile;
  const [fileTree, setFileTree] = $filesystem.fileTree;
  const selectedFileContent = () =>
    filePathSegments(selectedFile()).reduce(
      (acc, current) => acc[current],
      fileTree["home/web_user"],
    );

  onMount(() => {
    editor = new EditorView({
      doc: selectedFileContent(),
      extensions: [
        basicSetup,
        cpp(),
        EditorView.updateListener.of((viewUpdate) => {
          if (viewUpdate.docChanged) {
            const content = viewUpdate.view.state.doc.toString();
            setFileTree(
              "home/web_user",
              ...(filePathSegments(selectedFile()) as []),
              content,
            );
          }
        }),
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

  return <Box height="full" flexGrow={1} ref={editorRef} />;
};
