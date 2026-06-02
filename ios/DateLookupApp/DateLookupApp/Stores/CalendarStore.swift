import Foundation

@MainActor
final class CalendarStore: ObservableObject {
    @Published var visibleMonth: Date
    @Published var selectedDate: Date
    @Published var selectedCategory: RecordCategory = .activity
    @Published private(set) var records: [CalendarRecord] = []
    @Published private(set) var stats: MonthStats = .empty
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let apiClient: APIClient

    init(apiClient: APIClient, today: Date = Date()) {
        self.apiClient = apiClient
        visibleMonth = today
        selectedDate = today
    }

    var monthKey: String {
        DateFormatter.monthKey.string(from: visibleMonth)
    }

    var selectedDateKey: String {
        DateFormatter.dayKey.string(from: selectedDate)
    }

    var recordsByDate: [String: [CalendarRecord]] {
        Dictionary(grouping: records, by: \.date)
    }

    var selectedRecords: [CalendarRecord] {
        recordsByDate[selectedDateKey] ?? []
    }

    func loadMonth() async {
        isLoading = true
        errorMessage = nil
        do {
            async let records = apiClient.fetchRecords(monthKey)
            async let stats = apiClient.fetchStats(monthKey)
            self.records = try await records
            self.stats = try await stats
        } catch {
            errorMessage = "加载失败，请确认后端服务已启动。"
        }
        isLoading = false
    }

    func select(_ date: Date) {
        selectedDate = date
        if !Calendar.current.isDate(date, equalTo: visibleMonth, toGranularity: .month) {
            visibleMonth = date
        }
    }

    func moveMonth(by value: Int) async {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: value, to: visibleMonth) else { return }
        visibleMonth = nextMonth
        selectedDate = nextMonth
        await loadMonth()
    }

    func jumpToToday() async {
        let today = Date()
        visibleMonth = today
        selectedDate = today
        await loadMonth()
    }

    func create(_ request: RecordRequest) async {
        do {
            _ = try await apiClient.createRecord(request)
            selectedCategory = request.category
            await loadMonth()
        } catch {
            errorMessage = "保存失败，请稍后重试。"
        }
    }

    func delete(_ record: CalendarRecord) async {
        do {
            try await apiClient.deleteRecord(record.id)
            await loadMonth()
        } catch {
            errorMessage = "删除失败，请稍后重试。"
        }
    }
}

