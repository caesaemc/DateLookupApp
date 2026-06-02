import XCTest
@testable import DateLookupApp

final class CalendarGridBuilderTests: XCTestCase {
    func testMonthGridIncludesWholeWeeks() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let month = try XCTUnwrap(formatter.date(from: "2026-06-02"))

        let days = CalendarGridBuilder.monthGrid(for: month)

        XCTAssertEqual(days.count, 35)
        XCTAssertEqual(formatter.string(from: try XCTUnwrap(days.first)), "2026-05-31")
        XCTAssertEqual(formatter.string(from: try XCTUnwrap(days.last)), "2026-07-04")
    }
}

