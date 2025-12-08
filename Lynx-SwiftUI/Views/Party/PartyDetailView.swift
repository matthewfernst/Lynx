import SwiftUI
import Charts

struct PartyDetailView: View {
    @Environment(ProfileManager.self) private var profileManager
    @Environment(\.dismiss) private var dismiss
    @Bindable var partyHandler: PartyHandler
    let partyId: String

    @State private var selectedTimeframe: Timeframe = .season
    @State private var showInviteUser = false
    @State private var showPartySettings = false
    @State private var showLeaveConfirmation = false
    @State private var showDeleteConfirmation = false

    private var isManager: Bool {
        guard let details = partyHandler.selectedPartyDetails,
              let profile = profileManager.profile else { return false }
        // Try ID match first
        if profile.id == details.partyManager.id {
            return true
        }
        // Fallback: match by name and email
        return profile.firstName == details.partyManager.firstName &&
               profile.lastName == details.partyManager.lastName
    }

    var body: some View {
        ScrollView {
            if partyHandler.isLoadingDetails {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else if let details = partyHandler.selectedPartyDetails {
                VStack(spacing: 24) {
                    if let description = details.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            Text(description)
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }

                    PartyLeaderboardChartsSection(
                        details: details,
                        selectedTimeframe: $selectedTimeframe,
                        profileManager: profileManager,
                        onTimeframeChange: { timeframe in
                            partyHandler.fetchPartyDetails(
                                partyId: partyId,
                                sortBy: .verticalDistance,
                                timeframe: timeframe
                            )
                        }
                    )

                    PartyMembersListSection(
                        details: details,
                        profileManager: profileManager,
                        partyHandler: partyHandler,
                        partyId: partyId
                    )

                    PartyInvitedUsersListSection(
                        details: details,
                        partyHandler: partyHandler,
                        partyId: partyId
                    )
                }
                .padding()
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(partyHandler.selectedPartyDetails?.name ?? "Party")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showPartySettings = true }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .onAppear {
            partyHandler.fetchPartyDetails(partyId: partyId)
        }
        .refreshable {
            partyHandler.fetchPartyDetails(
                partyId: partyId,
                sortBy: .verticalDistance,
                timeframe: selectedTimeframe
            )
        }
        .sheet(isPresented: $showInviteUser) {
            PartyInviteUserView(partyHandler: partyHandler, partyId: partyId)
        }
        .sheet(isPresented: $showPartySettings) {
            if let details = partyHandler.selectedPartyDetails {
                PartySettingsView(
                    partyHandler: partyHandler,
                    partyId: partyId,
                    partyName: details.name,
                    partyDescription: details.description,
                    invitedUsers: details.invitedUsers,
                    isManager: isManager,
                    onDismiss: { dismiss() }
                )
            }
        }
        .alert("Leave Party", isPresented: $showLeaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                partyHandler.leaveParty(partyId: partyId) { _ in
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to leave this party?")
        }
        .alert("Delete Party", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                partyHandler.deleteParty(partyId: partyId) { _ in
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this party? This action cannot be undone.")
        }
    }
}

struct PartyLeaderboardChartsSection: View {
    let details: PartyDetails
    @Binding var selectedTimeframe: Timeframe
    let profileManager: ProfileManager
    let onTimeframeChange: (Timeframe) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Leaderboard")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                Menu {
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        Text("All Time").tag(Timeframe.allTime)
                        Text("Season").tag(Timeframe.season)
                        Text("Month").tag(Timeframe.month)
                        Text("Week").tag(Timeframe.week)
                        Text("Day").tag(Timeframe.day)
                    }
                } label: {
                    HStack {
                        Text(timeframeLabel)
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                .onChange(of: selectedTimeframe) { _, newValue in
                    onTimeframeChange(newValue)
                }

                Spacer()
            }

            if details.leaderboard.isEmpty {
                Text("No stats yet for this \(timeframeLabel.lowercased())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                VStack(spacing: 16) {
                    PartyLeaderboardChart(
                        leaderboard: details.leaderboard,
                        sortBy: .verticalDistance,
                        measurementSystem: profileManager.measurementSystem
                    )

                    PartyLeaderboardChart(
                        leaderboard: details.leaderboard,
                        sortBy: .distance,
                        measurementSystem: profileManager.measurementSystem
                    )

                    PartyLeaderboardChart(
                        leaderboard: details.leaderboard,
                        sortBy: .topSpeed,
                        measurementSystem: profileManager.measurementSystem
                    )

                    PartyLeaderboardChart(
                        leaderboard: details.leaderboard,
                        sortBy: .runCount,
                        measurementSystem: profileManager.measurementSystem
                    )
                }
            }
        }
    }

