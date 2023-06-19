//
//  LogBookStats.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 6/16/23.
//
import UIKit
import Foundation


struct RunRecordStats {
    var runRecords: RunRecords = []
    
    // MARK: - Lifetime Stats
    
    var lifetimeVerticalFeet: String {
        let totalVerticalFeet = runRecords.map { $0.vertical }.reduce(0, +)
        
        if totalVerticalFeet >= 1000 {
            let formattedVerticalFeet = String(format: "%.1fk", Double(totalVerticalFeet) / 1000)
            return formattedVerticalFeet
        }
        
        return String(totalVerticalFeet)
    }
    
    var lifetimeDaysOnMountain: String {
        return String(runRecords.count)
    }
    
    var lifetimeRunsTime: String {
        let totalHours = Int(runRecords.map { $0.duration / 3600 }.reduce(0, +))
        return "\(totalHours)H"
    }
    
    var lifetimeRuns: String {
        return String(runRecords.map { Int($0.runCount) ?? 0 }.reduce(0, +))
    }
    
    // MARK: - Specific Run Record Data
    
    func runRecord(at index: Int) -> RunRecord? {
        guard index >= 0 && index < runRecords.count else {
            return nil
        }
        
        return runRecords[index]
    }
    
    func formattedDateOfRun(at index: Int) -> String {
        let defaultDate = "NA\n"
        guard let runRecord = runRecord(at: index) else {
            return defaultDate
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: String(runRecord.start.split(separator: " ")[0])) {
            dateFormatter.dateFormat = "MMM\nd"
            return dateFormatter.string(from: date)
        }
        
        return defaultDate
    }
    
    func totalRunRecordTime(at index: Int) -> (Int, Int) {
        guard let runRecord = runRecord(at: index) else {
            return (0, 0)
        }
        
        let durationInSeconds = Int(runRecord.duration)
        let hours = durationInSeconds / 3600
        let minutes = (durationInSeconds % 3600) / 60
        
        return (hours, minutes)
    }
    
    func runRecordConditions(at index: Int) -> String {
        guard let conditions = runRecord(at: index)?.conditions else {
            return ""
        }
        
        let capitalizedConditions = conditions
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).capitalized }
            .prefix(2)
            .joined(separator: ", ")
        
        return capitalizedConditions
    }
    
    
    func runRecordTopSpeed(at index: Int) -> String {
        return String(format: "%.1f", runRecord(at: index)?.topSpeed ?? 0.0)
    }
    
    func getConfiguredRunRecordData(at index: Int) -> ConfiguredRunRecordData? {
        guard let runRecord = runRecord(at: index) else {
            return nil
        }
        
        let (runDurationHour, runDurationMinutes) = totalRunRecordTime(at: index)
        
        return ConfiguredRunRecordData(locationName: runRecord.locationName,
                                       numberOfRuns: Int(runRecord.runCount) ?? 0,
                                       runDurationHour: runDurationHour,
                                       runDurationMinutes: runDurationMinutes,
                                       dateOfRun: formattedDateOfRun(at: index),
                                       conditions: runRecordConditions(at: index),
                                       topSpeed: runRecordTopSpeed(at: index))
    }
    
    // MARK: Lifetime Stats
    var lifetimeAverages: [(Stat, Stat?)] {
        return [
            (Stat(label: "run vertical", information: calculateAverageVerticalFeet(), icon: UIImage(systemName: "arrow.down")!),
            Stat(label: "run distance", information: calculateAverageDistance(), icon: UIImage(systemName: "arrow.right")!)),
            (Stat(label: "speed", information: calculateAverageSpeed(), icon: UIImage(systemName: "speedometer")!), nil)
        ]
    }
    
    var lifetimeBest: [(Stat, Stat?)] {
        return [
           (Stat(label: "top speed", information: calculateBestTopSpeed(), icon: UIImage(systemName: "flame")!),
           Stat(label: "tallest run", information: calculateBestTallestRun(), icon: UIImage(systemName: "arrow.down")!)),
           (Stat(label: "longest run", information: calculateBestLongestRun(), icon: UIImage(systemName: "arrow.right")!), nil)
        ]
    }
    
    // Helper methods to calculate the averages and best values
    private func calculateAverageVerticalFeet() -> String {
        let averageVerticalFeet = runRecords.map { $0.vertical }.reduce(0.0) {
            return $0 + $1/Double(runRecords.count)
        }
        
        if averageVerticalFeet >= 1000 {
            return String(format: "%.1fk", averageVerticalFeet / 1000)
        }
        
        return String(format: "%.0f FT", averageVerticalFeet)
    }
    
    private func calculateAverageDistance() -> String {
        let averageDistance = runRecords.map { $0.distance }.reduce(0.0) {
            return $0 + $1/Double(runRecords.count)
        }
        
        return String(format: "%.1f MI", averageDistance.feetToMiles)
    }
    
    private func calculateAverageSpeed() -> String {
        let averageSpeed = runRecords.map { $0.topSpeed }.reduce(0.0) {
            return $0 + $1/Double(runRecords.count)
        }
        
        return String(format: "%.1f MPH", averageSpeed)
    }
    
    private func calculateBestTopSpeed() -> String {
        return String(format: "%.1f MPH", runRecords.map { $0.topSpeed }.max() ?? 0.0)
    }
    
    private func calculateBestTallestRun() -> String {
        return String(format: "%.1f FT", runRecords.map { $0.vertical }.max() ?? 0.0)
    }
    
    private func calculateBestLongestRun() -> String {
        return String(format: "%.1f MI", (runRecords.map { $0.distance }.max() ?? 0.0).feetToMiles)
    }
}

struct ConfiguredRunRecordData {
    let locationName: String
    let numberOfRuns: Int
    let runDurationHour: Int
    let runDurationMinutes: Int
    let dateOfRun: String
    let conditions: String
    let topSpeed: String
}

extension Double {
    var feetToMiles: Self {
        return self / 5280
    }
}
