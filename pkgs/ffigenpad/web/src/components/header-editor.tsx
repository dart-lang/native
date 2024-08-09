import { cpp } from "@codemirror/lang-cpp";
import { useStore } from "@nanostores/solid";
import { basicSetup, EditorView } from "codemirror";
import { onMount } from "solid-js";
import { Box } from "styled-system/jsx";
import { $headers } from "~/lib/headers";

export const HeaderEditor = () => {
  let editorRef: HTMLDivElement;
  let editor: EditorView;

  const headers = useStore($headers);
  onMount(() => {
    editor = new EditorView({
      doc: headers(),
      extensions: [
        basicSetup,
        cpp(),
        EditorView.updateListener.of((viewUpdate) => {
          if (viewUpdate.docChanged) {
            $headers.set(viewUpdate.view.state.doc.toString());
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
  return <Box ref={editorRef} />;
};
