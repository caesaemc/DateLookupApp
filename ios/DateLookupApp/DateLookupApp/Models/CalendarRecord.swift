import Foundation

struct CalendarRecord: Identifiable, Codable, Equatable {
    let id: String
    let category: RecordCategory
    let title: String
    let date: String
    let time: String
    let note: String
    let mood: String
    let details: [String: JSONValue]
    let createdAt: String
    let updatedAt: String

    var summary: String {
        switch category {
        case .activity:
            return "跑步 \(details.double("distanceKm").trimmed)km"
        case .meal:
            return "\(title) \(Int(details.double("calories")))"
        case .expense:
            return "支出 \(Int(details.double("amount")))"
        case .tip:
            return title
        }
    }

    var detailRows: [(String, String)] {
        switch category {
        case .activity:
            return [
                ("距离", "\(details.double("distanceKm").trimmed) 公里"),
                ("消耗", "\(Int(details.double("calories"))) kcal"),
                ("时长", "\(Int(details.double("durationMinutes"))) 分钟")
            ]
        case .meal:
            return [
                ("热量", "\(Int(details.double("calories"))) kcal"),
                ("蛋白质", "\(Int(details.double("protein"))) g")
            ]
        case .expense:
            return [
                ("金额", "¥\(details.double("amount").money)"),
                ("分类", details.string("category", fallback: "日常"))
            ]
        case .tip:
            return [
                ("标签", details.string("tag", fallback: "Tips"))
            ]
        }
    }
}

struct RecordRequest: Encodable {
    let category: RecordCategory
    let title: String
    let date: String
    let time: String
    let note: String
    let mood: String
    let details: [String: JSONValue]
}

enum JSONValue: Codable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else {
            self = .string(try container.decode(String.self))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
}

extension Dictionary where Key == String, Value == JSONValue {
    func double(_ key: String) -> Double {
        guard let value = self[key] else { return 0 }
        switch value {
        case .number(let number): return number
        case .string(let string): return Double(string) ?? 0
        case .bool, .null: return 0
        }
    }

    func string(_ key: String, fallback: String = "") -> String {
        guard let value = self[key] else { return fallback }
        switch value {
        case .string(let string): return string
        case .number(let number): return number.trimmed
        case .bool(let bool): return bool ? "true" : "false"
        case .null: return fallback
        }
    }
}

private extension Double {
    var trimmed: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(format: "%.2f", self)
    }

    var money: String {
        String(format: "%.2f", self)
    }
}

