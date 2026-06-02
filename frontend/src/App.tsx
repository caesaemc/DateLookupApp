import {
  Activity,
  CalendarDays,
  ChevronLeft,
  ChevronRight,
  CircleDollarSign,
  Lightbulb,
  Plus,
  Salad,
  Trash2
} from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { createRecord, deleteRecord, fetchRecords, fetchStats } from "./api";
import {
  format,
  isSameDay,
  isSameMonth,
  longDateTitle,
  monthGrid,
  monthTitle,
  nextMonth,
  parseDate,
  previousMonth,
  toISODate,
  toMonth
} from "./dateUtils";
import type { CalendarRecord, MonthStats, RecordCategory, RecordInput } from "./types";

const categoryMeta: Record<
  RecordCategory,
  { label: string; icon: typeof Activity; tone: string; empty: string }
> = {
  activity: { label: "运动", icon: Activity, tone: "green", empty: "记录一次身体状态" },
  meal: { label: "饮食", icon: Salad, tone: "orange", empty: "留下今天吃了什么" },
  expense: { label: "记账", icon: CircleDollarSign, tone: "blue", empty: "记一笔收入或支出" },
  tip: { label: "Tips", icon: Lightbulb, tone: "rose", empty: "写下今天的小提醒" }
};

const categories = Object.keys(categoryMeta) as RecordCategory[];

const defaultStats: MonthStats = {
  month: toMonth(new Date()),
  activityDistanceKm: 0,
  activityCalories: 0,
  mealCalories: 0,
  expenseAmount: 0,
  recordDays: 0,
  categoryCounts: { activity: 0, meal: 0, expense: 0, tip: 0 }
};

export function App() {
  const today = useMemo(() => new Date(), []);
  const [visibleMonth, setVisibleMonth] = useState(today);
  const [selectedDate, setSelectedDate] = useState(today);
  const [records, setRecords] = useState<CalendarRecord[]>([]);
  const [stats, setStats] = useState<MonthStats>(defaultStats);
  const [activeCategory, setActiveCategory] = useState<RecordCategory>("activity");
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState("");

  const month = toMonth(visibleMonth);
  const selectedDateKey = toISODate(selectedDate);

  async function loadMonth() {
    setIsLoading(true);
    setError("");
    try {
      const [nextRecords, nextStats] = await Promise.all([fetchRecords(month), fetchStats(month)]);
      setRecords(nextRecords);
      setStats(nextStats);
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : "加载失败");
    } finally {
      setIsLoading(false);
    }
  }

  useEffect(() => {
    void loadMonth();
  }, [month]);

  const recordsByDate = useMemo(() => {
    return records.reduce<Record<string, CalendarRecord[]>>((map, record) => {
      map[record.date] = [...(map[record.date] ?? []), record];
      return map;
    }, {});
  }, [records]);

  const selectedRecords = recordsByDate[selectedDateKey] ?? [];

  async function handleCreate(input: RecordInput) {
    await createRecord(input);
    await loadMonth();
    setActiveCategory(input.category);
  }

  async function handleDelete(id: string) {
    await deleteRecord(id);
    await loadMonth();
  }

  function shiftMonth(direction: "prev" | "next") {
    const next = direction === "prev" ? previousMonth(visibleMonth) : nextMonth(visibleMonth);
    setVisibleMonth(next);
    setSelectedDate(next);
  }

  return (
    <main className="app-shell">
      <section className="workspace">
        <header className="topbar">
          <div>
            <p className="app-name">清爽日历</p>
            <h1>记录生活，发现美好</h1>
          </div>
          <button className="today-button" onClick={() => {
            setVisibleMonth(today);
            setSelectedDate(today);
          }}>
            <CalendarDays size={17} />
            今天
          </button>
        </header>

        {error ? <div className="notice">{error}</div> : null}

        <div className="dashboard-grid">
          <section className="panel calendar-panel" aria-label="月视图日历">
            <div className="panel-heading month-heading">
              <button className="icon-button" aria-label="上个月" onClick={() => shiftMonth("prev")}>
                <ChevronLeft size={18} />
              </button>
              <h2>{monthTitle(visibleMonth)}</h2>
              <button className="icon-button" aria-label="下个月" onClick={() => shiftMonth("next")}>
                <ChevronRight size={18} />
              </button>
            </div>
            <CalendarGrid
              days={monthGrid(visibleMonth)}
              visibleMonth={visibleMonth}
              selectedDate={selectedDate}
              recordsByDate={recordsByDate}
              onSelect={setSelectedDate}
            />
          </section>

          <section className="panel day-panel" aria-label="每日记录详情">
            <div className="panel-heading">
              <div>
                <span className="muted">每日详情</span>
                <h2>{longDateTitle(selectedDate)}</h2>
              </div>
              <div className="date-strip">
                {[-2, -1, 0, 1, 2].map((offset) => {
                  const date = new Date(selectedDate);
                  date.setDate(date.getDate() + offset);
                  return (
                    <button
                      key={offset}
                      className={isSameDay(date, selectedDate) ? "date-dot active" : "date-dot"}
                      onClick={() => setSelectedDate(date)}
                    >
                      <span>{format(date, "d")}</span>
                    </button>
                  );
                })}
              </div>
            </div>

            <CategoryTabs value={activeCategory} onChange={setActiveCategory} />
            <RecordLane
              records={selectedRecords}
              activeCategory={activeCategory}
              onDelete={(id) => void handleDelete(id)}
            />
          </section>

          <aside className="side-stack">
            <RecordForm
              date={selectedDateKey}
              category={activeCategory}
              onCategoryChange={setActiveCategory}
              onCreate={(input) => void handleCreate(input)}
            />
            <StatsPanel stats={stats} isLoading={isLoading} />
          </aside>
        </div>
      </section>
    </main>
  );
}

