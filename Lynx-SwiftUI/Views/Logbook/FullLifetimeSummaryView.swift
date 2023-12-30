//
//  FullLifetimeSummaryView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/28/23.
//

import SwiftUI

struct FullLifetimeSummaryView: View {
    var logbookStats: LogbookStats
    
    var body: some View {
        Form {
            Section {
                sectionInfo(withStats: logbookStats.lifetimeAverages)
            } header: {
                Text("Averages")
            }
            
            Section {
                sectionInfo(withStats: logbookStats.lifetimeBest)
            } header: {
                Text("Best")
            }
        }
        .headerProminence(.increased)
        .navigationTitle("Lifetime")
    }
    
    
    private func sectionInfo(withStats stats: [[Stat]]) -> some View {
        VStack {
            ForEach(stats, id: \.self) { stat in
                rowOfStats(withStats: stat)
            }
            
        }
    }
    
    private func rowOfStats(withStats stats: [Stat]) -> some View {
        HStack {
            ForEach(stats, id: \.self) { stat in
                label(
                    withStat: stat.information,
                    labelText: stat.label,
                    systemImage: stat.systemImageName
                )
                if stat != stats.last || stats.count == 1 {
                    Spacer()
                }
            }
        }
    }
    
    private func label(withStat stat: String, labelText: String, systemImage image: String) -> some View {
        VStack(alignment: .leading) {
            Text(stat)
            Label(labelText, systemImage: image)
                .labelStyle(.titleAndIcon)
        }
        .padding(.vertical)
    }
    
}


#Preview {
    FullLifetimeSummaryView(logbookStats: LogbookStats())
}
