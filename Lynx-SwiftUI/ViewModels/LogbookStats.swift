import SwiftUI
import OSLog

@Observable final class LogbookStats {
    private var profileManager = ProfileManager.shared
    var logbooks: Logbooks = []
    var isLoadingLogs = false

    func requestLogs(completion: ((Result<Void, Error>) -> Void)? = nil) {
        isLoadingLogs = true
        ApolloLynxClient.clearCache()
        Task {
            ApolloLynxClient.getLogs(
                measurementSystem: profileManager.measurementSystem
            ) { result in
                DispatchQueue.main.async {
                    self.isLoadingLogs = false
                    switch result {
                    case .success(let logs):
                        self.logbooks = logs
                        completion?(.success(()))
                    case .failure(let error):
                        Logger.logbookStats.error("Failed to get logs: \(error)")
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    var lifetimeVertical: String {
        logbooks.lifetimeVertical(measurementSystem: profileManager.measurementSystem)
    }

    var lifetimeDaysOnMountain: String {
        logbooks.lifetimeDaysOnMountain
    }

    var lifetimeRunsTime: String {
        logbooks.lifetimeRunsTime
    }

    var lifetimeRuns: String {
        logbooks.lifetimeRuns
    }
    
    func logbook(at index: Int) -> ApolloGeneratedGraphQL.GetLogsQuery.Data.SelfLookup.Logbook? {
        guard logbooks.indices.contains(index) else { return nil }
        return logbooks[index]
    }

    func getConfiguredLogbookData(at index: Int) -> ConfiguredLogbookData? {
        guard logbooks.indices.contains(index) else { return nil }
        let logbook = logbooks[index]

        // Calculate duration
        let durationInSeconds = Int(logbook.duration)
        let hours = durationInSeconds / 3600
        let minutes = (durationInSeconds % 3600) / 60

        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var dateOfRun = "NA\n"
        if let date = dateFormatter.date(from: String(logbook.startDate.split(separator: " ")[0])) {
            dateFormatter.dateFormat = "MMM\nd"
            dateOfRun = dateFormatter.string(from: date)
        }

        // Format conditions
        var capitalizedConditions = logbook.conditions.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "_", with: " ").capitalized
        }
        if capitalizedConditions.count > 1 {
            capitalizedConditions.removeAll(where: { $0 == "Packed" })
        }
        let conditions = capitalizedConditions.first ?? ""

        return ConfiguredLogbookData(
            resortName: logbook.locationName,
            numberOfRuns: Int(logbook.runCount),
            runDurationHour: hours,
            runDurationMinutes: minutes,
            dateOfRun: dateOfRun,
            conditions: conditions,
            topSpeed: String(format: "%.1f\(profileManager.measurementSystem.milesOrKilometersPerHour)", logbook.topSpeed)
        )
    }
    
    var lifetimeAverages: [[Stat]] {
        logbooks.lifetimeAverages(measurementSystem: profileManager.measurementSystem)
    }

    var lifetimeBest: [[Stat]] {
        logbooks.lifetimeBest(measurementSystem: profileManager.measurementSystem)
    }
    
    func rangeDataPerSession<T>(propertyExtractor: (Logbook.Detail) -> T) -> [(date: Date, min: Double, max: Double)] {
        logbooks.rangeDataPerSession(propertyExtractor: propertyExtractor)
    }

    func maxAndMinOfDateAndValues(fromRangeData data: [(date: Date, min: Double, max: Double)]) -> (earliest: Date, latest: Date, smallest: Double, largest: Double) {
        logbooks.maxAndMinOfDateAndValues(fromRangeData: data)
    }

    func conditionsCount() -> ([(condition: String, count: Double)], String) {
        logbooks.conditionsCount()
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

// MARK: - Logbooks Extensions (View-level computed properties)
extension Logbooks {
    func lifetimeVertical(measurementSystem: MeasurementSystem) -> String {
        let totalVerticalFeet = self.map { $0.verticalDistance }.reduce(0, +)
        guard totalVerticalFeet > 0 else { return "--" }

        if totalVerticalFeet >= 1000 {
            return String(format: "%.1fk", totalVerticalFeet / 1000)
        }
        return String(format: "%.0f", totalVerticalFeet)
    }

    var lifetimeDaysOnMountain: String {
        let totalDays = self.count
        return totalDays == 0 ? "--" : String(totalDays)
    }

    var lifetimeRunsTime: String {
        let totalHours = Int(self.map { $0.duration / 3600 }.reduce(0, +))
        if totalHours == 0 { return "--" }
        return "\(totalHours)H"
    }

    var lifetimeRuns: String {
        let totalRuns = self.map { Int($0.runCount) }.reduce(0, +)
        return totalRuns == 0 ? "--" : String(totalRuns)
    }

    func lifetimeAverages(measurementSystem: MeasurementSystem) -> [[Stat]] {
        // Average vertical feet
        let averageVerticalFeet: String = {
            guard !self.isEmpty else { return "--" }
            let average = self.map { $0.verticalDistance }.reduce(0.0, +) / Double(self.count)

            if average >= 1000 {
                return String(format: "%.1fk \(measurementSystem.feetOrMeters)", average / 1000)
            }
            return String(format: "%.0f \(measurementSystem.feetOrMeters)", average)
        }()

        // Average distance
        let averageDistance: String = {
            guard !self.isEmpty else { return "--" }
            let average = self.map { $0.distance }.reduce(0.0, +) / Double(self.count)

            switch measurementSystem {
            case .imperial:
                return String(format: "%.1f MI", average.feetToMiles)
            case .metric:
                return String(format: "%.1f KM", average.metersToKilometers)
            }
        }()

        // Average speed
        let averageSpeed: String = {
            guard !self.isEmpty else { return "--" }
            let average = self.map { $0.topSpeed }.reduce(0.0, +) / Double(self.count)
            return String(format: "%.1f \(measurementSystem.milesOrKilometersPerHour)", average)
        }()

        return [
            [
                Stat(label: "run vertical", information: averageVerticalFeet, systemImageName: "arrow.down"),
                Stat(label: "run distance", information: averageDistance, systemImageName: "arrow.right")
            ],
            [
                Stat(label: "speed", information: averageSpeed, systemImageName: "speedometer")
            ],
        ]
    }

    func lifetimeBest(measurementSystem: MeasurementSystem) -> [[Stat]] {
        // Top speed
        let topSpeed = String(format: "%.1f \(measurementSystem.milesOrKilometersPerHour)", self.map { $0.topSpeed }.max() ?? 0.0)

        // Tallest run
        let tallestRun = String(format: "%.1f \(measurementSystem.feetOrMeters)", self.map { $0.verticalDistance }.max() ?? 0.0)

        // Longest run
        let longestRun: String = {
            switch measurementSystem {
            case .imperial:
                return String(format: "%.1f MI", (self.map { $0.distance }.max() ?? 0.0).feetToMiles)
            case .metric:
                return String(format: "%.1f KM", (self.map { $0.distance }.max() ?? 0.0).metersToKilometers)
            }
        }()

        return [
            [
                Stat(label: "top speed", information: topSpeed, systemImageName: "flame"),
                Stat(label: "tallest run", information: tallestRun, systemImageName: "ruler")
            ],
            [
                Stat(label: "longest run", information: longestRun, systemImageName: "timer"),
            ]
        ]
    }

    func conditionsCount() -> ([(condition: String, count: Double)], String) {
        let conditionsCount = self
            .compactMap { $0.conditions }
            .flatMap { $0 }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).sanitize.capitalized }
            .reduce(into: [:]) { counts, condition in
                counts[condition, default: 0] += 1
            }

        let resultsArray = conditionsCount.map { (condition, count) in
            (condition: condition, count: Double(count))
        }

        return (resultsArray, resultsArray.max(by: { $0.count < $1.count })?.condition ?? "")
    }

    func rangeDataPerSession<T>(propertyExtractor: (Logbook.Detail) -> T) -> [(date: Date, min: Double, max: Double)] {
        var rangeData: [(Date, Double, Double)] = []
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        for logbook in self {
            let propertyValues: [Double] = logbook.details.map { propertyExtractor($0) as! Double }

            rangeData.append(
                (
                    date: dateFormatter.date(from: logbook.startDate)!,
                    min: propertyValues.min() ?? 0.0,
                    max: propertyValues.max() ?? 0.0
                )
            )
        }
        rangeData.sort(by: { $0.0 < $1.0})
        return rangeData
    }

    func maxAndMinOfDateAndValues(fromRangeData data: [(date: Date, min: Double, max: Double)]) -> (earliest: Date, latest: Date, smallest: Double, largest: Double) {
        var earliest: Date = .distantFuture
        var latest: Date = .distantPast

        var smallest: Double = .infinity
        var largest: Double = -.infinity

        for (date, yMin, yMax) in data {
            earliest = Swift.min(earliest, date)
            latest = Swift.max(latest, date)

            smallest = Swift.min(smallest, yMin)
            largest = Swift.max(largest, yMax)
        }

        return (earliest, latest, smallest, largest)
    }
}