function CalendarGrid({
  days,
  visibleMonth,
  selectedDate,
  recordsByDate,
  onSelect
}: {
  days: Date[];
  visibleMonth: Date;
  selectedDate: Date;
  recordsByDate: Record<string, CalendarRecord[]>;
  onSelect: (date: Date) => void;
}) {
  return (
    <div className="calendar-grid">
      {["日", "一", "二", "三", "四", "五", "六"].map((day) => (
        <div className="weekday" key={day}>{day}</div>
      ))}
      {days.map((day) => {
        const key = toISODate(day);
        const dayRecords = recordsByDate[key] ?? [];
        return (
          <button
            key={key}
            className={[
              "calendar-cell",
              isSameMonth(day, visibleMonth) ? "" : "outside",
              isSameDay(day, selectedDate) ? "selected" : ""
            ].join(" ")}
            onClick={() => onSelect(day)}
          >
            <span className="date-number">{format(day, "d")}</span>
            <span className="record-tags">
              {dayRecords.slice(0, 3).map((record) => (
                <span className={`mini-tag ${categoryMeta[record.category].tone}`} key={record.id}>
                  {summaryFor(record)}
                </span>
              ))}
            </span>
          </button>
        );
      })}
    </div>
  );
}

function CategoryTabs({ value, onChange }: { value: RecordCategory; onChange: (value: RecordCategory) => void }) {
  return (
    <div className="category-tabs" role="tablist" aria-label="记录类型">
      {categories.map((category) => {
        const Icon = categoryMeta[category].icon;
        return (
          <button
            key={category}
            className={value === category ? `tab active ${categoryMeta[category].tone}` : "tab"}
            onClick={() => onChange(category)}
          >
            <Icon size={17} />
            {categoryMeta[category].label}
          </button>
        );
      })}
    </div>
  );
}

