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
        self.stat = Self.numericalStat(for: category, logbook: leader.logbook)
        
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
    
    private static func numericalStat(for category: LeaderboardSort, logbook: LeaderLogbooks) -> String {
        let numericalStat: String
        switch category {
        case .distance:
            numericalStat = LogbookStats.getDistanceFormatted(distance: logbook.map({
                $0.distance
            }).reduce(0, +))
        case .runCount:
            numericalStat = String(logbook.map({ $0.runCount }).reduce(0, +))
        case .topSpeed:
            numericalStat = String(format: "%.1f", logbook.map({ $0.topSpeed }).max()!)
        case .verticalDistance:
            numericalStat = LogbookStats.getDistanceFormatted(distance: logbook.map({
                $0.verticalDistance
            }).reduce(0, +))
        }
        
        let measurementSystem: String
        switch category {
        case .distance, .verticalDistance:
            switch TabViewController.profile?.measurementSystem {
            case .imperial:
                measurementSystem = "FT"
            case .metric:
                measurementSystem = "M"
            case .none:
                measurementSystem = ""
            }
        case .runCount:
            measurementSystem = "Runs"
        case .topSpeed:
            switch TabViewController.profile?.measurementSystem {
            case .imperial:
                measurementSystem = "MPH"
            case .metric:
                measurementSystem = "KPH"
            case .none:
                measurementSystem = ""
            }
        }
        return  numericalStat + " " + measurementSystem
    }
    
    
}
