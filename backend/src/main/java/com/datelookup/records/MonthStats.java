package com.datelookup.records;

import java.util.Map;

public record MonthStats(
    String month,
    double activityDistanceKm,
    double activityCalories,
    double mealCalories,
    double expenseAmount,
    int recordDays,
    Map<RecordCategory, Integer> categoryCounts) {
}
