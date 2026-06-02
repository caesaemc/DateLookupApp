export type RecordCategory = "activity" | "meal" | "expense" | "tip";

export type CalendarRecord = {
  id: string;
  category: RecordCategory;
  title: string;
  date: string;
  time: string;
  note: string;
  mood: string;
  details: Record<string, string | number | boolean | null>;
  createdAt: string;
  updatedAt: string;
};

export type RecordInput = Omit<CalendarRecord, "id" | "createdAt" | "updatedAt">;

export type MonthStats = {
  month: string;
  activityDistanceKm: number;
  activityCalories: number;
  mealCalories: number;
  expenseAmount: number;
  recordDays: number;
  categoryCounts: Record<RecordCategory, number>;
};
