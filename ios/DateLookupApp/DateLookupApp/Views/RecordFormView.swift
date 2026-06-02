import SwiftUI
import UIKit

struct RecordFormView: View {
    @EnvironmentObject private var store: CalendarStore
    @State private var title = "晨跑"
    @State private var time = "07:30"
    @State private var primaryValue = "5.0"
    @State private var secondaryValue = "320"
    @State private var mood = "适中"
    @State private var note = "今天状态很好。"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.selectedDateKey)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appMuted)
                    Text("快速记录")
                        .font(.title3.bold())
                }
                Spacer()
                Image(systemName: "plus")
                    .font(.headline)
            }

            CategoryPicker(selection: $store.selectedCategory)

            VStack(spacing: 12) {
                LabeledField(title: "标题", text: $title)
                LabeledField(title: "时间", text: $time, keyboard: .numbersAndPunctuation)

                HStack(spacing: 10) {
                    LabeledField(title: primaryLabel, text: $primaryValue, keyboard: .decimalPad)
                    LabeledField(title: secondaryLabel, text: $secondaryValue, keyboard: .numbersAndPunctuation)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("心情")
                        .formLabel()
                    Picker("心情", selection: $mood) {
                        ForEach(["轻松", "适中", "较高", "愉快"], id: \.self) { value in
                            Text(value).tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("笔记")
                        .formLabel()
                    TextEditor(text: $note)
                        .frame(minHeight: 86)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                }

                Button {
                    Task { await store.create(recordRequest) }
                } label: {
                    Text("保存记录")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(Color.appTeal)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(16)
        .panelStyle()
        .onChange(of: store.selectedCategory) { _, category in
            applyPreset(for: category)
        }
    }

    private var recordRequest: RecordRequest {
        RecordRequest(
            category: store.selectedCategory,
            title: title,
            date: store.selectedDateKey,
            time: normalizedTime,
            note: note,
            mood: mood,
            details: details
        )
    }

    private var normalizedTime: String {
        let parts = time.split(separator: ":")
        if parts.count == 2 {
            return time
        }
        return "07:30"
    }

    private var details: [String: JSONValue] {
        switch store.selectedCategory {
        case .activity:
            return ["distanceKm": .number(Double(primaryValue) ?? 0), "calories": .number(Double(secondaryValue) ?? 0), "durationMinutes": .number(30)]
        case .meal:
            return ["calories": .number(Double(primaryValue) ?? 0), "protein": .number(Double(secondaryValue) ?? 0)]
        case .expense:
            return ["amount": .number(Double(primaryValue) ?? 0), "category": .string(secondaryValue)]
        case .tip:
            return ["tag": .string(primaryValue), "priority": .number(Double(secondaryValue) ?? 1)]
        }
    }

    private var primaryLabel: String {
        switch store.selectedCategory {
        case .activity: return "距离 km"
        case .meal: return "热量 kcal"
        case .expense: return "金额 ¥"
        case .tip: return "标签"
        }
    }

    private var secondaryLabel: String {
        switch store.selectedCategory {
        case .activity: return "消耗 kcal"
        case .meal: return "蛋白质 g"
        case .expense: return "分类"
        case .tip: return "优先级"
        }
    }

    private func applyPreset(for category: RecordCategory) {
        switch category {
        case .activity:
            title = "晨跑"
            primaryValue = "5.0"
            secondaryValue = "320"
            note = "今天状态很好。"
        case .meal:
            title = "早餐"
            primaryValue = "360"
            secondaryValue = "22"
            note = "清爽的一餐。"
        case .expense:
            title = "咖啡"
            primaryValue = "25"
            secondaryValue = "餐饮"
            note = "记录一笔日常支出。"
        case .tip:
            title = "今日 Tips"
            primaryValue = "健康"
            secondaryValue = "1"
            note = "睡前拉伸 10 分钟。"
        }
    }
}

private struct LabeledField: View {
    let title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .formLabel()
            TextField(title, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
        }
    }
}

private extension Text {
    func formLabel() -> some View {
        font(.caption.weight(.bold))
            .foregroundStyle(Color.appMuted)
    }
}

#Preview {
    RecordFormView()
        .padding()
        .environmentObject(CalendarStore(apiClient: .preview))
}
