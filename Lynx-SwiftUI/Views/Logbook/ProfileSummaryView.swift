//
//  ProfileSummaryView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct ProfileSummaryView: View {
    @Environment(ProfileManager.self) private var profileManager
    var logbookStats: LogbookStats
    
    var body: some View {
        HStack {
            profilePicture
            lifetimeSummary
        }
    }
    
    @ViewBuilder
    private var profilePicture: some View {
        if let profilePic = profileManager.profilePicture {
            profilePic
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(maxWidth: Constants.Profile.imageWidth)
        } else {
            ProgressView()
                .padding()
        }
    }
    
    private var lifetimeSummary: some View {
        VStack {
            Text(logbookStats.lifetimeVertical)
                .font(.system(size: Constants.Font.statFontSize))
                .fontWeight(.semibold)
            Text("lifetime vertical \(profileManager.measurementSystem.feetOrMeters.lowercased())")
                .font(.system(size: Constants.Font.labelFontSize))
        }
        .padding()
    }
    
    
    private struct Constants {
        struct Font {
            static let statFontSize: CGFloat = 32
            static let labelFontSize: CGFloat = 18
        }
        
        struct Profile {
            static let imageWidth: CGFloat = 110
        }
    }

}

#Preview {
    ProfileSummaryView(logbookStats: LogbookStats())
}
