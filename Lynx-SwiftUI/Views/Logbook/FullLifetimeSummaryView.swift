import Charts
import SwiftUI

struct FullLifetimeSummaryView: View {
  @Environment(ProfileManager.self) private var profileManager
  var logbookStats: LogbookStats

  @State private var topSpeedRangeData: [(date: Date, min: Double, max: Double)] = []
  @State private var verticalDistanceRangeData: [(date: Date, min: Double, max: Double)] = []
  @State private var altitudeRangeData: [(date: Date, min: Double, max: Double)] = []
  @State private var hasAppeared = false
  @State private var scrollPositionStart: Date = Date()

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

        // Set scroll position to most recent date
        if let mostRecentDate = topSpeedRangeData.max(by: { $0.date < $1.date })?.date {
          scrollPositionStart = mostRecentDate
        }

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
    // Calculate total sum of max values
    let total = rangeData.reduce(0.0) { $0 + $1.2 }

    return VStack(alignment: .leading) {
      Text(title)
      Text(formatTotal(total, forTitle: title))
        .font(.system(.title, design: .rounded))
        .foregroundColor(.primary)
        + Text(" \(units)")
    }
    .fontWeight(.semibold)
  }

  private func formatTotal(_ value: Double, forTitle title: String) -> String {
    if title == "Top Speed" {
      // Top speed should show average, not sum
      let count = topSpeedRangeData.count
      let average = count > 0 ? value / Double(count) : 0
      return String(format: "%.1f", average)
    } else {
      // Vertical Distance and Altitude show total
      if value >= 1000 {
        return String(format: "%.1fk", value / 1000)
      }
      return String(format: "%.0f", value)
    }
  }

  private func chartForRangeData(
    rangeData data: [(date: Date, Double, Double)],
    barColor: Color
  ) -> some View {
    let segmentedData = segmentDataByGaps(data: data, maxGapMonths: 3)
    let oneYearInSeconds: TimeInterval = 365 * 24 * 60 * 60

    let chart = Chart {
      ForEach(Array(segmentedData.enumerated()), id: \.offset) { segmentIndex, segment in
        ForEach(segment, id: \.date) { date, yMin, yMax in
          LineMark(
            x: .value("Day", date, unit: .day),
            y: .value("Max", hasAppeared ? yMax : 0),
            series: .value("Segment", segmentIndex)
          )
          .foregroundStyle(barColor)
          .interpolationMethod(.catmullRom)
          .lineStyle(StrokeStyle(lineWidth: 2.5))
          .symbol {
            Circle()
              .fill(barColor)
              .frame(width: 6, height: 6)
          }

          AreaMark(
            x: .value("Day", date, unit: .day),
            yStart: .value("Min", hasAppeared ? yMin : 0),
            yEnd: .value("Max", hasAppeared ? yMax : 0),
            series: .value("Segment", segmentIndex)
          )
          .foregroundStyle(barColor.opacity(0.15))
          .interpolationMethod(.catmullRom)
        }
      }
    }

    return chart
      .chartScrollableAxes(.horizontal)
      .chartXVisibleDomain(length: oneYearInSeconds)
      .chartScrollPosition(initialX: scrollPositionStart)
      .chartYScale(domain: .automatic(includesZero: false))
      .frame(height: 240)
      .padding(.top, 5)
      .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasAppeared)
      .animation(.spring(response: 0.6, dampingFraction: 0.8), value: data.count)
  }

  private func segmentDataByGaps(
    data: [(date: Date, Double, Double)],
    maxGapMonths: Int
  ) -> [[(date: Date, Double, Double)]] {
    guard !data.isEmpty else { return [] }

    let sortedData = data.sorted { $0.date < $1.date }
    var segments: [[(date: Date, Double, Double)]] = []
    var currentSegment: [(date: Date, Double, Double)] = []

    for (index, item) in sortedData.enumerated() {
      if index == 0 {
        currentSegment.append(item)
      } else {
        let previousDate = sortedData[index - 1].date
        let currentDate = item.date

        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: previousDate, to: currentDate)
        let monthDifference = abs(components.month ?? 0)

        if monthDifference > maxGapMonths {
          if !currentSegment.isEmpty {
            segments.append(currentSegment)
          }
          currentSegment = [item]
        } else {
          currentSegment.append(item)
        }
      }
    }

    if !currentSegment.isEmpty {
      segments.append(currentSegment)
    }

    return segments
  }
}

#Preview {
  FullLifetimeSummaryView(logbookStats: LogbookStats())
}
