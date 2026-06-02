import { z } from "zod";

export const recordCategories = ["activity", "meal", "expense", "tip"] as const;

export const recordSchema = z.object({
  category: z.enum(recordCategories),
  title: z.string().min(1).max(80),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  time: z.string().regex(/^\d{2}:\d{2}$/),
  note: z.string().max(500).optional().default(""),
  mood: z.string().max(20).optional().default(""),
  details: z.record(z.string(), z.union([z.string(), z.number(), z.boolean(), z.null()])).default({})
});

export type RecordInput = z.infer<typeof recordSchema>;

export type CalendarRecord = RecordInput & {
  id: string;
  createdAt: string;
  updatedAt: string;
};

export type MonthStats = {
  month: string;
  activityDistanceKm: number;
  activityCalories: number;
  mealCalories: number;
  expenseAmount: number;
  recordDays: number;
  categoryCounts: Record<(typeof recordCategories)[number], number>;
};

export function assertMonth(month: string) {
  if (!/^\d{4}-\d{2}$/.test(month)) {
    throw new Error("month must use YYYY-MM format");
  }
}

export function monthFromDate(date: string) {
  return date.slice(0, 7);
}
