import Foundation

struct MonthStats: Codable, Equatable {
    let month: String
    let activityDistanceKm: Double
    let activityCalories: Double
    let mealCalories: Double
    let expenseAmount: Double
    let recordDays: Int
    let categoryCounts: [RecordCategory: Int]

    init(
        month: String,
        activityDistanceKm: Double,
        activityCalories: Double,
        mealCalories: Double,
        expenseAmount: Double,
        recordDays: Int,
        categoryCounts: [RecordCategory: Int]
    ) {
        self.month = month
        self.activityDistanceKm = activityDistanceKm
        self.activityCalories = activityCalories
        self.mealCalories = mealCalories
        self.expenseAmount = expenseAmount
        self.recordDays = recordDays
        self.categoryCounts = categoryCounts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        month = try container.decode(String.self, forKey: .month)
        activityDistanceKm = try container.decode(Double.self, forKey: .activityDistanceKm)
        activityCalories = try container.decode(Double.self, forKey: .activityCalories)
        mealCalories = try container.decode(Double.self, forKey: .mealCalories)
        expenseAmount = try container.decode(Double.self, forKey: .expenseAmount)
        recordDays = try container.decode(Int.self, forKey: .recordDays)

        let rawCounts = try container.decode([String: Int].self, forKey: .categoryCounts)
        categoryCounts = Dictionary(uniqueKeysWithValues: RecordCategory.allCases.map { category in
            (category, rawCounts[category.rawValue] ?? 0)
        })
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(month, forKey: .month)
        try container.encode(activityDistanceKm, forKey: .activityDistanceKm)
        try container.encode(activityCalories, forKey: .activityCalories)
        try container.encode(mealCalories, forKey: .mealCalories)
        try container.encode(expenseAmount, forKey: .expenseAmount)
        try container.encode(recordDays, forKey: .recordDays)
        try container.encode(
            Dictionary(uniqueKeysWithValues: categoryCounts.map { ($0.key.rawValue, $0.value) }),
            forKey: .categoryCounts
        )
    }

    static let empty = MonthStats(
        month: DateFormatter.monthKey.string(from: Date()),
        activityDistanceKm: 0,
        activityCalories: 0,
        mealCalories: 0,
        expenseAmount: 0,
        recordDays: 0,
        categoryCounts: Dictionary(uniqueKeysWithValues: RecordCategory.allCases.map { ($0, 0) })
    )

    private enum CodingKeys: String, CodingKey {
        case month
        case activityDistanceKm
        case activityCalories
        case mealCalories
        case expenseAmount
        case recordDays
        case categoryCounts
    }
}
