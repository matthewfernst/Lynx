//
//  LogBookStats.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 6/16/23.
//
import UIKit
import Foundation


struct LogbookStats {
    var logbooks: Logbooks = []
    
    // MARK: - Lifetime Stats
    
    var lifetimeVerticalFeet: String {
        let totalVerticalFeet = logbooks.map { $0.verticalDistance }.reduce(0, +)
        
        if totalVerticalFeet >= 1000 {
            let formattedVerticalFeet = String(format: "%.1fk", Double(totalVerticalFeet) / 1000)
            return formattedVerticalFeet
        }
        
        return String(totalVerticalFeet)
    }
    
    var lifetimeDaysOnMountain: String {
        return String(logbooks.count)
    }
    
    var lifetimeRunsTime: String {
        let totalHours = Int(logbooks.map { $0.duration / 3600 }.reduce(0, +))
        return "\(totalHours)H"
    }
    
    var lifetimeRuns: String {
        return String(logbooks.map { Int($0.runCount) }.reduce(0, +))
    }
    
    // MARK: - Specific Run Record Data
    
    func logbook(at index: Int) -> Logbook? {
        guard index >= 0 && index < logbooks.count else {
            return nil
        }
        
        return logbooks[index]
    }
    
    func formattedDateOfRun(at index: Int) -> String {
        let defaultDate = "NA\n"
        guard let logbook = logbook(at: index) else {
            return defaultDate
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: String(logbook.startDate.split(separator: " ")[0])) {
            dateFormatter.dateFormat = "MMM\nd"
            return dateFormatter.string(from: date)
        }
        
        return defaultDate
    }
    
    func totalLogbookTime(at index: Int) -> (Int, Int) {
        guard let logbook = logbook(at: index) else {
            return (0, 0)
        }
        
        let durationInSeconds = Int(logbook.duration)
        let hours = durationInSeconds / 3600
        let minutes = (durationInSeconds % 3600) / 60
        
        return (hours, minutes)
    }
    
    func logbookConditions(at index: Int) -> String {
        guard let conditions = logbook(at: index)?.conditions else {
            return ""
        }
        
        var capitalizedConditions = conditions
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).capitalized }
        
        if capitalizedConditions.count > 1 {
            capitalizedConditions.removeAll(where: { $0 == "Packed" })
        }
        
        let formattedCondition = capitalizedConditions.first ?? ""
        return formattedCondition
    }
    
    
    func logbookTopSpeed(at index: Int) -> String {
        return String(format: "%.1f", logbook(at: index)?.topSpeed ?? 0.0)
    }
    
    func getConfiguredLogbookData(at index: Int) -> ConfiguredLogbookData? {
        guard let logbook = logbook(at: index) else {
            return nil
        }
        
        let (runDurationHour, runDurationMinutes) = totalLogbookTime(at: index)
        
        return ConfiguredLogbookData(locationName: logbook.locationName,
                                       numberOfRuns: Int(logbook.runCount) ,
                                       runDurationHour: runDurationHour,
                                       runDurationMinutes: runDurationMinutes,
                                       dateOfRun: formattedDateOfRun(at: index),
                                       conditions: logbookConditions(at: index),
                                       topSpeed: logbookTopSpeed(at: index))
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
        let averageVerticalFeet = logbooks.map { $0.verticalDistance }.reduce(0.0) {
            return $0 + $1/Double(logbooks.count)
        }
        
        if averageVerticalFeet >= 1000 {
            return String(format: "%.1fk", averageVerticalFeet / 1000)
        }
        
        return String(format: "%.0f FT", averageVerticalFeet)
    }
    
    private func calculateAverageDistance() -> String {
        let averageDistance = logbooks.map { $0.distance }.reduce(0.0) {
            return $0 + $1/Double(logbooks.count)
        }
        
        return String(format: "%.1f MI", averageDistance.feetToMiles)
    }
    
    private func calculateAverageSpeed() -> String {
        let averageSpeed = logbooks.map { $0.topSpeed }.reduce(0.0) {
            return $0 + $1/Double(logbooks.count)
        }
        
        return String(format: "%.1f MPH", averageSpeed)
    }
    
    private func calculateBestTopSpeed() -> String {
        return String(format: "%.1f MPH", logbooks.map { $0.topSpeed }.max() ?? 0.0)
    }
    
    private func calculateBestTallestRun() -> String {
        return String(format: "%.1f FT", logbooks.map { $0.verticalDistance }.max() ?? 0.0)
    }
    
    private func calculateBestLongestRun() -> String {
        return String(format: "%.1f MI", (logbooks.map { $0.distance }.max() ?? 0.0).feetToMiles)
    }
}

struct ConfiguredLogbookData {
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