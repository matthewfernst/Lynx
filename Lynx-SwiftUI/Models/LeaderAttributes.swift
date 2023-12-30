//
//  LeaderAttributes.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/9/23.
//

import Foundation

struct LeaderAttributes: Identifiable, Hashable {
    var id: UUID
    let fullName: String
    let category: LeaderboardSort
    let profilePictureURL: URL?
    let stat: Double
    
    init(leader: Leaderboard, category: LeaderboardSort, profilePictureURL: URL?) {
        self.id = UUID()
        self.fullName = leader.firstName + " " + leader.lastName
        self.category = category
        self.profilePictureURL = profilePictureURL
        self.stat = LeaderAttributes.getNumericStatFrom(leaderStat: leader.stat, specificStatSortedBy: category)
    }
    
    private static func getNumericStatFrom(leaderStat: LeaderStat?, specificStatSortedBy: LeaderboardSort) -> Double {
        guard let stat = leaderStat else {
            return Constants.defaultStat
        }
        
        switch stat {
        case .distanceStat(let distanceStat):
            return distanceStat?.distance ?? Constants.defaultStat
        case .topSpeedStat(let topSpeedStat):
            return topSpeedStat?.topSpeed ?? Constants.defaultStat
        case .runCountStat(let runCountStat):
            return Double(runCountStat?.runCount ?? 0)
        case .verticalDistanceStat(let verticalDistanceStat):
            return verticalDistanceStat?.verticalDistance ?? Constants.defaultStat
        case .selectedLeaderStat(let selectedLeaderStat):
            guard let selectedLeaderStat = selectedLeaderStat else {
                return Constants.defaultStat
            }
            
            switch specificStatSortedBy {
            case .distance:
                return selectedLeaderStat.distance
            case .topSpeed:
                return selectedLeaderStat.topSpeed
            case .runCount:
                return Double(selectedLeaderStat.runCount)
            case .verticalDistance:
                return selectedLeaderStat.verticalDistance
            }
        }
    }
    
    
    static func formattedStatLabel(
        _ stat: Double,
        forCategory category: LeaderboardCategory,
        withMeasurementSystem measurementSystem: MeasurementSystem
    ) -> String {
        switch category {
        case .distance, .verticalDistance:
            return String(format: "%.1fk \(measurementSystem.feetOrMeters)", stat / Constants.thousandDivisor)
        case .runCount:
            return "\(Int(stat))"
        case .topSpeed:
            return String(format: "%.1f \(measurementSystem.milesOrKilometersPerHour)", stat)
        }
    }
    
    private struct Constants {
        static let defaultStat: Double = 0
        
        static let thousandDivisor: Double = 1000
    }
}
