import SwiftUI
import Charts
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

    @State private var expandedSeasons: Set<String> = []

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
            }
        }
    }
    
    // MARK: - Views
    private var autoUpload: some View {
        VStack {
              Spacer()
                  .frame(height: showAutoUpload && !folderConnectionHandler.isUploadingInBackground ? 0 : 55)
                  .animation(.easeInOut, value: showAutoUpload)

            // Only show compact overlay if NOT doing background upload
            if showAutoUpload && !folderConnectionHandler.isUploadingInBackground {
                AutoUploadView(
                    folderConnectionHandler: folderConnectionHandler,
                    showAutoUpload: $showAutoUpload
                )
                .padding(.top, showAutoUpload ? 55 : 0)
                .offset(y: showAutoUpload ? 0 : -UIScreen.main.bounds.height)
                .animation(.easeInOut(duration: 1.25), value: showAutoUpload)
            }

            Spacer()
          }
          .ignoresSafeArea(.all)
          .zIndex(1)
          .opacity(showAutoUpload && !folderConnectionHandler.isUploadingInBackground ? 1 : 0)
          .animation(.easeInOut, value: showAutoUpload)
    }
    
    private var documentPickerAndConnectionButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if slopesFolderIsConnected {
                Button {
                    showSlopesFolderAlreadyConnected = true
                } label: {
                    ZStack {
                        // Background icon
                        Image(systemName: "externaldrive.fill.badge.checkmark")
                            .foregroundStyle(.green)

                        // Progress overlay when uploading in background
                        if folderConnectionHandler.isUploadingInBackground {
                            Circle()
                                .trim(from: 0.0, to: folderConnectionHandler.uploadProgress)
                                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(-90))
                                .frame(width: 35, height: 35)
                                .animation(.easeInOut, value: folderConnectionHandler.uploadProgress)
                        }
                    }
                }
            } else {
                Button("Connect Folder", systemImage: "folder.badge.plus") {
                    showUploadFilesSheet = true
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
        Group {
            if logbookStats.isLoadingLogs {
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Loading Ski Logs...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
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

                // Conditions chart section
                Section {
                    conditionsChart
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
                        let isExpanded = expandedSeasons.contains(seasonGroup.season)
                        let logsToShow = isExpanded ? seasonGroup.logs : Array(seasonGroup.logs.prefix(3))

                        ForEach(logsToShow, id: \.index) { logItem in
                            if let logbook = logbookStats.logbook(at: logItem.index) {
                                NavigationLink {
                                    LogDetailView(logbook: logbook, logbookStats: logbookStats)
                                } label: {
                                    configuredSessionSummary(with: logItem.data)
                                }
                            }
                        }

                        if seasonGroup.logs.count > 3 {
                            Button(action: {
                                withAnimation {
                                    if isExpanded {
                                        expandedSeasons.remove(seasonGroup.season)
                                    } else {
                                        expandedSeasons.insert(seasonGroup.season)
                                    }
                                }
                            }) {
                                HStack {
                                    Text(isExpanded ? "Show Less" : "Show More (\(seasonGroup.logs.count - 3))")
                                        .font(.subheadline)
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
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
        }
    }
    
    private var lifetimeSummary: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.dateAndSummary) {
            Text("Lifetime")
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
    
    @ViewBuilder
    private var conditionsChart: some View {
        let (conditionToCount, topCondition) = logbookStats.conditionsCount()
        VStack(spacing: 0) {
            HStack(spacing: 20) {
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
                .chartLegend(.hidden)
                .frame(height: 140)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Top Condition")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text(topCondition.sanitize)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 12)

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
            .chartLegend(.visible)
            .chartPlotStyle { plotArea in
                plotArea.frame(height: 0)
            }
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
        // Only check once per app launch
        guard !folderConnectionHandler.hasCheckedForFilesThisSession else {
            Logger.logbookView.debug("Already checked for files this session, skipping.")
            return
        }

        folderConnectionHandler.hasCheckedForFilesThisSession = true

        if let url = BookmarkManager.shared.bookmark?.url {
            folderConnectionHandler.getNonUploadedSlopeFiles(forURL: url) { files in
                if let files, !files.isEmpty {
                    // Determine if this is first-time setup or background upload
                    let isFirstTimeSetup = UserDefaults.standard.bool(forKey: "hasCompletedInitialUpload") == false

                    if isFirstTimeSetup {
                        // Show full progress dialog for first upload
                        showAutoUpload = true
                    } else {
                        // Background upload with minimal UI
                        folderConnectionHandler.isUploadingInBackground = true
                    }

                    folderConnectionHandler.uploadNewFiles(files) {
                        UserDefaults.standard.set(true, forKey: "hasCompletedInitialUpload")

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.25) { // give time for Lambda's to fire and animation to end
                            folderConnectionHandler.isUploadingInBackground = false
                            requestLogs()
                        }
                    }
                }
            }
        }
    }
    
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
