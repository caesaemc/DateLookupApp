import XCTest
@testable import DateLookupApp

final class RecordSummaryTests: XCTestCase {
    func testActivitySummaryUsesDistance() {
        let record = CalendarRecord(
            id: "1",
            category: .activity,
            title: "晨跑",
            date: "2026-06-02",
            time: "07:30",
            note: "",
            mood: "适中",
            details: ["distanceKm": .number(5.02), "calories": .number(320), "durationMinutes": .number(30)],
            createdAt: "2026-06-02T00:00:00Z",
            updatedAt: "2026-06-02T00:00:00Z"
        )

        XCTAssertEqual(record.summary, "跑步 5.02km")
        XCTAssertEqual(record.detailRows[0].1, "5.02 公里")
    }
}

