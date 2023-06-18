//
//  LogBookStats.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 6/16/23.
//

import Foundation
import Apollo

struct RunRecordStats
{
    
    var runRecords: RunRecords = []
    
    // MARK: Top Main Stats
    public func lifetimeVerticalFeet() -> String {
        let totalVerticalFeet = runRecords.map({ $0.vertical }).reduce(0, +)
        
        if totalVerticalFeet >= 1000 {
            let formattedVerticalFeet = String(format: "%.1fk", Double(totalVerticalFeet) / 1000)
            return formattedVerticalFeet
        }
        
        return String(totalVerticalFeet)
    }
    
    public func lifetimeDaysOnMountain() -> String {
        return String(runRecords.count)
    }
    
    public func lifetimeRunsTime() -> String {
        let totalHours = Int(runRecords.map { $0.duration / 3600 }.reduce(0, +))
        return "\(totalHours)H"
    }
    
    public func lifetimeRuns() -> String {
        return String(runRecords.map({ Int($0.runCount) ?? 0 }).reduce(0, +))
    }
    
    // MARK: Specific Runs Values
    public func runLocationName(index: Int) -> String {
        return runRecords[index].locationName
    }
    
    public func runRecordDate(index: Int) -> String {
        let dateString = runRecords[index].start.split(separator: " ")[0]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateFormatter.date(from: String(dateString)) {
            dateFormatter.dateFormat = "MMM\nd"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        }
        return "Jan\n1"
    }
    
    public func runRecordNumberOfRuns(index: Int) -> Int {
        return Int(runRecords[index].runCount) ?? 0
    }
    
    public func totalRunRecordTime(index: Int) -> (Int, Int) {
        let durationInSeconds = Int(runRecords[index].duration)
        let hours = durationInSeconds / 3600
        let minutes = (durationInSeconds % 3600) / 60
        
        return (hours, minutes)
    }
    
}
