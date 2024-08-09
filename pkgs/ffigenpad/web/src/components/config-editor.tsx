import { Box } from "styled-system/jsx";
import { basicSetup, EditorView } from "codemirror";
import { onMount } from "solid-js";
import { yaml } from "@codemirror/lang-yaml";
import { useStore } from "@nanostores/solid";
import { $ffigenConfig } from "~/lib/ffigen-config";

export const ConfigEditor = () => {
  let editorRef: HTMLDivElement;
  let editor: EditorView;

  const ffigenConfig = useStore($ffigenConfig);

  onMount(() => {
    editor = new EditorView({
      doc: ffigenConfig(),
      extensions: [
        basicSetup,
        yaml(),
        EditorView.updateListener.of((viewUpdate) => {
          if (viewUpdate.docChanged) {
            $ffigenConfig.set(viewUpdate.view.state.doc.toString());
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