function RecordLane({
  records,
  activeCategory,
  onDelete
}: {
  records: CalendarRecord[];
  activeCategory: RecordCategory;
  onDelete: (id: string) => void;
}) {
  const filtered = records.filter((record) => record.category === activeCategory);
  const visible = filtered.length > 0 ? filtered : records;

  if (visible.length === 0) {
    const Icon = categoryMeta[activeCategory].icon;
    return (
      <div className="empty-state">
        <Icon size={34} />
        <p>{categoryMeta[activeCategory].empty}</p>
      </div>
    );
  }

  return (
    <div className="record-lane">
      {visible.map((record) => {
        const Icon = categoryMeta[record.category].icon;
        return (
          <article className={`record-card ${categoryMeta[record.category].tone}`} key={record.id}>
            <div className="record-title-row">
              <span className="record-icon"><Icon size={18} /></span>
              <div>
                <h3>{record.title}</h3>
                <p>{record.time} · {categoryMeta[record.category].label}</p>
              </div>
              <button className="ghost-icon" aria-label="删除记录" onClick={() => onDelete(record.id)}>
                <Trash2 size={16} />
              </button>
            </div>
            <dl>
              {detailRows(record).map(([label, value]) => (
                <div key={label}>
                  <dt>{label}</dt>
                  <dd>{value}</dd>
                </div>
              ))}
            </dl>
            {record.note ? <p className="record-note">{record.note}</p> : null}
          </article>
        );
      })}
    </div>
  );
}

function RecordForm({
  date,
  category,
  onCategoryChange,
  onCreate
}: {
  date: string;
  category: RecordCategory;
  onCategoryChange: (value: RecordCategory) => void;
  onCreate: (input: RecordInput) => void;
}) {
  const [title, setTitle] = useState("晨跑");
  const [time, setTime] = useState("07:30");
  const [primaryValue, setPrimaryValue] = useState("5.0");
  const [secondaryValue, setSecondaryValue] = useState("320");
  const [mood, setMood] = useState("适中");
  const [note, setNote] = useState("今天状态很好。");

  useEffect(() => {
    const presets: Record<RecordCategory, [string, string, string, string]> = {
      activity: ["晨跑", "5.0", "320", "今天状态很好。"],
      meal: ["早餐", "360", "22", "清爽的一餐。"],
      expense: ["咖啡", "25", "餐饮", "记录一笔日常支出。"],
      tip: ["今日 Tips", "健康", "1", "睡前拉伸 10 分钟。"]
    };
    const [nextTitle, nextPrimary, nextSecondary, nextNote] = presets[category];
    setTitle(nextTitle);
    setPrimaryValue(nextPrimary);
    setSecondaryValue(nextSecondary);
    setNote(nextNote);
  }, [category]);

  function detailsForCategory(): RecordInput["details"] {
    if (category === "activity") {
      return { distanceKm: Number(primaryValue), calories: Number(secondaryValue), durationMinutes: 30 };
    }
    if (category === "meal") {
      return { calories: Number(primaryValue), protein: Number(secondaryValue) };
    }
    if (category === "expense") {
      return { amount: Number(primaryValue), category: secondaryValue };
    }
    return { tag: primaryValue, priority: Number(secondaryValue) };
  }

  return (
    <section className="panel form-panel" aria-label="新增记录">
      <div className="panel-heading">
        <div>
          <span className="muted">{date}</span>
          <h2>快速记录</h2>
        </div>
        <Plus size={19} />
      </div>
      <CategoryTabs value={category} onChange={onCategoryChange} />
      <form
        className="record-form"
        onSubmit={(event) => {
          event.preventDefault();
          onCreate({
            category,
            title,
            date,
            time,
            note,
            mood,
            details: detailsForCategory()
          });
        }}
      >
        <label>
          标题
          <input value={title} onChange={(event) => setTitle(event.target.value)} required />
        </label>
        <label>
          时间
          <input type="time" value={time} onChange={(event) => setTime(event.target.value)} required />
        </label>
        <div className="form-row">
          <label>
            {primaryLabel(category)}
            <input value={primaryValue} onChange={(event) => setPrimaryValue(event.target.value)} required />
          </label>
          <label>
            {secondaryLabel(category)}
            <input value={secondaryValue} onChange={(event) => setSecondaryValue(event.target.value)} required />
          </label>
        </div>
        <label>
          心情
          <select value={mood} onChange={(event) => setMood(event.target.value)}>
            <option>轻松</option>
            <option>适中</option>
            <option>较高</option>
            <option>愉快</option>
          </select>
        </label>
        <label>
          笔记
          <textarea value={note} onChange={(event) => setNote(event.target.value)} rows={3} />
        </label>
        <button className="primary-button" type="submit">保存记录</button>
      </form>
    </section>
  );
}

