import request from "supertest";
import { describe, expect, it } from "vitest";
import { createApp } from "./app.js";
import { openDatabase } from "./database.js";

function testApp() {
  return createApp(openDatabase(":memory:"));
}

describe("records API", () => {
  it("creates and lists records by date", async () => {
    const app = testApp();

    const created = await request(app)
      .post("/api/records")
      .send({
        category: "activity",
        title: "晨跑",
        date: "2026-06-02",
        time: "07:30",
        note: "跑步很舒服",
        mood: "适中",
        details: { distanceKm: 5.02, calories: 320 }
      })
      .expect(201);

    expect(created.body.record.id).toBeTruthy();

    const listed = await request(app).get("/api/records?date=2026-06-02").expect(200);
    expect(listed.body.records).toHaveLength(1);
    expect(listed.body.records[0].title).toBe("晨跑");
  });

  it("aggregates monthly stats", async () => {
    const app = testApp();

    await request(app).post("/api/records").send({
      category: "meal",
      title: "早餐",
      date: "2026-06-02",
      time: "08:10",
      details: { calories: 360 }
    });
    await request(app).post("/api/records").send({
      category: "expense",
      title: "午餐",
      date: "2026-06-02",
      time: "12:10",
      details: { amount: 48 }
    });

    const stats = await request(app).get("/api/stats?month=2026-06").expect(200);
    expect(stats.body.stats.mealCalories).toBe(360);
    expect(stats.body.stats.expenseAmount).toBe(48);
    expect(stats.body.stats.recordDays).toBe(1);
  });
});
