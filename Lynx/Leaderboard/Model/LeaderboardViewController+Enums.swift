//
//  LeaderboardViewController+Enums.swift
//  Lynx
//
//  Created by Matthew Ernst on 7/14/23.
//

import Foundation

enum LeaderboardSections: Int, CaseIterable
{
    case distance = 0
    case runCount = 1
    case topSpeed = 2
    case verticalDistance = 3
}

typealias LeaderboardPlaces = LeaderboardRows
enum LeaderboardRows: Int, CaseIterable
{
    case firstPlace = 0
    case secondPlace = 1
    case thirdPlace = 2
    case showAll = 3
}
