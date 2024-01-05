//
//  FullLifetimeSummaryView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/28/23.
//

import SwiftUI
import Charts

struct FullLifetimeSummaryView: View {
    @Environment(ProfileManager.self) private var profileManager
    var logbookStats: LogbookStats
    
    @State private var topSpeedRangeData: [(date: Date, min: Double, max: Double)] = []
    @State private var verticalDistanceRangeData: [(date: Date, min: Double, max: Double)] = []
    @State private var altitudeRangeData: [(date: Date, min: Double, max: Double)] = []
    
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
            
            conditionsChart
        }
        .navigationTitle("Lifetime")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            logbookStats.requestLogs {
                topSpeedRangeData = logbookStats.rangeDataPerSession { $0.topSpeed }
                verticalDistanceRangeData = logbookStats.rangeDataPerSession { $0.verticalDistance }
                altitudeRangeData = logbookStats.rangeDataPerSession { $0.maxAltitude }
            }
        }
    }
    
    private func headerForRangeChart(
        title: String,
        units: String,
        rangeData: [(Date, Double, Double)]
    ) -> some View {
        let (earliest, latest, smallest, largest) = logbookStats.maxAndMinOfDateAndValues(fromRangeData: rangeData)
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
                    yStart: .value("Min", yMin),
                    yEnd: .value("Max", yMax)
                )
                .clipShape(Capsule())
                .foregroundStyle(barColor)
            }
        }
        .padding(.top, 5)
    }
    
    @ViewBuilder
    private var conditionsChart: some View {
        let (conditionToCount, topCondition) = logbookStats.conditionsCount()
        Chart(conditionToCount, id: \.condition) { condition, count in
            Plot {
                SectorMark(
                    angle: .value("Value", count),
                    innerRadius: .ratio(0.68),
                    outerRadius: .inset(10),
                    angularInset: 1
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Condition", condition))
            }
        }
        .chartPlotStyle { plotArea in
            plotArea.frame(height: 200)
        }
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let frame = geometry[chartProxy.plotFrame!]
                VStack {
                    Text("Top Condition")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text(topCondition)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                }
                .position(x: frame.midX, y: frame.midY)
            }
        }
    }
}


#Preview {
    FullLifetimeSummaryView(logbookStats: LogbookStats())
}
