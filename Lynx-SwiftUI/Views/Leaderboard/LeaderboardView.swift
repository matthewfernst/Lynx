import SwiftUI
import Charts

struct LeaderboardView: View {
    @Environment(ProfileManager.self) private var profileManager
    @State private var leaderboardHandler = LeaderboardHandler()
    @State private var logbookStats = LogbookStats()
    @State private var selectedTimeframe: Timeframe = .season
    @State private var selectedResort: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                if leaderboardHandler.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                } else if let errorMessage = leaderboardHandler.errorMessage {
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

                        // Four leaderboard charts
                        GlobalLeaderboardChart(
                            leaders: leaderboardHandler.verticalDistanceLeaders,
                            sortBy: .verticalDistance,
                            measurementSystem: profileManager.measurementSystem
                        )

                        GlobalLeaderboardChart(
                            leaders: leaderboardHandler.distanceLeaders,
                            sortBy: .distance,
                            measurementSystem: profileManager.measurementSystem
                        )

                        GlobalLeaderboardChart(
                            leaders: leaderboardHandler.topSpeedLeaders,
                            sortBy: .topSpeed,
                            measurementSystem: profileManager.measurementSystem
                        )

                        GlobalLeaderboardChart(
                            leaders: leaderboardHandler.runCountLeaders,
                            sortBy: .runCount,
                            measurementSystem: profileManager.measurementSystem
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(uiColor: .systemGroupedBackground))
            .task {
                logbookStats.requestLogs()
                fetchLeaderboards()
            }
            .refreshable {
                fetchLeaderboards()
            }
        }
    }

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters")
                .font(.headline)
                .foregroundStyle(.secondary)

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
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
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
        leaderboardHandler.fetchAllLeaderboards(
            timeframe: selectedTimeframe,
            resort: selectedResort,
            measurementSystem: profileManager.measurementSystem
        )
    }
}
