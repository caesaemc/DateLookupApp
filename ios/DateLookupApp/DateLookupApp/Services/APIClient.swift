import Foundation

struct APIClient {
    var fetchRecords: (_ month: String) async throws -> [CalendarRecord]
    var createRecord: (_ request: RecordRequest) async throws -> CalendarRecord
    var deleteRecord: (_ id: String) async throws -> Void
    var fetchStats: (_ month: String) async throws -> MonthStats

    static let defaultBaseURL = AppConfiguration.apiBaseURL

    static let live = APIClient(baseURL: defaultBaseURL)

    static let preview = APIClient(
        fetchRecords: { _ in SampleData.records },
        createRecord: { request in SampleData.record(from: request) },
        deleteRecord: { _ in },
        fetchStats: { _ in SampleData.stats }
    )

    init(
        fetchRecords: @escaping (_ month: String) async throws -> [CalendarRecord],
        createRecord: @escaping (_ request: RecordRequest) async throws -> CalendarRecord,
        deleteRecord: @escaping (_ id: String) async throws -> Void,
        fetchStats: @escaping (_ month: String) async throws -> MonthStats
    ) {
        self.fetchRecords = fetchRecords
        self.createRecord = createRecord
        self.deleteRecord = deleteRecord
        self.fetchStats = fetchStats
    }

    init(baseURL: URL, session: URLSession = .shared) {
        let transport = APITransport(baseURL: baseURL, session: session)
        fetchRecords = { month in
            let response: RecordsResponse = try await transport.request(path: "/api/records?month=\(month)")
            return response.records
        }
        createRecord = { request in
            let response: RecordResponse = try await transport.request(path: "/api/records", method: "POST", body: request)
            return response.record
        }
        deleteRecord = { id in
            try await transport.requestNoBody(path: "/api/records/\(id)", method: "DELETE")
        }
        fetchStats = { month in
            let response: StatsResponse = try await transport.request(path: "/api/stats?month=\(month)")
            return response.stats
        }
    }
}

private struct RecordsResponse: Decodable {
    let records: [CalendarRecord]
}

private struct RecordResponse: Decodable {
    let record: CalendarRecord
}

private struct StatsResponse: Decodable {
    let stats: MonthStats
}

private struct APITransport {
    let baseURL: URL
    let session: URLSession

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func request<Response: Decodable>(
        path: String,
        method: String = "GET"
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponentOrQuery(path))
        request.httpMethod = method
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        return try decoder.decode(Response.self, from: data)
    }

    func request<Response: Decodable, Body: Encodable>(
        path: String,
        method: String,
        body: Body
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponentOrQuery(path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        return try decoder.decode(Response.self, from: data)
    }

    func requestNoBody(path: String, method: String) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponentOrQuery(path))
        request.httpMethod = method
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
    }
}

enum APIError: Error {
    case invalidResponse
}

enum SampleData {
    static let today = DateFormatter.dayKey.string(from: Date())

    static let records: [CalendarRecord] = [
        CalendarRecord(
            id: "activity-1",
            category: .activity,
            title: "晨跑",
            date: today,
            time: "07:30",
            note: "状态轻松，配速稳定。",
            mood: "适中",
            details: ["distanceKm": .number(5.02), "durationMinutes": .number(30), "calories": .number(320)],
            createdAt: "2026-06-02T06:37:02Z",
            updatedAt: "2026-06-02T06:37:02Z"
        ),
        CalendarRecord(
            id: "meal-1",
            category: .meal,
            title: "早餐",
            date: today,
            time: "08:25",
            note: "燕麦、鸡蛋和水果。",
            mood: "轻松",
            details: ["calories": .number(360), "protein": .number(22)],
            createdAt: "2026-06-02T06:37:02Z",
            updatedAt: "2026-06-02T06:37:02Z"
        )
    ]

    static let stats = MonthStats(
        month: DateFormatter.monthKey.string(from: Date()),
        activityDistanceKm: 5.02,
        activityCalories: 320,
        mealCalories: 360,
        expenseAmount: 25,
        recordDays: 1,
        categoryCounts: [.activity: 1, .meal: 1, .expense: 1, .tip: 1]
    )

    static func record(from request: RecordRequest) -> CalendarRecord {
        CalendarRecord(
            id: UUID().uuidString,
            category: request.category,
            title: request.title,
            date: request.date,
            time: request.time,
            note: request.note,
            mood: request.mood,
            details: request.details,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
    }
}

private extension URL {
    func appendingPathComponentOrQuery(_ value: String) -> URL {
        URL(string: value, relativeTo: self)!.absoluteURL
    }
}
