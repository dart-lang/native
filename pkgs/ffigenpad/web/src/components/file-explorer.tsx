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

const data = {
  label: "Root",
  children: [
    {
      name: "home/web_user",
      children: [
        {
          name: "a.h",
        },
        {
          name: "clang-c",
          children: [
            {
              name: "b.h",
            },
            {
              name: "a.h",
            },
          ],
        },
      ],
    },
  ],
};

interface Child {
  name: string;
  children?: Child[];
}

const FileTree = () => {
  const renderChild = (child: Child, parent: string) => (
    <Show
      when={child.children}
      fallback={
        <Editable.Root activationMode="dblclick" defaultValue={child.name}>
          <HStack justify="space-between">
            <StyledTreeView.Item value={`${parent}/${child.name}`}>
              <Editable.Area>
                <Editable.Input />
                <StyledTreeView.ItemText>
                  <Editable.Preview />
                </StyledTreeView.ItemText>
              </Editable.Area>
            </StyledTreeView.Item>

            <IconButton size="xs" variant="ghost">
              <TbTrash />
            </IconButton>
          </HStack>
        </Editable.Root>
      }
    >
      <StyledTreeView.Branch value={`${parent}/${child.name}`}>
        <Editable.Root activationMode="dblclick" value={child.name}>
          <HStack justify="space-between">
            <StyledTreeView.BranchControl>
              <StyledTreeView.BranchIndicator>
                <TbChevronRight />
              </StyledTreeView.BranchIndicator>
              <Editable.Area>
                <Editable.Input />
                <StyledTreeView.BranchText>
                  <Editable.Preview />
                </StyledTreeView.BranchText>
              </Editable.Area>
            </StyledTreeView.BranchControl>
            <HStack gap="0">
              <IconButton size="xs" variant="ghost">
                <TbFilePlus />
              </IconButton>
              <IconButton size="xs" variant="ghost">
                <TbFolderPlus />
              </IconButton>
              <IconButton size="xs" variant="ghost">
                <TbTrash />
              </IconButton>
            </HStack>
          </HStack>
        </Editable.Root>
        <StyledTreeView.BranchContent>
          <For each={child.children}>
            {(c) => renderChild(c, `${parent}/${child.name}`)}
          </For>
        </StyledTreeView.BranchContent>
      </StyledTreeView.Branch>
    </Show>
  );

  return (
    <StyledTreeView.Root
      aria-label={data.label}
      defaultExpandedValue={["/home/web_user"]}
      onSelectionChange={console.log}
    >
      <StyledTreeView.Tree>
        <For each={data.children}>{(c) => renderChild(c, "")}</For>
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
