import { atom } from "nanostores";

export interface LogEntry {
  level: number;
  message: string;
}

export const $logs = atom<LogEntry[]>([]);
