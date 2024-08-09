import { TbFileDots } from "solid-icons/tb";
import { Drawer } from "./ui/drawer";
import { IconButton } from "./ui/icon-button";
import { TreeView } from "./ui/tree-view";

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

export const FileTree = () => {
  return <TreeView data={data} />;
};

export const FileExplorer = () => {
  return (
    <Drawer.Root variant="left">
      <Drawer.Trigger
        asChild={(triggerProps) => (
          <IconButton {...triggerProps()}>
            <TbFileDots />
          </IconButton>
        )}
      />
      <Drawer.Positioner>
        <Drawer.Content>
          <Drawer.Body>
            <FileTree />
          </Drawer.Body>
        </Drawer.Content>
      </Drawer.Positioner>
    </Drawer.Root>
  );
};
