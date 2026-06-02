import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: CalendarStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HeaderView()
                    if let errorMessage = store.errorMessage {
                        ErrorBanner(message: errorMessage)
                    }
                    MonthCalendarView()
                    DayDetailView()
                    RecordFormView()
                    StatsView()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(
                LinearGradient(
                    colors: [Color.appSurfaceSoft, Color.appBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await store.loadMonth()
            }
            .refreshable {
                await store.loadMonth()
            }
        }
    }
}

private struct HeaderView: View {
    @EnvironmentObject private var store: CalendarStore

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("清爽日历")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTeal)
                Text("记录生活，发现美好")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appText)
                    .minimumScaleFactor(0.72)
            }
            Spacer()
            Button {
                Task { await store.jumpToToday() }
            } label: {
                Label("今天", systemImage: "calendar")
                    .font(.subheadline.weight(.bold))
            }
            .buttonStyle(.bordered)
            .tint(Color.appTeal)
        }
        .padding(.top, 12)
    }
}

private struct ErrorBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    ContentView()
        .environmentObject(CalendarStore(apiClient: .preview))
}

