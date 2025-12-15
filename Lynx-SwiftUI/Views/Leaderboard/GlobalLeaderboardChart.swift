import SwiftUI
import Charts

struct GlobalLeaderboardChart: View {
    let leaders: [LeaderAttributes]
    let sortBy: LeaderboardSort
    let measurementSystem: MeasurementSystem

    private var topTen: [LeaderAttributes] {
        Array(leaders.prefix(10))
    }

    private var chartData: [(name: String, value: Double)] {
        topTen.map { leader in
            let value = leader.stat
            let name = "\(leader.firstName) \(leader.lastName)"
            return (name: name, value: value)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: categoryIcon)
                    .foregroundStyle(.blue)
                Text(categoryLabel)
                    .font(.headline)
                Spacer()
            }

            if chartData.isEmpty {
                Text("No data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                        BarMark(
                            x: .value("Value", data.value),
                            y: .value("Name", data.name)
                        )
                        .foregroundStyle(colorForRank(index))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        if let xValue = value.as(Double.self) {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(formatValue(xValue))
                        }
                    }
                }
                .frame(height: 300)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var categoryLabel: String {
        switch sortBy {
        case .verticalDistance: return "Vertical Distance"
        case .distance: return "Distance"
        case .topSpeed: return "Top Speed"
        case .runCount: return "Run Count"
        }
    }

    private var categoryIcon: String {
        switch sortBy {
        case .verticalDistance: return "arrow.up"
        case .distance: return "arrow.left.and.right"
        case .topSpeed: return "speedometer"
        case .runCount: return "figure.snowboarding"
        }
    }

    private func colorForRank(_ index: Int) -> Color {
        switch index {
        case 0: return .blue
        case 1: return .green
        case 2: return .orange
        default: return .gray
        }
    }

    private func formatValue(_ value: Double) -> String {
        switch sortBy {
        case .verticalDistance:
            if value >= 1000 {
                return String(format: "%.1fk \(measurementSystem.feetOrMeters)", value / 1000)
            }
            return String(format: "%.0f \(measurementSystem.feetOrMeters)", value)
        case .distance:
            switch measurementSystem {
            case .imperial:
                return String(format: "%.1f mi", value.feetToMiles)
            case .metric:
                return String(format: "%.1f km", value.metersToKilometers)
            }
        case .topSpeed:
            return String(format: "%.1f \(measurementSystem.milesOrKilometersPerHour)", value)
        case .runCount:
            return "\(Int(value))"
        }
    }
}
