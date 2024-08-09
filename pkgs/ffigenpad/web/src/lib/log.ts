import { atom } from "nanostores";

export interface LogEntry {
  level: string;
  message: string;
}

export const $logs = atom<LogEntry[]>([]);