function StatsPanel({ stats, isLoading }: { stats: MonthStats; isLoading: boolean }) {
  const rings = [
    ["运动", stats.categoryCounts.activity, "green"],
    ["饮食", stats.categoryCounts.meal, "orange"],
    ["记账", stats.categoryCounts.expense, "blue"],
    ["Tips", stats.categoryCounts.tip, "rose"]
  ] as const;

  return (
    <section className="panel stats-panel" aria-label="月度统计">
      <div className="panel-heading">
        <div>
          <span className="muted">{stats.month}</span>
          <h2>月度趋势</h2>
        </div>
      </div>
      {isLoading ? <p className="muted">正在同步记录...</p> : null}
      <div className="stats-grid">
        <StatTile label="跑步距离" value={`${stats.activityDistanceKm.toFixed(1)} km`} />
        <StatTile label="总消耗" value={`${Math.round(stats.activityCalories)} kcal`} />
        <StatTile label="摄入热量" value={`${Math.round(stats.mealCalories)} kcal`} />
        <StatTile label="支出" value={`¥${stats.expenseAmount.toFixed(0)}`} />
      </div>
      <div className="ring-row">
        {rings.map(([label, value, tone]) => (
          <div className={`ring ${tone}`} key={label}>
            <strong>{value}</strong>
            <span>{label}</span>
          </div>
        ))}
      </div>
      <p className="monthly-copy">本月已记录 {stats.recordDays} 天，保持轻量但稳定的生活复盘。</p>
    </section>
  );
}

function StatTile({ label, value }: { label: string; value: string }) {
  return (
    <div className="stat-tile">
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

function summaryFor(record: CalendarRecord) {
  if (record.category === "activity") {
    return `跑步 ${Number(record.details.distanceKm ?? 0)}km`;
  }
  if (record.category === "meal") {
    return `${record.title} ${Number(record.details.calories ?? 0)}`;
  }
  if (record.category === "expense") {
    return `支出 ${Number(record.details.amount ?? 0)}`;
  }
  return record.title;
}

function detailRows(record: CalendarRecord): [string, string][] {
  if (record.category === "activity") {
    return [
      ["距离", `${Number(record.details.distanceKm ?? 0)} 公里`],
      ["消耗", `${Number(record.details.calories ?? 0)} kcal`],
      ["时长", `${Number(record.details.durationMinutes ?? 0)} 分钟`]
    ];
  }
  if (record.category === "meal") {
    return [
      ["热量", `${Number(record.details.calories ?? 0)} kcal`],
      ["蛋白质", `${Number(record.details.protein ?? 0)} g`]
    ];
  }
  if (record.category === "expense") {
    return [
      ["金额", `¥${Number(record.details.amount ?? 0).toFixed(2)}`],
      ["分类", String(record.details.category ?? "日常")]
    ];
  }
  return [["标签", String(record.details.tag ?? "Tips")]];
}

function primaryLabel(category: RecordCategory) {
  return {
    activity: "距离 km",
    meal: "热量 kcal",
    expense: "金额 ¥",
    tip: "标签"
  }[category];
}

function secondaryLabel(category: RecordCategory) {
  return {
    activity: "消耗 kcal",
    meal: "蛋白质 g",
    expense: "分类",
    tip: "优先级"
  }[category];
}
