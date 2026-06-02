import SwiftUI

struct DayDetailView: View {
    @EnvironmentObject private var store: CalendarStore

    private var visibleRecords: [CalendarRecord] {
        let filtered = store.selectedRecords.filter { $0.category == store.selectedCategory }
        return filtered.isEmpty ? store.selectedRecords : filtered
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("每日详情")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appMuted)
                    Text(DateFormatter.dayTitle.string(from: store.selectedDate))
                        .font(.title3.bold())
                        .foregroundStyle(Color.appText)
                }
                Spacer()
                if store.isLoading {
                    ProgressView()
                }
            }

            CategoryPicker(selection: $store.selectedCategory)

            if visibleRecords.isEmpty {
                EmptyRecordView(category: store.selectedCategory)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(visibleRecords) { record in
                            RecordCard(record: record)
                                .frame(width: 230)
                        }
                    }
                    .padding(.bottom, 2)
                }
            }
        }
        .padding(16)
        .panelStyle()
    }
}

private struct EmptyRecordView: View {
    let category: RecordCategory

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: category.symbolName)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(category.tint)
            Text("今天还没有\(category.title)记录")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appMuted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(category.tint.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct RecordCard: View {
    @EnvironmentObject private var store: CalendarStore
    let record: CalendarRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: record.category.symbolName)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(record.category.tint)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(record.title)
                        .font(.headline)
                    Text("\(record.time) · \(record.category.title)")
                        .font(.caption)
                        .foregroundStyle(Color.appMuted)
                }
                Spacer()
                Button(role: .destructive) {
                    Task { await store.delete(record) }
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.appMuted)
            }

            VStack(spacing: 10) {
                ForEach(record.detailRows, id: \.0) { label, value in
                    HStack {
                        Text(label)
                            .foregroundStyle(Color.appMuted)
                        Spacer()
                        Text(value)
                            .fontWeight(.bold)
                            .foregroundStyle(record.category.tint)
                    }
                    .font(.subheadline)
                    Divider()
                }
            }

            if !record.note.isEmpty {
                Text(record.note)
                    .font(.caption)
                    .foregroundStyle(Color.appMuted)
                    .lineLimit(3)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(height: 250)
        .background(record.category.tint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(record.category.tint.opacity(0.24), lineWidth: 1)
        )
    }
}

