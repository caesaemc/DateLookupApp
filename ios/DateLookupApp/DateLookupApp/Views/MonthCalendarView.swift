import SwiftUI

struct MonthCalendarView: View {
    @EnvironmentObject private var store: CalendarStore
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    Task { await store.moveMonth(by: -1) }
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)

                Spacer()
                Text(DateFormatter.monthTitle.string(from: store.visibleMonth))
                    .font(.title3.bold())
                Spacer()

                Button {
                    Task { await store.moveMonth(by: 1) }
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(Color.appTeal)
            .padding(16)

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                }

                ForEach(CalendarGridBuilder.monthGrid(for: store.visibleMonth), id: \.self) { day in
                    CalendarDayCell(
                        day: day,
                        records: store.recordsByDate[DateFormatter.dayKey.string(from: day)] ?? []
                    )
                    .onTapGesture {
                        store.select(day)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .panelStyle()
    }
}

private struct CalendarDayCell: View {
    @EnvironmentObject private var store: CalendarStore
    let day: Date
    let records: [CalendarRecord]

    private var isSelected: Bool {
        Calendar.current.isDate(day, inSameDayAs: store.selectedDate)
    }

    private var isCurrentMonth: Bool {
        Calendar.current.isDate(day, equalTo: store.visibleMonth, toGranularity: .month)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dayNumber)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(isSelected ? .white : isCurrentMonth ? Color.appText : Color.appMuted.opacity(0.55))
                .frame(width: 26, height: 26)
                .background(isSelected ? Color.appTeal : Color.clear)
                .clipShape(Circle())

            ForEach(records.prefix(3)) { record in
                Text(record.summary)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(record.category.tint)
                    .lineLimit(1)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(record.category.tint.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            }
            Spacer(minLength: 0)
        }
        .padding(6)
        .frame(height: 82)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.appTeal.opacity(0.12) : isCurrentMonth ? Color.white : Color.appBackground.opacity(0.8))
        .overlay(alignment: .topTrailing) {
            if records.count > 3 {
                Text("+\(records.count - 3)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.appMuted)
                    .padding(4)
            }
        }
        .overlay(
            Rectangle()
                .stroke(Color.appBorder, lineWidth: 0.5)
        )
    }

    private var dayNumber: String {
        let component = Calendar.current.component(.day, from: day)
        return String(component)
    }
}

#Preview {
    MonthCalendarView()
        .padding()
        .environmentObject(CalendarStore(apiClient: .preview))
}