    private var timeframeLabel: String {
        switch selectedTimeframe {
        case .season: return "Season"
        case .month: return "Month"
        case .week: return "Week"
        case .day: return "Day"
        case .allTime: return "All Time"
        }
    }
}

struct PartyLeaderboardChart: View {
    let leaderboard: [PartyLeaderboardEntry]
    let sortBy: LeaderboardSort
    let measurementSystem: MeasurementSystem

    private var topThree: [PartyLeaderboardEntry] {
        Array(leaderboard.prefix(3))
    }

    private var chartData: [(name: String, value: Double)] {
        topThree.map { entry in
            let value: Double
            if let stats = entry.stats {
                switch sortBy {
                case .verticalDistance: value = stats.verticalDistance
                case .distance: value = stats.distance
                case .topSpeed: value = stats.topSpeed
                case .runCount: value = Double(stats.runCount)
                }
            } else {
                value = 0
            }
            return (name: "\(entry.firstName) \(entry.lastName)", value: value)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: categoryIcon)
                    .foregroundStyle(.blue)
                Text(categoryLabel)
                    .font(.headline)
                Spacer()
            }

            if chartData.isEmpty {
                Text("No data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                        BarMark(
                            x: .value("Value", data.value),
                            y: .value("Name", data.name)
                        )
                        .foregroundStyle([Color.blue, .green, .orange][index])
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        if let xValue = value.as(Double.self) {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(formatValue(xValue))
                        }
                    }
                }
                .frame(height: 180)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var categoryLabel: String {
        switch sortBy {
        case .verticalDistance: return "Vertical Distance"
        case .distance: return "Distance"
        case .topSpeed: return "Top Speed"
        case .runCount: return "Run Count"
        }
    }

    private var categoryIcon: String {
        switch sortBy {
        case .verticalDistance: return "arrow.up"
        case .distance: return "arrow.left.and.right"
        case .topSpeed: return "speedometer"
        case .runCount: return "figure.snowboarding"
        }
    }

    private func formatValue(_ value: Double) -> String {
        switch sortBy {
        case .verticalDistance:
            if value >= 1000 {
                return String(format: "%.1fk \(measurementSystem.feetOrMeters)", value / 1000)
            }
            return String(format: "%.0f \(measurementSystem.feetOrMeters)", value)
        case .distance:
            switch measurementSystem {
            case .imperial:
                return String(format: "%.1f mi", value.feetToMiles)
            case .metric:
                return String(format: "%.1f km", value.metersToKilometers)
            }
        case .topSpeed:
            return String(format: "%.1f \(measurementSystem.milesOrKilometersPerHour)", value)
        case .runCount:
            return "\(Int(value))"
        }
    }
}

struct PartyMembersListSection: View {
    let details: PartyDetails
    let profileManager: ProfileManager
    @Bindable var partyHandler: PartyHandler
    let partyId: String

    @State private var userToRemove: PartyUser?
    @State private var showRemoveConfirmation = false

