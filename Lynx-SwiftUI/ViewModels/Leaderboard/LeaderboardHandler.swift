import Foundation
import OSLog

@Observable final class LeaderboardHandler {
    var isLoading = false
    var distanceLeaders: [LeaderAttributes] = []
    var runCountLeaders: [LeaderAttributes] = []
    var topSpeedLeaders: [LeaderAttributes] = []
    var verticalDistanceLeaders: [LeaderAttributes] = []
    var errorMessage: String?

    func fetchAllLeaderboards(
        timeframe: Timeframe,
        resort: String? = nil,
        measurementSystem: MeasurementSystem
    ) {
        isLoading = true
        errorMessage = nil

        ApolloLynxClient.getAllLeaderboards(
            for: timeframe,
            limit: 10,
            inMeasurementSystem: measurementSystem,
            resort: resort
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let leaderboards):
                    self?.distanceLeaders = leaderboards[.distance] ?? []
                    self?.runCountLeaders = leaderboards[.runCount] ?? []
                    self?.topSpeedLeaders = leaderboards[.topSpeed] ?? []
                    self?.verticalDistanceLeaders = leaderboards[.verticalDistance] ?? []
                    Logger.leaderboard.info("Successfully fetched all leaderboards")
                case .failure(let error):
                    Logger.leaderboard.error("Failed to fetch leaderboards: \(error.localizedDescription)")
                    self?.errorMessage = "Failed to load leaderboards. Please try again."
                }
            }
        }
    }
}
