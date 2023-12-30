//
//  AllLeadersForCategoryView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/9/23.
//

import SwiftUI
import Charts

struct AllLeadersForCategoryView: View {
    @Environment(ProfileManager.self) private var profileManager
    let category: LeaderboardCategory
    @State private var leaders: [LeaderAttributes] = []
    
    @State private var timeframe: Timeframe = .allTime

    var body: some View {
        VStack {
            allLeadersCharts
            listOfLeaders
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            populateLeaders()
        }
        .onChange(of: timeframe) { _, _ in
            populateLeaders()
        }
    }
    
    
    private var timeframePicker: some View {
        Picker("Timeframe", selection: $timeframe) {
            Text("Day").tag(Timeframe.day)
            Text("Week").tag(Timeframe.week)
            Text("Month").tag(Timeframe.month)
            Text("Season").tag(Timeframe.season)
            Text("All-Time").tag(Timeframe.allTime)
        }
        .pickerStyle(.segmented)
    }
    
    private var allLeadersCharts: some View {
        VStack(alignment: .leading) {
            Label(category.headerLabelText, systemImage: category.headerSystemImage)
                .fontWeight(.bold)
            Divider()
            timeframePicker
                .padding(.bottom)
            if leaders.isEmpty {
                Text("No Leaders Yet")
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
            } else {
                chartView
            }
        }
        .padding()
    }
    
    private var chartView: some View {
        Chart {
            ForEach(leaders) { leader in
                BarMark(
                    x: .value("Name", leader.fullName),
                    y: .value("Stat", leader.stat)
                )
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                if let yAxisValue = value.as(Double.self) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(
                        LeaderAttributes.formattedStatLabel(
                            yAxisValue,
                            forCategory: category,
                            withMeasurementSystem: profileManager.measurementSystem
                        )
                    )
                } else {
                    AxisGridLine()
                }
            }
        }
        .chartPlotStyle { plotArea in
            plotArea.frame(height: 180)
        }
    }
    
    private var listOfLeaders: some View {
        List {
            ForEach(leaders.indices, id: \.self) { index in
                let rank = index < 3 ? index + 1 : nil
                LeaderView(
                    category: category,
                    attributes: leaders[index],
                    rank: rank
                )
            }
        }
        .refreshable {
            populateLeaders()
        }
    }
    
    
    private func populateLeaders() {
        ApolloLynxClient.getSpecificLeaderboardAllTime(
            for: timeframe,
            sortBy: category.correspondingSort,
            inMeasurementSystem: profileManager.measurementSystem
        ) { result in
            switch result {
            case .success(let attributes):
                leaders = attributes
            case .failure(_):
                print()
            }
        }
    }
    
}

/// To be honest, no idea why this looks wack here, but it works :)
struct LeaderView: View {
    @Environment(ProfileManager.self) private var profileManager
    @Environment(\.colorScheme) private var colorScheme
    
    let category: LeaderboardCategory
    let attributes: LeaderAttributes
    let rank: Int?
    
    var body: some View {
        HStack {
            profilePicture
            nameAndStat
        }
    }
    
    @ViewBuilder
    private var profilePicture: some View {
        AsyncImage(url: attributes.profilePictureURL) { image in
            GeometryReader { geometry in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                
                if let rank = rank {
                    let (rankImageName, rankColor, rankImageWidth) = Constants.Rank.rankImageNameAndColor[rank - 1]
                    Circle()
                        .overlay(
                            Image(systemName: rankImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: rankImageWidth)
                                .foregroundStyle(rankColor)
                        )
                        .frame(maxWidth: Constants.ProfilePicture.medalBackgroundWidth)
                        .foregroundStyle(
                            Color(uiColor: colorScheme == .light ? .tertiarySystemGroupedBackground : .systemBackground)
                        )
                        .offset(
                            x: geometry.size.width / Constants.ProfilePicture.xMedalOffsetDivisor,
                            y: geometry.size.height / Constants.ProfilePicture.yMedalOffsetDivisor
                        )
                }
            }
        } placeholder: {
            ProgressView()
        }
        .frame(maxWidth: Constants.ProfilePicture.imageWidth)
    }
    
    private var nameAndStat: some View {
        VStack(spacing: Constants.Font.spacing) {
            Text(attributes.fullName)
                .font(.system(size: Constants.Font.nameSize, weight: .medium))
            Text(
                LeaderAttributes.formattedStatLabel(
                    attributes.stat,
                    forCategory: category,
                    withMeasurementSystem: profileManager.measurementSystem
                )
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private struct Constants {
        struct Rank {
            static let rankImageNameAndColor: [(String, Color, CGFloat)] = [
                ("crown.fill", .gold, 15),
                ("medal.fill", .silver, 13),
                ("medal.fill", .bronze, 13)
            ]
        }
        
        struct ProfilePicture {
            static let imageWidth: CGFloat = 60
            static let medalBackgroundWidth: CGFloat = 20
            static let xMedalOffsetDivisor: CGFloat = 1.5
            static let yMedalOffsetDivisor: CGFloat = 1.5
        }
        
        struct Font {
            static let nameSize: CGFloat = 20
            static let spacing: CGFloat = 5
        }
    }
}

extension Color {
    static let gold = Color(red: 219 / 255, green: 172 / 255, blue: 52 / 255)
    static let silver = Color(red: 170 / 255 , green: 169 / 255, blue: 173 / 255)
    static let bronze = Color(red: 205 / 255 , green: 127 / 255, blue: 50 / 255)
}

//#Preview {
//    let debugURL = ProfileManager.Constants.defaultProfilePictureURL
//    return AllLeadersForCategoryView(
//        category: .distance(),
//        leaders: [
//            .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: 240_609),
//            .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: 154_712),
//            .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: 50_409),
//            .init(fullName: "Sully Sullivian", profilePictureURL: debugURL, stat: 5_431),
//            .init(fullName: "Matthew Ernst", profilePictureURL: debugURL, stat: 4_212),
//            .init(fullName: "Christine Perich", profilePictureURL: debugURL, stat: 0),
//        ]
//    )
//}
