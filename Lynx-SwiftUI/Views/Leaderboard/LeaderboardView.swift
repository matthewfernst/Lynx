//
//  LeaderboardView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(ProfileManager.self) private var profileManager
    
    @State private var verticalDistanceLeaders: [LeaderAttributes] = []
    @State private var topSpeedLeaders: [LeaderAttributes] = []
    @State private var distanceLeaders: [LeaderAttributes] = []
    @State private var runCountLeaders: [LeaderAttributes] = []
    
    
    @State private var showFailedToGetTopLeaders = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(Array(zip([
                    verticalDistanceLeaders, topSpeedLeaders, distanceLeaders, runCountLeaders
                ], [
                    LeaderboardCategory.verticalDistance(), .topSpeed(), .distance(), .runCount(),
                ])), id: \.1) { leaders, category in
                    TopLeadersForCategoryView(
                        topLeaders: leaders,
                        category: category
                    )
                }
            }
            .padding()
            .alert("Failed to Get Top Leaders", isPresented: $showFailedToGetTopLeaders, actions: {})
            .navigationTitle("Leaderboard")
            .scrollContentBackground(.hidden)
            .onAppear {
                populateLeaderboard()
            }
            .refreshable { // TODO: Refresh being wonky on simulator?
                populateLeaderboard()
            }
        }
    }
    
    private func populateLeaderboard() {
        ApolloLynxClient.getAllLeaderboards(
            for: .allTime,
            limit: Constants.topThree,
            inMeasurementSystem: profileManager.measurementSystem
        ) { result in
            switch result {
            case .success(let leaderboards):
                distanceLeaders = leaderboards[.distance] ?? []
                runCountLeaders = leaderboards[.runCount] ?? []
                topSpeedLeaders = leaderboards[.topSpeed] ?? []
                verticalDistanceLeaders = leaderboards[.verticalDistance] ?? []
            case .failure(_):
                showFailedToGetTopLeaders = true
            }
        }
    }
    
    private struct Constants {
        static let topThree: Int = 3
    }
}

enum LeaderboardCategory: Equatable, Hashable {
    case distance(headerLabelText: String = "Distance", headerSystemImage: String = "arrow.right")
    case runCount(headerLabelText: String = "Run Count", headerSystemImage: String = "figure.skiing.downhill")
    case topSpeed(headerLabelText: String = "Top Speed", headerSystemImage: String = "flame")
    case verticalDistance(headerLabelText: String = "Vertical Distance", headerSystemImage: String = "arrow.down")
    
    var headerLabelText: String {
        switch self {
        case .distance(let labelText, _),
                .runCount(let labelText, _),
                .topSpeed(let labelText, _),
                .verticalDistance(let labelText, _):
            return labelText
        }
    }
    
    var headerSystemImage: String {
        switch self {
        case .distance(_, let systemImage),
                .runCount(_, let systemImage),
                .topSpeed(_, let systemImage),
                .verticalDistance(_, let systemImage):
            return systemImage
        }
    }
    
    var correspondingSort: LeaderboardSort {
        switch self {
        case .distance:
            return .distance
        case .runCount:
            return .runCount
        case .topSpeed:
            return .topSpeed
        case .verticalDistance:
            return .verticalDistance
        }
    }
}



#Preview {
    LeaderboardView()
}
