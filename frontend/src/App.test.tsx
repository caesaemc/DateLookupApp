import { render, screen, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { App } from "./App";

describe("App", () => {
  beforeEach(() => {
    vi.stubGlobal(
      "fetch",
      vi.fn((url: string) => {
        if (url.startsWith("/api/records")) {
          return Promise.resolve({
            ok: true,
            status: 200,
            json: () => Promise.resolve({ records: [] })
          });
        }
        return Promise.resolve({
          ok: true,
          status: 200,
          json: () =>
            Promise.resolve({
              stats: {
                month: "2026-06",
                activityDistanceKm: 0,
                activityCalories: 0,
                mealCalories: 0,
                expenseAmount: 0,
                recordDays: 0,
                categoryCounts: { activity: 0, meal: 0, expense: 0, tip: 0 }
              }
            })
        });
      })
    );
  });

  it("renders the MVP calendar workspace", async () => {
    render(<App />);

    expect(screen.getByText("清爽日历")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "今天" })).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByText("快速记录")).toBeInTheDocument();
      expect(screen.getByText("月度趋势")).toBeInTheDocument();
    });
  });
});
