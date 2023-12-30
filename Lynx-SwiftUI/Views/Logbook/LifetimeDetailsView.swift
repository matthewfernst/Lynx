//
//  LifetimeDetailsView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct LifetimeDetailsView: View {
    var logbookStats: LogbookStats
    
    var body: some View {
        HStack {
            detailView(
                withStat: logbookStats.lifetimeDaysOnMountain,
                andText: "days"
            )
            detailView(
                withStat: logbookStats.lifetimeRunsTime,
                andText: "time on runs"
            )
            detailView(
                withStat: logbookStats.lifetimeRuns,
                andText: "runs"
            )
        }
    }
    private func detailView(withStat stat: String, andText text: String) -> some View {
        VStack {
            Text(stat)
                .font(.system(size: 22, weight: .bold))
            Text(text)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LifetimeDetailsView(logbookStats: LogbookStats())
}
