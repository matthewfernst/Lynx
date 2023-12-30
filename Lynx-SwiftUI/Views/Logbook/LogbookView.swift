//
//  LogbookView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI
import OSLog

struct LogbookView: View {
    @Bindable var folderConnectionHandler: FolderConnectionHandler
    @Environment(ProfileManager.self) private var profileManager
    
    var logbookStats: LogbookStats
    
    @State private var showMoreInfo = false
    
    @State private var showUploadFilesSheet = false
    @State private var showUploadProgress = false
    
    @State private var showSlopesFolderAlreadyConnected = false
    
    @State private var showAutoUpload = false
    
    private var slopesFolderIsConnected: Bool {
        BookmarkManager.shared.bookmark != nil
    }

    var body: some View {
        ZStack {
            autoUpload
            NavigationStack {
                VStack {
                    ProfileSummaryView(logbookStats: logbookStats)
                    LifetimeDetailsView(logbookStats: logbookStats)
                    scrollableSessionSummaries
                }
                .navigationTitle("Logbook")
                .toolbar {
                    moreInfoButton
                    documentPickerAndConnectionButton
                }
                .onAppear {
                    BookmarkManager.shared.loadAllBookmarks()
                    requestLogs()
                    checkForNewFilesAndUpload()
                }
                .sheet(isPresented: $showUploadFilesSheet) {
                    FolderConnectionView(
                        showUploadProgressView: $showUploadProgress,
                        folderConnectionHandler: folderConnectionHandler
                    )
                }
                .sheet(isPresented: $showUploadProgress) {
                    requestLogs()
                } content: {
                    FileUploadProgressView(
                        folderConnectionHandler: folderConnectionHandler
                    )
                }
                .alert("Slopes Folder Connected", isPresented: $showSlopesFolderAlreadyConnected) {} message: {
                    Text("When you open the app, we will automatically upload new files to propogate to MountainUI.")
                }
            }
        }
    }
    
    // MARK: - Views
    private var autoUpload: some View {
        VStack {
              Spacer()
                  .frame(height: showAutoUpload ? 0 : 55)
                  .animation(.easeInOut, value: showAutoUpload)
            
            AutoUploadView(
                folderConnectionHandler: folderConnectionHandler,
                showAutoUpload: $showAutoUpload
            )
            .padding(.top, showAutoUpload ? 55 : 0)
            .offset(y: showAutoUpload ? 0 : -UIScreen.main.bounds.height)
            .animation(.easeInOut(duration: 1.25), value: showAutoUpload)

            Spacer()
          }
          .ignoresSafeArea(.all)
          .zIndex(1)
          .opacity(showAutoUpload ? 1 : 0)
          .animation(.easeInOut, value: showAutoUpload)
    }
    
