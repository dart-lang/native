import { cpp } from "@codemirror/lang-cpp";
import { useStore } from "@nanostores/solid";
import { basicSetup, EditorView } from "codemirror";
import { onMount } from "solid-js";
import { Box, Flex, Grid, HStack } from "styled-system/jsx";
import { $headers } from "~/lib/headers";
import { TreeView } from "./ui/tree-view";

const FileTree = () => {
  const data = {
    label: "Root",
    children: [
      {
        value: "1",
        name: "Item 1",
        children: [
          {
            value: "1.1",
            name: "Item 1.1",
          },
          {
            value: "1.2",
            name: "Item 1.2",
            children: [
              {
                value: "1.2.1",
                name: "Item 1.2.1",
              },
              {
                value: "1.2.2",
                name: "Item 1.2.2",
              },
            ],
          },
        ],
      },
      {
        value: "2",
        name: "Item 2",
        children: [
          {
            value: "2.1",
            name: "Item 2.1",
          },
          {
            value: "2.2",
            name: "Item 2.2",
          },
        ],
      },
      {
        value: "3",
        name: "Item 3",
      },
    ],
  };

  return <TreeView flexGrow={0} width="unset" data={data} />;
};

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
  return <Box height="full" flexGrow={1} ref={editorRef} />;
};
