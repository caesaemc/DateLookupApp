import {
  addMonths,
  eachDayOfInterval,
  endOfMonth,
  endOfWeek,
  format,
  isSameDay,
  isSameMonth,
  parseISO,
  startOfMonth,
  startOfWeek,
  subMonths
} from "date-fns";
import { zhCN } from "date-fns/locale";

export function toISODate(date: Date) {
  return format(date, "yyyy-MM-dd");
}

export function toMonth(date: Date) {
  return format(date, "yyyy-MM");
}

export function monthTitle(date: Date) {
  return format(date, "yyyy年M月", { locale: zhCN });
}

export function longDateTitle(date: Date) {
  return format(date, "M月d日 EEEE", { locale: zhCN });
}

export function monthGrid(date: Date) {
  const start = startOfWeek(startOfMonth(date), { weekStartsOn: 0 });
  const end = endOfWeek(endOfMonth(date), { weekStartsOn: 0 });
  return eachDayOfInterval({ start, end });
}

export function previousMonth(date: Date) {
  return subMonths(date, 1);
}

export function nextMonth(date: Date) {
  return addMonths(date, 1);
}

export function parseDate(value: string) {
  return parseISO(value);
}

export { format, isSameDay, isSameMonth };
