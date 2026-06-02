import type { CalendarRecord, MonthStats, RecordInput } from "./types";

async function request<T>(url: string, options?: RequestInit): Promise<T> {
  const response = await fetch(url, {
    headers: { "Content-Type": "application/json" },
    ...options
  });

  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new Error(body.error ? JSON.stringify(body.error) : `Request failed: ${response.status}`);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
}

export async function fetchRecords(month: string) {
  const data = await request<{ records: CalendarRecord[] }>(`/api/records?month=${month}`);
  return data.records;
}

export async function createRecord(input: RecordInput) {
  const data = await request<{ record: CalendarRecord }>("/api/records", {
    method: "POST",
    body: JSON.stringify(input)
  });
  return data.record;
}

export async function deleteRecord(id: string) {
  await request<void>(`/api/records/${id}`, { method: "DELETE" });
}

export async function fetchStats(month: string) {
  const data = await request<{ stats: MonthStats }>(`/api/stats?month=${month}`);
  return data.stats;
}
