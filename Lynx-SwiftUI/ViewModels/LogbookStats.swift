//
//  LogBookStats.swift
//  Lynx
//
//  Created by Matthew Ernst on 6/16/23.
//
import Foundation
import SwiftUI

@Observable final class LogbookStats {
    private var profileManager = ProfileManager.shared
    var logbooks: Logbooks = []
    
    // MARK: - Lifetime Stats
    func getDistanceFormatted(distance: Double) -> String {
        if distance >= 1000 {
            return String(format: "%.1fk", Double(distance) / 1000)
        }
        return String(distance)
    }
    
    var lifetimeVertical: String {
        let totalVerticalFeet = logbooks.map { $0.verticalDistance }.reduce(0, +)
        
        if totalVerticalFeet == 0 { return "--" }
        
        return getDistanceFormatted(distance: totalVerticalFeet)
    }
    
    var lifetimeDaysOnMountain: String {
        let totalDays = logbooks.count
        return totalDays == 0 ? "--" : String(totalDays)
    }
    
    var lifetimeRunsTime: String {
        let totalHours = Int(logbooks.map { $0.duration / 3600 }.reduce(0, +))
        if totalHours == 0 { return "--" }
        return "\(totalHours)H"
    }
    
    var lifetimeRuns: String {
        let totalRuns = logbooks.map { Int($0.runCount) }.reduce(0, +)
        return totalRuns == 0 ? "--" : String(totalRuns)
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
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "_", with: " ").capitalized }
        
        if capitalizedConditions.count > 1 {
            capitalizedConditions.removeAll(where: { $0 == "Packed" })
        }
        
        let formattedCondition = capitalizedConditions.first ?? ""
        return formattedCondition
    }
    
    func logbookTopSpeed(at index: Int) -> String {
        return String(format: "%.1f\(profileManager.measurementSystem.milesOrKilometersPerHour)", logbook(at: index)?.topSpeed ?? 0.0)
    }
    
    func getConfiguredLogbookData(at index: Int) -> ConfiguredLogbookData? {
        guard let logbook = logbook(at: index) else {
            return nil
        }
        
        let (runDurationHour, runDurationMinutes) = totalLogbookTime(at: index)
        
        return ConfiguredLogbookData(
            resortName: logbook.locationName,
            numberOfRuns: Int(logbook.runCount),
            runDurationHour: runDurationHour,
            runDurationMinutes: runDurationMinutes,
            dateOfRun: formattedDateOfRun(at: index),
            conditions: logbookConditions(at: index),
            topSpeed: logbookTopSpeed(at: index)
        )
    }
    
    // MARK: Lifetime Stats
    var lifetimeAverages: [[Stat]] {
        return [
            [
                Stat(label: "run vertical", information: calculateAverageVerticalFeet(), systemImageName: "arrow.down"),
                Stat(label: "run distance", information: calculateAverageDistance(), systemImageName: "arrow.right")
            ],
            [
                Stat(label: "speed", information: calculateAverageSpeed(), systemImageName: "speedometer")
            ],
        ]
    }
    
    var lifetimeBest: [[Stat]] {
        return [
            [
                Stat(label: "top speed", information: calculateBestTopSpeed(), systemImageName: "flame"),
                Stat(label: "tallest run", information: calculateBestTallestRun(), systemImageName: "ruler")
            ],
            [
                Stat(label: "longest run", information: calculateBestLongestRun(), systemImageName: "timer"),
            ]
        ]
    }
    
    // Helper methods to calculate the averages and best values
    private func calculateAverageVerticalFeet() -> String {
        let averageVerticalFeet = logbooks.map { $0.verticalDistance }.reduce(0.0) {
            return $0 + $1/Double(logbooks.count)
        }
        
        if averageVerticalFeet >= 1000 {
            return String(format: "%.1fk \(profileManager.measurementSystem.feetOrMeters)", averageVerticalFeet / 1000)
        }
        
        return String(format: "%.0f \(profileManager.measurementSystem.feetOrMeters)", averageVerticalFeet)
    }
    
    private func calculateAverageDistance() -> String {
        let averageDistance = logbooks.map { $0.distance }.reduce(0.0) {
            return $0 + $1/Double(logbooks.count)
        }
        switch profileManager.measurementSystem {
        case .imperial:
            return String(format: "%.1f MI", averageDistance.feetToMiles)
        case .metric:
            return String(format: "%.1f KM", averageDistance.metersToKilometers)
        }
    }
    
    private func calculateAverageSpeed() -> String {
        let averageSpeed = logbooks.map { $0.topSpeed }.reduce(0.0) {
            return $0 + $1/Double(logbooks.count)
        }
        
        return String(format: "%.1f \(profileManager.measurementSystem.milesOrKilometersPerHour)", averageSpeed)
    }
    
    private func calculateBestTopSpeed() -> String {
        return String(format: "%.1f \(profileManager.measurementSystem.milesOrKilometersPerHour)", logbooks.map { $0.topSpeed }.max() ?? 0.0)
    }
    
    private func calculateBestTallestRun() -> String {
        return String(format: "%.1f \(profileManager.measurementSystem.feetOrMeters)", logbooks.map { $0.verticalDistance }.max() ?? 0.0)
    }
    
    private func calculateBestLongestRun() -> String {
        switch profileManager.measurementSystem {
        case .imperial:
            return String(format: "%.1f MI", (logbooks.map { $0.distance }.max() ?? 0.0).feetToMiles)
        case .metric:
            return String(format: "%.1f KM", (logbooks.map { $0.distance }.max() ?? 0.0).metersToKilometers)
        }
    }
}

struct ConfiguredLogbookData {
    let resortName: String
    let numberOfRuns: Int
    let runDurationHour: Int
    let runDurationMinutes: Int
    let dateOfRun: String
    let conditions: String
    let topSpeed: String
}

struct Stat: Hashable, Identifiable {
    let label: String
    var information: String
    let systemImageName: String
    var id: String { information }
}


extension Double {
    var feetToMiles: Self {
        return self / 5280
    }
    
    var metersToKilometers: Self {
        return self / 1000
    }
}
