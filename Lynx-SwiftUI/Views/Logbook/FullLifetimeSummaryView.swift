import Charts
import SwiftUI

struct FullLifetimeSummaryView: View {
  @Environment(ProfileManager.self) private var profileManager
  var logbookStats: LogbookStats

  @State private var topSpeedRangeData: [(date: Date, min: Double, max: Double)] = []
  @State private var verticalDistanceRangeData: [(date: Date, min: Double, max: Double)] = []
  @State private var altitudeRangeData: [(date: Date, min: Double, max: Double)] = []
  @State private var hasAppeared = false

  var body: some View {
    List {
      Section(
        header: headerForRangeChart(
          title: "Top Speed",
          units: profileManager.measurementSystem.milesOrKilometersPerHour,
          rangeData: topSpeedRangeData
        )
      ) {
        chartForRangeData(rangeData: topSpeedRangeData, barColor: .red)
      }

      Section(
        header: headerForRangeChart(
          title: "Vertical Distance",
          units: profileManager.measurementSystem.feetOrMeters,
          rangeData: verticalDistanceRangeData
        )
      ) {
        chartForRangeData(rangeData: verticalDistanceRangeData, barColor: .blue)
      }

      Section(
        header: headerForRangeChart(
          title: "Altitude",
          units: profileManager.measurementSystem.feetOrMeters,
          rangeData: altitudeRangeData
        )
      ) {
        chartForRangeData(rangeData: altitudeRangeData, barColor: .green)
      }
    }
    .navigationTitle("Lifetime")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      logbookStats.requestLogs { _ in
        topSpeedRangeData = logbookStats.rangeDataPerSession { $0.topSpeed }
        verticalDistanceRangeData = logbookStats.rangeDataPerSession { $0.verticalDistance }
        altitudeRangeData = logbookStats.rangeDataPerSession { $0.maxAltitude }

        withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.1)) {
          hasAppeared = true
        }
      }
    }
  }

  private func headerForRangeChart(
    title: String,
    units: String,
    rangeData: [(Date, Double, Double)]
  ) -> some View {
    let (earliest, latest, smallest, largest) = logbookStats.maxAndMinOfDateAndValues(
      fromRangeData: rangeData)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, yyyy"

    return VStack(alignment: .leading) {
      Text(title)
      Text("\(smallest, specifier: "%.1f") - \(largest, specifier: "%.1f") ")
        .font(.system(.title, design: .rounded))
        .foregroundColor(.primary)
        + Text(units)

      Text("\(dateFormatter.string(from: earliest)) - ") + Text(dateFormatter.string(from: latest))
    }
    .fontWeight(.semibold)
  }

  private func chartForRangeData(
    rangeData data: [(date: Date, Double, Double)],
    barColor: Color
  ) -> some View {
    Chart(data, id: \.date) { date, yMin, yMax in
      Plot {
        BarMark(
          x: .value("Day", date, unit: .day),
          yStart: .value("Min", hasAppeared ? yMin : yMax),
          yEnd: .value("Max", yMax)
        )
        .clipShape(Capsule())
        .foregroundStyle(barColor)
        .opacity(hasAppeared ? 1.0 : 0.3)
      }
    }
    .padding(.top, 5)
    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasAppeared)
    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: data.count)
  }
}

#Preview {
  FullLifetimeSummaryView(logbookStats: LogbookStats())
}
