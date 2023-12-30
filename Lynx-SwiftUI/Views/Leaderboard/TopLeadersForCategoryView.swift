//
//  CategoryTopLeadersView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/9/23.
//

import SwiftUI
import Charts

struct TopLeadersForCategoryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ProfileManager.self) private var profileManager
    
    @State private var range: (Double, Double)? = nil
    private var rangeFormattedLabel: (String, String)? {
        guard let range = range else { return nil }
        
        return (
            LeaderAttributes.formattedStatLabel(
                range.0,
                forCategory: category,
                withMeasurementSystem: profileManager.measurementSystem
            ),
            LeaderAttributes.formattedStatLabel(
                range.1,
                forCategory: category,
                withMeasurementSystem: profileManager.measurementSystem
            )
        )
    }
    
    @State private var goToMoreInfo = false
    @State private var showFailedToGetAllLeaders = false
    
    let topLeaders: [LeaderAttributes]
    let category: LeaderboardCategory
    
    var body: some View {
        GroupBox {
            if topLeaders.isEmpty {
                Text("No Leaders Yet")
                    .frame(height: Constants.Chart.height)
            } else {
                chartOfTopLeaders
            }
        } label: {
            chartLabel
        }
        .navigationDestination(isPresented: $goToMoreInfo) {
            AllLeadersForCategoryView(category: category)
        }
        .alert("Failed to Get All Leaders", isPresented: $showFailedToGetAllLeaders, actions: {})
        .padding(.bottom)
        .listRowSeparator(.hidden)
    }
    
    private var chartOfTopLeaders: some View {
        Chart {
            ForEach(topLeaders.indices, id: \.self) { index in
                BarMark(
                    x: .value("Stat", topLeaders[index].stat),
                    y: .value("Name", topLeaders[index].fullName)
                )
                .foregroundStyle([Color.blue, .green, .orange][index])
            }
            
            if let range, let rangeFormattedLabel {
                RectangleMark(
                    xStart: .value("Start Stat", range.0),
                    xEnd: .value("End Stat", range.1)
                )
                .foregroundStyle(Color.gray.opacity(Constants.Chart.brushOpacity))
                .offset(yStart: Constants.Chart.Popover.yOffset)
                .zIndex(-1)
                .annotation(
                    position: .top, spacing: Constants.Chart.Popover.spacing,
                    overflowResolution: .init(
                        x: .fit(to: .chart),
                        y: .disabled
                    )
                ) {
                    RoundedRectangle(cornerRadius: Constants.Chart.Popover.cornerRadius)
                        .fill(.windowBackground)
                        .overlay(
                            Text("\(rangeFormattedLabel.0) - \(rangeFormattedLabel.1)")
                                .font(.caption)
                        )
                        .frame(
                            width: category == LeaderboardCategory.runCount() ? Constants.Chart.Popover.runCountWidth : Constants.Chart.Popover.width,
                            height: Constants.Chart.Popover.height
                        )
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let xAxisValue = value.as(Double.self) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(
                        LeaderAttributes.formattedStatLabel(
                            xAxisValue,
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
            plotArea.frame(height: Constants.Chart.height)
        }
        .chartOverlay { proxy in
            GeometryReader { g in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(DragGesture()
                        .onChanged { value in
                            let startX = value.startLocation.x - g[proxy.plotFrame!].origin.x
                            let currentX = value.location.x - g[proxy.plotFrame!].origin.x
                            
                            if let startStat: Double = proxy.value(atX: startX),
                               let endStat: Double = proxy.value(atX: currentX) {
                                range = (startStat, endStat)
                            }
                        }
                        .onEnded { _ in range = nil }
                    )
            }
        }
    }
    
    private var chartLabel: some View {
        HStack {
            Label(
                category.headerLabelText.capitalized,
                systemImage: category.headerSystemImage
            )
            Spacer()
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.gray)
                .frame(width: 7)
                .onTapGesture {
                    goToMoreInfo.toggle()
                }
        }
    }
    
    private struct Constants {
        struct Chart {
            static let height: CGFloat = 180
            static let brushOpacity: CGFloat = 0.3
            
            struct Popover {
                static let cornerRadius: CGFloat = 15
                static let spacing: CGFloat = 4
                static let yOffset: CGFloat = -4
                static let height: CGFloat = 35
                static let width: CGFloat = 130
                static let runCountWidth: CGFloat = 50
            }
        }
        
        struct Font {
            static let nameSize: CGFloat = 20
            static let spacing: CGFloat = 5
        }
    }
}

//
//#Preview {
//    let debugURL = ProfileManager.Constants.defaultProfilePictureURL
//    return TopLeadersForCategoryView(
//        leaders: [
//            .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: 240_612),
//            .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: 154_712),
//            .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: 50_412)
//        ],
//        category: LeaderboardCategory.distance()
//    )
//}

