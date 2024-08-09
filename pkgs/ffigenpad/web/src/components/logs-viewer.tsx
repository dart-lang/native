import { $logs } from "~/lib/log";
import { Table } from "./ui/table";
import { useStore } from "@nanostores/solid";
import { For } from "solid-js";
import { Box } from "styled-system/jsx";

export const LogsViewer = () => {
  const logs = useStore($logs);

  return (
    <Box overflow="auto" height="calc(100vh - 150px)">
      <Table.Root size="sm">
        <Table.Head position="sticky" top="0" bg="bg.subtle">
          <Table.Row>
            <Table.Header>Level</Table.Header>
            <Table.Header>Message</Table.Header>
          </Table.Row>
        </Table.Head>
        <Table.Body>
          <For each={logs()}>
            {(log) => (
              <Table.Row>
                <Table.Cell>{log.level}</Table.Cell>
                <Table.Cell>{log.message}</Table.Cell>
              </Table.Row>
            )}
          </For>
        </Table.Body>
      </Table.Root>
    </Box>
  );
};
