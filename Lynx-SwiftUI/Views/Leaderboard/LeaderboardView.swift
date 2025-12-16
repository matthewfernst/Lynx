import SwiftUI
import Charts
import OSLog

struct LeaderboardView: View {
    @Environment(ProfileManager.self) private var profileManager
    @State private var logbookStats = LogbookStats()
    @State private var selectedTimeframe: Timeframe = .season
    @State private var selectedResort: String? = nil

    @State private var isLoading = false
    @State private var distanceLeaders: [LeaderAttributes] = []
    @State private var runCountLeaders: [LeaderAttributes] = []
    @State private var topSpeedLeaders: [LeaderAttributes] = []
    @State private var verticalDistanceLeaders: [LeaderAttributes] = []
    @State private var errorMessage: String?
    @State private var hasAppeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Loading Leaderboards...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else if let errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Try Again") {
                            fetchLeaderboards()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else {
                    VStack(spacing: 24) {
                        // Filter controls
                        filterSection
                            .opacity(hasAppeared ? 1 : 0)
                            .offset(y: hasAppeared ? 0 : -10)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasAppeared)

                        // Four leaderboard charts
                        GlobalLeaderboardChart(
                            leaders: verticalDistanceLeaders,
                            sortBy: .verticalDistance,
                            measurementSystem: profileManager.measurementSystem
                        )
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1), value: hasAppeared)

                        GlobalLeaderboardChart(
                            leaders: distanceLeaders,
                            sortBy: .distance,
                            measurementSystem: profileManager.measurementSystem
                        )
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2), value: hasAppeared)

                        GlobalLeaderboardChart(
                            leaders: topSpeedLeaders,
                            sortBy: .topSpeed,
                            measurementSystem: profileManager.measurementSystem
                        )
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.3), value: hasAppeared)

                        GlobalLeaderboardChart(
                            leaders: runCountLeaders,
                            sortBy: .runCount,
                            measurementSystem: profileManager.measurementSystem
                        )
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.4), value: hasAppeared)
                    }
                    .padding()
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(uiColor: .systemGroupedBackground))
            .task {
                Logger.leaderboard.info("LeaderboardView appeared - starting initial fetch")
                logbookStats.requestLogs()
                fetchLeaderboards()

                withAnimation {
                    hasAppeared = true
                }
            }
            .refreshable {
                fetchLeaderboards()
            }
        }
    }

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Timeframe Menu
                Menu {
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        Text("All Time").tag(Timeframe.allTime)
                        Text("Season").tag(Timeframe.season)
                        Text("Month").tag(Timeframe.month)
                        Text("Week").tag(Timeframe.week)
                        Text("Day").tag(Timeframe.day)
                    }
                } label: {
                    HStack {
                        Text(timeframeLabel)
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                .onChange(of: selectedTimeframe) { _, _ in
                    fetchLeaderboards()
                }

                // Resort Menu
                Menu {
                    Picker("Resort", selection: $selectedResort) {
                        Text("All Resorts").tag(String?.none)
                        ForEach(visitedResorts, id: \.self) { resort in
                            Text(resort).tag(String?.some(resort))
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedResort ?? "All Resorts")
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                .onChange(of: selectedResort) { _, _ in
                    fetchLeaderboards()
                }

                Spacer()
            }
        }
    }

    private var timeframeLabel: String {
        switch selectedTimeframe {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .season: return "Season"
        case .allTime: return "All Time"
        }
    }

    private var visitedResorts: [String] {
        let resorts = Set(logbookStats.logbooks.map { $0.locationName })
        return resorts.sorted()
    }

    private func fetchLeaderboards() {
        isLoading = true
        errorMessage = nil

        ApolloLynxClient.getAllLeaderboards(
            for: selectedTimeframe,
            limit: 10,
            inMeasurementSystem: profileManager.measurementSystem,
            resort: selectedResort
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let leaderboards):
                    self.distanceLeaders = leaderboards[.distance] ?? []
                    self.runCountLeaders = leaderboards[.runCount] ?? []
                    self.topSpeedLeaders = leaderboards[.topSpeed] ?? []
                    self.verticalDistanceLeaders = leaderboards[.verticalDistance] ?? []

                    // Log detailed info
                    Logger.leaderboard.info("Successfully fetched leaderboards - Distance: \(self.distanceLeaders.count), RunCount: \(self.runCountLeaders.count), TopSpeed: \(self.topSpeedLeaders.count), Vertical: \(self.verticalDistanceLeaders.count)")
                case .failure(let error):
                    Logger.leaderboard.error("Failed to fetch leaderboards: \(error.localizedDescription)")
                    self.errorMessage = "Failed to load leaderboards. \(error.localizedDescription)"
                }
            }
        }
    }
}
