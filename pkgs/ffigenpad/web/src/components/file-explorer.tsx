import {
  TbChevronRight,
  TbFileDots,
  TbFilePlus,
  TbFolderPlus,
  TbTrash,
} from "solid-icons/tb";
import { For, Show } from "solid-js";
import { HStack } from "styled-system/jsx";
import { Drawer } from "./ui/drawer";
import { Editable } from "./ui/editable";
import { IconButton } from "./ui/icon-button";
import * as StyledTreeView from "./ui/styled/tree-view";
import { treeView } from "styled-system/recipes";
import { produce } from "solid-js/store";
import { $fileTree, type FSNode } from "~/lib/filesystem";

// need to include recipie for some reason
treeView();

const FileTree = () => {
  const [fileTree, setFileTree] = $fileTree;
  function addFile(parentPath: string) {
    const parts = parentPath.split("/").slice(3);

    const parentContents: FSNode = parts.reduce(
      (acc, current) => acc[current],
      fileTree["home/web_user"],
    );

    let i = 1;
    while (`file${i}.h` in parentContents) {
      i++;
    }
    setFileTree("home/web_user", ...(parts as []), {
      [`file${i}.h`]: "",
    });
  }

  function addFolder(parentPath: string) {
    const parts = parentPath.split("/").slice(3);

    const parentContents: FSNode = parts.reduce(
      (acc, current) => acc[current],
      fileTree["home/web_user"],
    );

    let i = 1;
    while (`folder${i}` in parentContents) {
      i++;
    }

    setFileTree("home/web_user", ...(parts as []), {
      [`folder${i}`]: {},
    });
  }

  function deleteEntity(entityPath: string) {
    const parts = entityPath.split("/").slice(3);
    setFileTree("home/web_user", ...(parts as []), undefined);
  }

  function renameEntity(entityPath: string, newName: string) {
    const parts = entityPath.split("/").slice(3);
    const oldName = parts.at(-1);
    setFileTree(
      "home/web_user",
      ...(parts.slice(0, -1) as []),
      produce((parent) => {
        parent[newName] = parent[oldName];
        parent[oldName] = undefined;
      }),
    );
  }

  const renderChild = (child: [string, FSNode | string], parent: string) => {
    const entityPath = `${parent}/${child[0]}`;
    return (
      <Show
        when={typeof child[1] !== "string"}
        fallback={
          <HStack justify="space-between">
            <StyledTreeView.Item value={entityPath}>
              <Editable.Root
                activationMode="dblclick"
                value={child[0]}
                onValueCommit={({ value }) => renameEntity(entityPath, value)}
              >
                <Editable.Area>
                  <Editable.Input />
                  <StyledTreeView.ItemText>
                    <Editable.Preview />
                  </StyledTreeView.ItemText>
                </Editable.Area>
              </Editable.Root>
            </StyledTreeView.Item>

            <IconButton
              size="xs"
              variant="ghost"
              onClick={() => deleteEntity(entityPath)}
            >
              <TbTrash />
            </IconButton>
          </HStack>
        }
      >
        <StyledTreeView.Branch value={entityPath}>
          <HStack justify="space-between">
            <StyledTreeView.BranchControl>
              <StyledTreeView.BranchIndicator>
                <TbChevronRight />
              </StyledTreeView.BranchIndicator>
              <Editable.Root
                activationMode="dblclick"
                value={child[0]}
                onValueCommit={({ value }) => renameEntity(entityPath, value)}
              >
                <Editable.Area>
                  <Editable.Input />
                  <StyledTreeView.BranchText>
                    <Editable.Preview />
                  </StyledTreeView.BranchText>
                </Editable.Area>
              </Editable.Root>
            </StyledTreeView.BranchControl>
            <HStack gap="0">
              <IconButton
                size="xs"
                variant="ghost"
                onClick={() => addFile(entityPath)}
              >
                <TbFilePlus />
              </IconButton>
              <IconButton
                size="xs"
                variant="ghost"
                onClick={() => addFolder(entityPath)}
              >
                <TbFolderPlus />
              </IconButton>
              <IconButton
                size="xs"
                variant="ghost"
                onClick={() => deleteEntity(entityPath)}
              >
                <TbTrash />
              </IconButton>
            </HStack>
          </HStack>
          <StyledTreeView.BranchContent>
            <For each={Object.entries(child[1])}>
              {(c) => renderChild(c, entityPath)}
            </For>
          </StyledTreeView.BranchContent>
        </StyledTreeView.Branch>
      </Show>
    );
  };

  return (
    <StyledTreeView.Root
      aria-label="FileSystem"
      defaultExpandedValue={["/home/web_user"]}
    >
      <StyledTreeView.Tree>
        <For each={Object.entries(fileTree)}>{(c) => renderChild(c, "")}</For>
      </StyledTreeView.Tree>
    </StyledTreeView.Root>
  );
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
          <Drawer.Header>
            <Drawer.Title>FileSystem</Drawer.Title>
            <Drawer.Description>Tip: double click to rename</Drawer.Description>
          </Drawer.Header>
          <Drawer.Body>
            <FileTree />
          </Drawer.Body>
        </Drawer.Content>
      </Drawer.Positioner>
    </Drawer.Root>
  );
};
