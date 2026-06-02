import XCTest
@testable import DateLookupApp

final class MonthStatsDecodingTests: XCTestCase {
    func testDecodesCategoryCountsFromBackendObject() throws {
        let data = """
        {
          "month": "2026-06",
          "activityDistanceKm": 5.02,
          "activityCalories": 320,
          "mealCalories": 360,
          "expenseAmount": 25,
          "recordDays": 1,
          "categoryCounts": {
            "activity": 1,
            "meal": 2,
            "expense": 3,
            "tip": 4
          }
        }
        """.data(using: .utf8)!

        let stats = try JSONDecoder().decode(MonthStats.self, from: data)

        XCTAssertEqual(stats.categoryCounts[.activity], 1)
        XCTAssertEqual(stats.categoryCounts[.meal], 2)
        XCTAssertEqual(stats.categoryCounts[.expense], 3)
        XCTAssertEqual(stats.categoryCounts[.tip], 4)
    }
}

