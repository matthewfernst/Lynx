import SwiftUI
import OSLog

struct LogbookView: View {
    @Bindable var folderConnectionHandler: FolderConnectionHandler
    @Environment(ProfileManager.self) private var profileManager

    var logbookStats: LogbookStats

    @State private var showUploadFilesSheet = false
    @State private var showUploadProgress = false

    @State private var showSlopesFolderAlreadyConnected = false

    @State private var showAutoUpload = false

    @State private var showProfile = false
    @State private var showLoadError = false
    @State private var showNotifications = false
    @State private var partyHandler = PartyHandler()

    private var slopesFolderIsConnected: Bool {
        BookmarkManager.shared.bookmark != nil
    }

    var body: some View {
        ZStack {
            autoUpload
            NavigationStack {
                scrollableSessionSummaries
                    .navigationTitle("Logbook")
                .toolbar {
                    documentPickerAndConnectionButton
                    notificationsButton
                    profileButton
                }
                .task {
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
                .alert("Unable to Load Logs", isPresented: $showLoadError) {
                    Button("Retry") {
                        requestLogs()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("We couldn't load your ski logs. Please check your internet connection and try again.")
                }
                .sheet(isPresented: $showProfile) {
                    AccountView()
                }
                .sheet(isPresented: $showNotifications) {
                    NavigationStack {
                        PartyInvitesView(partyHandler: partyHandler)
                    }
                }
                .task {
                    partyHandler.fetchPartyInvites()
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
    
    private var documentPickerAndConnectionButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
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

    private var notificationsButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                showNotifications = true
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                    if !partyHandler.partyInvites.isEmpty {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
    }

    private var profileButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ProfileButton(showProfile: $showProfile)
        }
    }

    private var scrollableSessionSummaries: some View {
        List {
            if logbookStats.logbooks.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Text(Constants.noLogsMessage)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)

                        Button {
                            showUploadFilesSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                Text("Link Your Account")
                            }
                            .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                }
            } else {
                // Stats section
                Section {
                    LifetimeDetailsView(logbookStats: logbookStats)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                // All-time summary section
                Section {
                    NavigationLink {
                        FullLifetimeSummaryView(logbookStats: logbookStats)
                    } label: {
                        lifetimeSummary
                    }
                }

                // Grouped by season sections
                ForEach(logsBySeasonGrouped, id: \.season) { seasonGroup in
                    Section {
                        ForEach(seasonGroup.logs, id: \.index) { logItem in
                            if let logbook = logbookStats.logbook(at: logItem.index) {
                                NavigationLink {
                                    LogDetailView(logbook: logbook, logbookStats: logbookStats)
                                } label: {
                                    configuredSessionSummary(with: logItem.data)
                                }
                            }
                        }
                    } header: {
                        Text(seasonGroup.season)
                            .padding(.top)
                    }
                    .headerProminence(.increased)
                }
            }
        }
        .refreshable {
            requestLogs()
        }
    }
    
    private var lifetimeSummary: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.dateAndSummary) {
            Text("Overview")
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
    private var logsBySeasonGrouped: [(season: String, logs: [(index: Int, data: ConfiguredLogbookData)])] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        // Group logs by season with dates for sorting
        var seasonGroups: [String: [(index: Int, data: ConfiguredLogbookData, date: Date)]] = [:]

        for (index, logbook) in logbookStats.logbooks.enumerated() {
            guard let date = dateFormatter.date(from: logbook.startDate),
                  let configuredData = logbookStats.getConfiguredLogbookData(at: index) else {
                continue
            }

            let calendar = Calendar.current
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)

            let (firstYear, secondYear): (Int, Int)
            if month >= 10 { // October-December: current/next year season
                firstYear = year
                secondYear = year + 1
            } else { // January-September: previous/current year season
                firstYear = year - 1
                secondYear = year
            }

            let seasonKey = "\(firstYear)/\(secondYear)"
            seasonGroups[seasonKey, default: []].append((index, configuredData, date))
        }

        // Sort seasons and logs in descending order (newest first)
        return seasonGroups
            .map { (
                season: $0.key,
                logs: $0.value
                    .sorted { $0.date > $1.date }
                    .map { (index: $0.index, data: $0.data) }
            ) }
            .sorted { $0.season > $1.season }
    }

    private var yearHeader: String {
        guard !logbookStats.logbooks.isEmpty else {
            // No logs, show current ski season
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let currentYear = dateFormatter.string(from: .now)
            let pastYear = String((Int(currentYear) ?? 0) - 1)
            return "\(pastYear)/\(currentYear)"
        }

        // Get the most recent log date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        let logDates = logbookStats.logbooks.compactMap { logbook -> Date? in
            dateFormatter.date(from: logbook.startDate)
        }

        guard let mostRecentDate = logDates.max() else {
            // Fallback to current season if we can't parse dates
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let currentYear = yearFormatter.string(from: .now)
            let pastYear = String((Int(currentYear) ?? 0) - 1)
            return "\(pastYear)/\(currentYear)"
        }

        // Calculate ski season based on the most recent log date
        // Ski season runs roughly October-April
        let calendar = Calendar.current
        let month = calendar.component(.month, from: mostRecentDate)
        let year = calendar.component(.year, from: mostRecentDate)

        let (firstYear, secondYear): (Int, Int)
        if month >= 10 { // October-December: current/next year season
            firstYear = year
            secondYear = year + 1
        } else { // January-September: previous/current year season
            firstYear = year - 1
            secondYear = year
        }

        return "\(firstYear)/\(secondYear)"
    }
    
    private func requestLogs() {
        if !showAutoUpload { // only allow upload if we aren't currently uploading
            logbookStats.requestLogs { result in
                switch result {
                case .success:
                    break
                case .failure:
                    showLoadError = true
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
        static let noLogsMessage = """
                                   No logs found. Link your Slopes folder to start tracking your runs, view leaderboards, and see all your ski statistics.

                                   Happy Shredding! 🏂
                                   """

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
