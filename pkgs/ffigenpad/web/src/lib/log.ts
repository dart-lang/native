import { atom, onMount } from "nanostores";

export interface LogEntry {
  level: string;
  message: string;
}

export const $logs = atom<LogEntry[]>([]);

onMount($logs, () => {
  (globalThis as any).addLog = (
    level: LogEntry["level"],
    message: LogEntry["message"],
  ) => {
    $logs.set([...$logs.get(), { level, message }]);
  };
});
