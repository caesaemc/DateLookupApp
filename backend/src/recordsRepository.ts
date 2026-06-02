import { randomUUID } from "node:crypto";
import type { AppDatabase } from "./database.js";
import {
  assertMonth,
  type CalendarRecord,
  monthFromDate,
  type MonthStats,
  type RecordInput,
  recordCategories
} from "./domain.js";

type RecordRow = {
  id: string;
  category: CalendarRecord["category"];
  title: string;
  date: string;
  time: string;
  note: string;
  mood: string;
  details: string;
  created_at: string;
  updated_at: string;
};

function toRecord(row: RecordRow): CalendarRecord {
  return {
    id: row.id,
    category: row.category,
    title: row.title,
    date: row.date,
    time: row.time,
    note: row.note,
    mood: row.mood,
    details: JSON.parse(row.details),
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

export class RecordsRepository {
  constructor(private readonly db: AppDatabase) {}

  list(filters: { month?: string; date?: string } = {}) {
    if (filters.date) {
      const rows = this.db
        .prepare("SELECT * FROM records WHERE date = ? ORDER BY time ASC, created_at ASC")
        .all(filters.date) as RecordRow[];
      return rows.map(toRecord);
    }

    if (filters.month) {
      assertMonth(filters.month);
      const rows = this.db
        .prepare("SELECT * FROM records WHERE substr(date, 1, 7) = ? ORDER BY date ASC, time ASC")
        .all(filters.month) as RecordRow[];
      return rows.map(toRecord);
    }

    const rows = this.db
      .prepare("SELECT * FROM records ORDER BY date DESC, time DESC LIMIT 200")
      .all() as RecordRow[];
    return rows.map(toRecord);
  }

  create(input: RecordInput) {
    const now = new Date().toISOString();
    const record: CalendarRecord = {
      id: randomUUID(),
      ...input,
      createdAt: now,
      updatedAt: now
    };

    this.db
      .prepare(
        `INSERT INTO records
          (id, category, title, date, time, note, mood, details, created_at, updated_at)
         VALUES
          (@id, @category, @title, @date, @time, @note, @mood, @details, @createdAt, @updatedAt)`
      )
      .run({ ...record, details: JSON.stringify(record.details) });

    return record;
  }

  update(id: string, input: RecordInput) {
    const existing = this.find(id);
    if (!existing) {
      return null;
    }

    const updated: CalendarRecord = {
      id,
      ...input,
      createdAt: existing.createdAt,
      updatedAt: new Date().toISOString()
    };

    this.db
      .prepare(
        `UPDATE records SET
          category = @category,
          title = @title,
          date = @date,
          time = @time,
          note = @note,
          mood = @mood,
          details = @details,
          updated_at = @updatedAt
         WHERE id = @id`
      )
      .run({ ...updated, details: JSON.stringify(updated.details) });

    return updated;
  }

  delete(id: string) {
    return this.db.prepare("DELETE FROM records WHERE id = ?").run(id).changes > 0;
  }

  find(id: string) {
    const row = this.db.prepare("SELECT * FROM records WHERE id = ?").get(id) as RecordRow | undefined;
    return row ? toRecord(row) : null;
  }

  stats(month: string): MonthStats {
    assertMonth(month);
    const records = this.list({ month });
    const categoryCounts = Object.fromEntries(recordCategories.map((category) => [category, 0])) as MonthStats["categoryCounts"];
    const days = new Set<string>();

    const base = records.reduce(
      (acc, record) => {
        days.add(record.date);
        categoryCounts[record.category] += 1;

        if (record.category === "activity") {
          acc.activityDistanceKm += Number(record.details.distanceKm ?? 0);
          acc.activityCalories += Number(record.details.calories ?? 0);
        }
        if (record.category === "meal") {
          acc.mealCalories += Number(record.details.calories ?? 0);
        }
        if (record.category === "expense") {
          acc.expenseAmount += Number(record.details.amount ?? 0);
        }
        return acc;
      },
      {
        activityDistanceKm: 0,
        activityCalories: 0,
        mealCalories: 0,
        expenseAmount: 0
      }
    );

    return {
      month,
      ...base,
      recordDays: days.size,
      categoryCounts
    };
  }

  seedIfEmpty() {
    const count = this.db.prepare("SELECT COUNT(*) as count FROM records").get() as { count: number };
    if (count.count > 0) {
      return;
    }

    const today = new Date();
    const month = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, "0")}`;
    const day = String(today.getDate()).padStart(2, "0");
    const date = `${month}-${day}`;

    const seedRecords: RecordInput[] = [
      {
        category: "activity",
        title: "晨跑",
        date,
        time: "07:30",
        note: "状态轻松，配速稳定。",
        mood: "适中",
        details: { distanceKm: 5.02, durationMinutes: 30, calories: 320, intensity: "适中" }
      },
      {
        category: "meal",
        title: "早餐",
        date,
        time: "08:25",
        note: "燕麦、鸡蛋和水果。",
        mood: "轻松",
        details: { calories: 360, protein: 22, carbs: 45, fat: 10 }
      },
      {
        category: "expense",
        title: "咖啡",
        date,
        time: "12:30",
        note: "午后提神。",
        mood: "",
        details: { amount: 25, category: "餐饮" }
      },
      {
        category: "tip",
        title: "今日 Tips",
        date,
        time: "21:30",
        note: "晚间拉伸 10 分钟，明天继续保持。",
        mood: "愉快",
        details: { tag: "健康" }
      }
    ];

    seedRecords.forEach((record) => this.create(record));
  }
}

export { monthFromDate };
