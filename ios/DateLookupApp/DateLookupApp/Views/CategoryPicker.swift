import SwiftUI

struct CategoryPicker: View {
    @Binding var selection: RecordCategory

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(RecordCategory.allCases) { category in
                Button {
                    selection = category
                } label: {
                    Label(category.title, systemImage: category.symbolName)
                        .font(.caption.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(selection == category ? category.tint.opacity(0.14) : Color.white)
                        .foregroundStyle(selection == category ? category.tint : Color.appMuted)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(selection == category ? category.tint.opacity(0.35) : Color.appBorder, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