    private var isManager: Bool {
        profileManager.profile?.id == details.partyManager.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Members (\(details.users.count))")
                .font(.title3)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                ForEach(details.users, id: \.id) { user in
                    HStack {
                        if user.id == details.partyManager.id {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                        }

                        VStack(alignment: .leading) {
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.subheadline)
                                .fontWeight(user.id == details.partyManager.id ? .semibold : .regular)
                        }

                        Spacer()

                        if isManager && user.id != details.partyManager.id {
                            if partyHandler.isRemovingUser {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .controlSize(.small)
                            } else {
                                Button(action: {
                                    userToRemove = user
                                    showRemoveConfirmation = true
                                }) {
                                    Image(systemName: "person.fill.xmark")
                                        .foregroundStyle(.red)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }
            }
        }
        .alert("Remove User", isPresented: $showRemoveConfirmation) {
            Button("Cancel", role: .cancel) {
                userToRemove = nil
            }
            Button("Remove", role: .destructive) {
                if let user = userToRemove {
                    partyHandler.removeUserFromParty(partyId: partyId, userId: user.id) { _ in
                        userToRemove = nil
                    }
                }
            }
        } message: {
            if let user = userToRemove {
                Text("Are you sure you want to remove \(user.firstName) \(user.lastName) from the party?")
            }
        }
    }
}

struct PartyInvitedUsersListSection: View {
    let details: PartyDetails
    @Bindable var partyHandler: PartyHandler
    let partyId: String

    @State private var inviteToRevoke: PartyUser?
    @State private var showRevokeConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pending Invites (\(details.invitedUsers.count))")
                .font(.title3)
                .fontWeight(.semibold)

