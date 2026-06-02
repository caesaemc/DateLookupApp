import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: CalendarStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(store.stats.month)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appMuted)
                Text("月度趋势")
                    .font(.title3.bold())
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                StatTile(title: "跑步距离", value: "\(store.stats.activityDistanceKm.trimmed) km")
                StatTile(title: "总消耗", value: "\(Int(store.stats.activityCalories)) kcal")
                StatTile(title: "摄入热量", value: "\(Int(store.stats.mealCalories)) kcal")
                StatTile(title: "支出", value: "¥\(Int(store.stats.expenseAmount))")
            }

            HStack(spacing: 10) {
                ForEach(RecordCategory.allCases) { category in
                    CountRing(
                        category: category,
                        count: store.stats.categoryCounts[category] ?? 0
                    )
                }
            }

            Text("本月已记录 \(store.stats.recordDays) 天，保持轻量但稳定的生活复盘。")
                .font(.footnote)
                .foregroundStyle(Color.appMuted)
        }
        .padding(16)
        .panelStyle()
    }
}

private struct StatTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appMuted)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color.appText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.appBackground.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }
}

private struct CountRing: View {
    let category: RecordCategory
    let count: Int

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .stroke(category.tint.opacity(0.24), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: min(CGFloat(count) / 12, 1))
                    .stroke(category.tint, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(count)")
                        .font(.headline.bold())
                    Text(category.title)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.appMuted)
                }
            }
            .frame(height: 68)
        }
        .frame(maxWidth: .infinity)
    }
}

private extension Double {
    var trimmed: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(format: "%.1f", self)
    }
}

#Preview {
    StatsView()
        .padding()
        .environmentObject(CalendarStore(apiClient: .preview))
}

