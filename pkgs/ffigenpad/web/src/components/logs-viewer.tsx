import { $logs } from "~/lib/log";
import { Table } from "./ui/table";
import { useStore } from "@nanostores/solid";
import { For } from "solid-js";
import { Box } from "styled-system/jsx";
import { Select } from "./ui/select";
import { atom, batched } from "nanostores";

const loggingLevels = [
  {
    label: "ALL",
    value: 0,
  },
  {
    label: "FINEST",
    value: 3,
  },
  {
    label: "FINER",
    value: 4,
  },
  {
    label: "FINE",
    value: 5,
  },
  {
    label: "CONFIG",
    value: 7,
  },
  {
    label: "INFO",
    value: 8,
  },
  {
    label: "WARNING",
    value: 9,
  },
  {
    label: "SEVERE",
    value: 10,
  },
];

const levelLabelMap = new Map<number, string>();
for (let level of loggingLevels) {
  levelLabelMap.set(level.value, level.label);
}

const $levelFilter = atom(0);

const LevelSelect = () => {
  const levelFilter = useStore($levelFilter);
  return (
    <Select.Root
      items={loggingLevels}
      size="sm"
      defaultValue={[levelFilter().toString()]}
      itemToValue={(item: any) => item.value.toString()}
      onValueChange={({ value }) => {
        $levelFilter.set(parseInt(value[0]));
      }}
    >
      <Select.Control>
        <Select.Trigger>
          <Select.ValueText placeholder="Level" />
        </Select.Trigger>
      </Select.Control>
      <Select.Positioner>
        <Select.Content>
          <For each={loggingLevels}>
            {(item) => (
              <Select.Item item={item}>
                <Select.ItemText>{item.label}</Select.ItemText>
              </Select.Item>
            )}
          </For>
        </Select.Content>
      </Select.Positioner>
    </Select.Root>
  );
};

const $filteredLogs = batched([$logs, $levelFilter], (logs, levelFilter) =>
  logs.filter(({ level }) => level >= levelFilter),
);

export const LogsViewer = () => {
  const logs = useStore($filteredLogs);

  return (
    <Table.Root size="sm">
      <Table.Head position="sticky" top="0" bg="bg.subtle">
        <Table.Row>
          <Table.Header>
            <LevelSelect />
          </Table.Header>
          <Table.Header>Message</Table.Header>
        </Table.Row>
      </Table.Head>
      <Table.Body>
        <For each={logs()}>
          {(log) => (
            <Table.Row textStyle="xs">
              <Table.Cell>{levelLabelMap.get(log.level)}</Table.Cell>
              <Table.Cell>{log.message}</Table.Cell>
            </Table.Row>
          )}
        </For>
      </Table.Body>
    </Table.Root>
  );
};
