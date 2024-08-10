import { createRoot, createSignal } from "solid-js";

export interface LogEntry {
  level: number;
  message: string;
}

const logsSignal = () => createSignal<LogEntry[]>([]);

export const $logs = createRoot(logsSignal);
