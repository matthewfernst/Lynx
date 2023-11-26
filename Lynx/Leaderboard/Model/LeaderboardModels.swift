//
//  LeaderboardModels.swift
//  Lynx
//
//  Created by Matthew Ernst on 7/16/23.
//

import Foundation
import UIKit

class LeaderboardAttributes
{
    let fullName: String
    var profilePicture: UIImage?
    let stat: String
    
    init(leader: Leaderboard, category: LeaderboardSort, completion: (() -> Void)? = nil) {

        self.fullName = leader.firstName + " " + leader.lastName
        self.stat = Self.numericalStat(for: category, logbooks: leader.logbooks)
        
        if let profilePictureURL = leader.profilePictureUrl,
           let url = URL(string: profilePictureURL) {
            ProfilePictureUtils.downloadProfilePicture(with: url) { [weak self] image in
                self?.profilePicture = image
                DispatchQueue.main.async {
                    completion?()
                }
            }
        } else {
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

        private static func numericalStat(for category: LeaderboardSort, logbooks: LeaderLogbooks) -> String {
            let statData: String

            switch logbooks {
            case .selectedLeader(let logbook):
                statData = mapData(logbook: logbook, category: category)
            default:
                statData = mapData(logbooks: logbooks)
            }

            let measurementSystem: String
            switch category {
            case .distance, .verticalDistance:
                measurementSystem = TabViewController.profile?.measurementSystem == .imperial ? "FT" : "M"
            case .runCount:
                measurementSystem = "Runs"
            case .topSpeed:
                measurementSystem = TabViewController.profile?.measurementSystem == .imperial ? "MPH" : "KPH"
            }

            return statData + " " + measurementSystem
        }

        
        private static func mapData(logbooks: LeaderLogbooks) -> String {
            let statData: String

            switch logbooks {
            case .distanceLogbook(let logbook):
                statData = mapNumericData(logbook.map(\.distance))
            case .runCountLogbook(let logbook):
                statData = mapNumericData(logbook.map({ Double($0.runCount)}))
            case .topSpeedLogbook(let logbook):
                statData = String(format: "%.1f", logbook.map(\.topSpeed).max()!)
            case .verticalDistanceLogbook(let logbook):
                statData = mapNumericData(logbook.map(\.verticalDistance))
            default:
                statData = ""
            }

            return statData
        }

        private static func mapData(logbook: [ApolloGeneratedGraphQL.GetSelectedLeaderboardQuery.Data.Leaderboard.Logbook], category: LeaderboardSort) -> String {
            let statData: String

            switch category {
            case .distance:
                statData = mapNumericData(logbook.map(\.distance))
            case .runCount:
                statData = mapNumericData(logbook.map({ Double($0.runCount)}))
            case .topSpeed:
                statData = String(format: "%.1f", logbook.map(\.topSpeed).max()!)
            case .verticalDistance:
                statData = mapNumericData(logbook.map(\.verticalDistance))
            }
            return statData
        }

        private static func mapNumericData(_ data: [Double]) -> String {
            let total: Double = data.reduce(0, +)

            return LogbookStats.getDistanceFormatted(distance: total)
        }
    
}
