import { createSignal, For } from "solid-js";
import { $logs } from "~/lib/log";
import { Select } from "./ui/select";
import { Table } from "./ui/table";
import { TbSelector } from "solid-icons/tb";

/**
 * level and label pairs as defined by package:logging in dart
 */
const loggingLevels: [number, string][] = [
  [0, "ALL"],
  [3, "FINEST"],
  [4, "FINER"],
  [5, "FINE"],
  [7, "CONFIG"],
  [8, "INFO"],
  [9, "WARNING"],
  [10, "SEVERE"],
];

const levelLabelMap = new Map<number, string>(loggingLevels);

/**
 *Dropdown select to set filter for the logs displayed
 */
const LevelSelect = (props: {
  level: number;
  onLevelChange: (level: number) => void;
}) => {
  return (
    <Select.Root
      items={loggingLevels}
      size="sm"
      defaultValue={[props.level.toString()]}
      itemToValue={(item) => item[0].toString()}
      itemToString={(item) => item[1]}
      onValueChange={({ value }) => {
        props.onLevelChange(parseInt(value[0]));
      }}
    >
      <Select.Control>
        <Select.Trigger>
          <Select.ValueText placeholder="Level" />
          <TbSelector />
        </Select.Trigger>
      </Select.Control>
      <Select.Positioner>
        <Select.Content>
          <For each={loggingLevels}>
            {(item) => (
              <Select.Item item={item}>
                <Select.ItemText>{item[1]}</Select.ItemText>
              </Select.Item>
            )}
          </For>
        </Select.Content>
      </Select.Positioner>
    </Select.Root>
  );
};

const LogsViewer = () => {
  const [logs] = $logs;

  // set default log level to INFO
  const [levelFilter, setLevelFilter] = createSignal(8);
  const filteredLogs = () =>
    logs().filter(({ level }) => level >= levelFilter());

  return (
    <Table.Root size="sm">
      <Table.Head position="sticky" top="0" bg="bg.subtle">
        <Table.Row>
          <Table.Header>
            <LevelSelect level={levelFilter()} onLevelChange={setLevelFilter} />
          </Table.Header>
          <Table.Header>Message</Table.Header>
        </Table.Row>
      </Table.Head>
      <Table.Body>
        <For each={filteredLogs()}>
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

export default LogsViewer;