            if details.invitedUsers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("No Pending Invites")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(details.invitedUsers, id: \.id) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(user.firstName) \(user.lastName)")
                                    .font(.subheadline)
                            }
                            Spacer()
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.secondary)
                                .font(.caption)

                            if partyHandler.isRevokingInvite {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .controlSize(.small)
                            } else {
                                Button(action: {
                                    inviteToRevoke = user
                                    showRevokeConfirmation = true
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .alert("Revoke Invitation", isPresented: $showRevokeConfirmation) {
            Button("Cancel", role: .cancel) {
                inviteToRevoke = nil
            }
            Button("Revoke", role: .destructive) {
                if let user = inviteToRevoke {
                    partyHandler.revokePartyInvite(partyId: partyId, userId: user.id) { _ in
                        inviteToRevoke = nil
                    }
                }
            }
        } message: {
            if let user = inviteToRevoke {
                Text("Are you sure you want to revoke the invitation for \(user.firstName) \(user.lastName)?")
            }
        }
    }
}

struct PartyInviteUserView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var partyHandler: PartyHandler
    let partyId: String

    @State private var email = ""
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @State private var foundUser: PartyUser?
    @State private var profilePicture: Image?
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Search by Email")
                            .font(.headline)

                        TextField("Enter email address", text: $email)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .padding(12)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(10)
                            .onChange(of: email) { oldValue, newValue in
                                debouncedSearch(email: newValue)
                            }

                        if !email.isEmpty {
                            Text("Searching as you type...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .background(Color(uiColor: .systemGroupedBackground))
                ScrollView {
                    VStack(spacing: 20) {
                        if isSearching {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .controlSize(.large)
                                Text("Searching for user...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if let user = foundUser {
                            VStack(spacing: 24) {
                                VStack(spacing: 16) {
                                    if let profilePicture {
                                        profilePicture
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.green, lineWidth: 3)
                                            )
                                    } else {
                                        ZStack {
                                            Circle()
                                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                                .frame(width: 100, height: 100)

                                            if user.profilePictureURL != nil {
                                                ProgressView()
                                            } else {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 100, height: 100)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .overlay(
                                            Circle()
                                                .stroke(Color.green, lineWidth: 3)
                                        )
                                    }

                                    VStack(spacing: 4) {
                                        HStack(spacing: 8) {
                                            Text("\(user.firstName) \(user.lastName)")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundStyle(.green)
                                        }

                                        Text(email)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.top, 40)
                                Button(action: sendInvite) {
                                    HStack {
                                        if partyHandler.isInvitingUser {
                                            ProgressView()
                                                .progressViewStyle(.circular)
                                                .tint(.white)
                                        } else {
                                            Image(systemName: "paperplane.fill")
                                            Text("Send Invitation")
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .disabled(partyHandler.isInvitingUser || isSearching)
                                .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                        } else if let errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.orange)
                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if !email.isEmpty && !isSearching {
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.secondary)
                                Text("Start typing to search for a user")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.secondary)

                                Text("Enter an email address to find and invite users to this party")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .navigationTitle("Invite User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        searchTask?.cancel()
                        dismiss()
                    }
                }
            }
        }
        .alert("Invitation Sent!", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("The party invitation has been sent successfully.")
        }
        .onChange(of: foundUser) { _, newUser in
            loadProfilePicture(for: newUser)
        }
    }

    private func debouncedSearch(email: String) {
        searchTask?.cancel()
        errorMessage = nil

        guard !email.isEmpty else {
            foundUser = nil
            profilePicture = nil
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

            guard !Task.isCancelled else { return }

            await MainActor.run {
                searchUser(email: email)
            }
        }
    }

    private func searchUser(email: String) {
        guard !email.isEmpty else { return }
        isSearching = true
        foundUser = nil
        profilePicture = nil

        ApolloLynxClient.userLookupByEmail(email: email) { result in
            DispatchQueue.main.async {
                isSearching = false
                switch result {
                case .success(let user):
                    if let user = user {
                        foundUser = user
                    } else {
                        errorMessage = "No user found with that email address."
                    }
                case .failure(let error):
                    errorMessage = "Error searching for user: \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadProfilePicture(for user: PartyUser?) {
        guard let user = user, let url = user.profilePictureURL else {
            profilePicture = nil
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    profilePicture = Image(uiImage: uiImage)
                }
            }
        }.resume()
    }

    private func sendInvite() {
        guard let user = foundUser else { return }
        errorMessage = nil

        partyHandler.inviteUserToParty(partyId: partyId, userId: user.id) { result in
            switch result {
            case .success:
                showSuccess = true
            case .failure(let error):
                errorMessage = "Error sending invitation: \(error.localizedDescription)"
            }
        }
    }
}

struct PartySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var partyHandler: PartyHandler
    let partyId: String
    let partyName: String
    let partyDescription: String?
    let invitedUsers: [PartyUser]
    let isManager: Bool
    let onDismiss: () -> Void

    @State private var editedName: String
    @State private var editedDescription: String
    @State private var showLeaveConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var hasChanges = false

    // Invite user state
    @State private var inviteEmail = ""
    @State private var isSearching = false
    @State private var searchErrorMessage: String?
    @State private var foundUser: PartyUser?
    @State private var profilePicture: Image?
    @State private var searchTask: Task<Void, Never>?

    init(partyHandler: PartyHandler, partyId: String, partyName: String, partyDescription: String?, invitedUsers: [PartyUser], isManager: Bool, onDismiss: @escaping () -> Void) {
        self.partyHandler = partyHandler
        self.partyId = partyId
        self.partyName = partyName
        self.partyDescription = partyDescription
        self.invitedUsers = invitedUsers
        self.isManager = isManager
        self.onDismiss = onDismiss
        _editedName = State(initialValue: partyName)
        _editedDescription = State(initialValue: partyDescription ?? "")
    }

    private var isUserAlreadyInvited: Bool {
        guard let user = foundUser else { return false }
        return invitedUsers.contains(where: { $0.id == user.id })
    }

    var body: some View {
        NavigationStack {
            List {
                if isManager {
                    Section {
                        TextField("Party Name", text: $editedName)
                            .onChange(of: editedName) { _, _ in checkForChanges() }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("Add a description...", text: $editedDescription, axis: .vertical)
                                .lineLimit(3...6)
                                .onChange(of: editedDescription) { _, _ in checkForChanges() }
                        }
                    } header: {
                        Text("Party Details")
                    } footer: {
                        if hasChanges {
                            Button(action: saveChanges) {
                                HStack {
                                    if partyHandler.isEditingParty {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .controlSize(.small)
                                        Text("Saving...")
                                    } else {
                                        Text("Save Changes")
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            .disabled(partyHandler.isEditingParty || editedName.isEmpty)
                        }
                    }

                    Section {
                        TextField("Search by email...", text: $inviteEmail)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .onChange(of: inviteEmail) { _, newValue in
                                debouncedSearch(email: newValue)
                            }

                        if isSearching {
                            HStack {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Searching...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                        } else if let errorMessage = searchErrorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                        } else if let user = foundUser {
                            HStack(spacing: 12) {
                                if let profilePicture {
                                    profilePicture
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(.secondary)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(user.firstName) \(user.lastName)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(inviteEmail)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if isUserAlreadyInvited {
                                    Text("Already Invited")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                                        .cornerRadius(6)
                                } else {
                                    Button(action: sendInvite) {
                                        if partyHandler.isInvitingUser {
                                            ProgressView()
                                                .progressViewStyle(.circular)
                                                .controlSize(.small)
                                        } else {
                                            Text("Invite")
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                    .disabled(partyHandler.isInvitingUser)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        Text("Invite User")
                    } footer: {
                        if !inviteEmail.isEmpty && foundUser == nil && !isSearching && searchErrorMessage == nil {
                            Text("Start typing an email to search for users")
                                .font(.caption)
                        }
                    }
                }

                Section {
                    if isManager {
                        Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                            HStack {
                                if partyHandler.isDeletingParty {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "trash")
                                    Text("Delete Party")
                                }
                            }
                        }
                        .disabled(partyHandler.isDeletingParty)
                    } else {
                        Button(role: .destructive, action: { showLeaveConfirmation = true }) {
                            HStack {
                                if partyHandler.isLeavingParty {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Leave Party")
                                }
                            }
                        }
                        .disabled(partyHandler.isLeavingParty)
                    }
                } header: {
                    Text("Danger Zone")
                }
            }
            .navigationTitle("Party Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: foundUser) { _, newUser in
            loadProfilePicture(for: newUser)
        }
        .alert("Leave Party", isPresented: $showLeaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                partyHandler.leaveParty(partyId: partyId) { _ in
                    dismiss()
                    onDismiss()
                }
            }
        } message: {
            Text("Are you sure you want to leave this party?")
        }
        .alert("Delete Party", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                partyHandler.deleteParty(partyId: partyId) { _ in
                    dismiss()
                    onDismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this party? This action cannot be undone.")
        }
    }

    private func checkForChanges() {
        hasChanges = editedName != partyName || editedDescription != (partyDescription ?? "")
    }

    private func saveChanges() {
        partyHandler.editParty(
            partyId: partyId,
            name: editedName,
            description: editedDescription.isEmpty ? nil : editedDescription
        ) { result in
            if result {
                hasChanges = false
            }
        }
    }

    private func debouncedSearch(email: String) {
        searchTask?.cancel()
        searchErrorMessage = nil

        guard !email.isEmpty else {
            foundUser = nil
            profilePicture = nil
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

            guard !Task.isCancelled else { return }

            await MainActor.run {
                searchUser(email: email)
            }
        }
    }

    private func searchUser(email: String) {
        guard !email.isEmpty else { return }
        isSearching = true
        foundUser = nil
        profilePicture = nil

        ApolloLynxClient.userLookupByEmail(email: email) { result in
            DispatchQueue.main.async {
                isSearching = false
                switch result {
                case .success(let user):
                    if let user = user {
                        foundUser = user
                    } else {
                        searchErrorMessage = "No user found with that email address."
                    }
                case .failure(let error):
                    searchErrorMessage = "Error searching for user: \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadProfilePicture(for user: PartyUser?) {
        guard let user = user, let url = user.profilePictureURL else {
            profilePicture = nil
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    profilePicture = Image(uiImage: uiImage)
                }
            }
        }.resume()
    }

    private func sendInvite() {
        guard let user = foundUser else { return }
        searchErrorMessage = nil

        partyHandler.inviteUserToParty(partyId: partyId, userId: user.id) { result in
            switch result {
            case .success:
                // Clear the search after successful invite
                inviteEmail = ""
                foundUser = nil
                profilePicture = nil
            case .failure(let error):
                searchErrorMessage = "Error sending invitation: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    NavigationStack {
        PartyDetailView(partyHandler: PartyHandler(), partyId: "1")
    }
}