    private var moreInfoButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("More Info", systemImage: "info.circle") {
                showMoreInfo = true
            }
            .confirmationDialog("Slopes Integration", isPresented: $showMoreInfo, titleVisibility: .visible) {
                Link(
                    "What is Slopes?",
                    destination: URL(string: Constants.slopesLink)!
                )
                Link(
                    "What is MountainUI?",
                    destination: URL(string: Constants.mountainUILink)!
                )
            } message:  {
                Text(Constants.slopeIntegrationMessage)
            }
        }
    }
    
    private var documentPickerAndConnectionButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if slopesFolderIsConnected {
                Button("Folder Already Connected", systemImage: "externaldrive.fill.badge.checkmark") {
                    showSlopesFolderAlreadyConnected = true
                }
                .tint(.green)
            } else {
                Button("Connect Folder", systemImage: "folder.badge.plus") {
                    showUploadFilesSheet = true
                }
            }
        }
    }
    
    private var scrollableSessionSummaries: some View {
        List {
            Section {
                if logbookStats.logbooks.isEmpty {
                    Text(Constants.uploadFilesForLogbooksMessage)
                        .multilineTextAlignment(.center)
                } else {
                    NavigationLink {
                        FullLifetimeSummaryView(logbookStats: logbookStats)
                    } label: {
                        lifetimeSummary
                    }
                }
            } header: {
                Text(yearHeader)
                    .padding(.top)
            }
            .headerProminence(.increased)
            
            ForEach(logbookStats.logbooks.indices, id: \.self) { index in
                if let configuredData = logbookStats.getConfiguredLogbookData(at: index) {
                    configuredSessionSummary(with: configuredData)
                }
            }
        }
        .refreshable {
            requestLogs()
        }
    }
    
    private var lifetimeSummary: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.dateAndSummary) {
            Text("Lifetime Summary")
                .font(.system(
                    size: Constants.Fonts.resortNameSize,
                    weight: Constants.Fonts.resortNameWeight
                ))
            HStack {
                Text(
                    "\(logbookStats.lifetimeRuns) runs | \(logbookStats.lifetimeDaysOnMountain) days | \(logbookStats.lifetimeVertical)"
                )
            }
            .foregroundStyle(Color(uiColor: .secondaryLabel))
            .font(.system(
                size: Constants.Fonts.detailSize,
                weight: Constants.Fonts.detailWeight
            ))
        }
    }
    
    private func configuredSessionSummary(with data: ConfiguredLogbookData) -> some View {
        HStack(alignment: .top, spacing: Constants.Spacing.mainTitleAndDetails) {
            Text(data.dateOfRun)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.dateAndSummary) {
                Text(data.resortName)
                    .font(.system(
                        size: Constants.Fonts.resortNameSize,
                        weight: Constants.Fonts.resortNameWeight
                    ))
                HStack {
                    Image(systemName: "figure.snowboarding")
                        .rotationEffect(.radians(.pi / 16))
                    Text(
                        "| \(data.numberOfRuns) runs | \(data.runDurationHour)H \(data.runDurationMinutes)M | \(data.conditions) | \(data.topSpeed)"
                    )
                }
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .font(.system(
                    size: Constants.Fonts.detailSize,
                    weight: Constants.Fonts.detailWeight
                ))
            }
        }
    }
    
    // MARK: - Helpers
    private var yearHeader: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: .now)
        let pastYear = String((Int(currentYear) ?? 0) - 1)
        return "\(pastYear)/\(currentYear)"
    }
    
    private func requestLogs() {
        if !showAutoUpload { // only allow upload if we aren't currently uploading
            ApolloLynxClient.clearCache()
            Task {
                ApolloLynxClient.getLogs(
                    measurementSystem: profileManager.measurementSystem
                ) { result in
                    switch result {
                    case .success(let logs):
                        Logger.logbook.debug("Updating new logbook stats")
                        logbookStats.logbooks = logs
                    case .failure(let error):
                        Logger.logbook.error("Failed to get logs: \(error)")
                    }
                }
            }
        }
    }
    
    private func checkForNewFilesAndUpload() {
        if let url = BookmarkManager.shared.bookmark?.url {
            folderConnectionHandler.getNonUploadedSlopeFiles(forURL: url) { files in
                if let files {
                    showAutoUpload = true
                    
                    folderConnectionHandler.uploadNewFiles(files) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.25) { // give time for Lambda's to fire and animation to end
                            requestLogs()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Constants
    private struct Constants {
        static let slopeIntegrationMessage = """
                           Lynx works together with the Slopes App by Breakpoint Studios. Slopes is able to track a skier or snowboarder while they shred it down the mountain. Slopes can track things such as average speed, total vertical feet, and more. Lynx uses the data stored by Slopes and links to your MountainUI display.
                       """
        static let mountainUILink = "https://github.com/matthewfernst/Mountain-UI"
        static let slopesLink = "https://getslopes.com"
        
        static let uploadFilesForLogbooksMessage = """
                                                   Upload files to see run statistics, leaderboards, and all other information.
                                                   
                                                   To get started, press the folder button in the top right of this screen and connect to your Slopes folder.
                                                   
                                                   Happy Shreading! 🏂
                                                   """
        
        struct Spacing {
            static let mainTitleAndDetails: CGFloat = 20
            static let dateAndSummary: CGFloat = 4
        }
        
        struct Fonts {
            static let resortNameSize: CGFloat = 18
            static let resortNameWeight: Font.Weight = .medium
            
            static let detailSize: CGFloat = 12
            static let detailWeight: Font.Weight = .medium
        }
    }
}

#Preview {
    LogbookView(folderConnectionHandler: FolderConnectionHandler(), logbookStats: LogbookStats())
}
