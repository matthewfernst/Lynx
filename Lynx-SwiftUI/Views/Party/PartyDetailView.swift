import SwiftUI
import Charts

struct PartyDetailView: View {
    @Environment(ProfileManager.self) private var profileManager
    @Environment(\.dismiss) private var dismiss
    @Bindable var partyHandler: PartyHandler
    let partyId: String

    @State private var selectedTimeframe: Timeframe = .season
    @State private var showInviteUser = false
    @State private var showLeaveConfirmation = false
    @State private var showDeleteConfirmation = false

    private var isManager: Bool {
        guard let details = partyHandler.selectedPartyDetails,
              let profileId = profileManager.profile?.id else { return false }
        return profileId == details.partyManager.id
    }

    var body: some View {
        ScrollView {
            if partyHandler.isLoadingDetails {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let details = partyHandler.selectedPartyDetails {
                VStack(spacing: 24) {
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

                    if !details.invitedUsers.isEmpty {
                        PartyInvitedUsersListSection(
                            details: details,
                            partyHandler: partyHandler,
                            partyId: partyId
                        )
                    }

                    Button(role: .destructive) {
                        if isManager {
                            showDeleteConfirmation = true
                        } else {
                            showLeaveConfirmation = true
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Label(
                                isManager ? "Delete Party" : "Leave Party",
                                systemImage: isManager ? "trash" : "rectangle.portrait.and.arrow.right"
                            )
                            .foregroundStyle(.red)
                            Spacer()
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationTitle(partyHandler.selectedPartyDetails?.name ?? "Party")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showInviteUser = true }) {
                    Image(systemName: "person.badge.plus")
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

                        Button(action: {
                            inviteToRevoke = user
                            showRevokeConfirmation = true
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(8)
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

    @State private var userId = ""
    @State private var isInviting = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("User ID", text: $userId)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } header: {
                    Text("Enter User ID")
                } footer: {
                    Text("Ask the user for their User ID to send them a party invitation.")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button(action: sendInvite) {
                        if isInviting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Send Invitation")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(userId.isEmpty || isInviting)
                }
            }
            .navigationTitle("Invite User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
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
    }

    private func sendInvite() {
        guard !userId.isEmpty else { return }
        isInviting = true
        errorMessage = nil

        partyHandler.inviteUserToParty(partyId: partyId, userId: userId) { result in
            isInviting = false
            switch result {
            case .success:
                showSuccess = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    NavigationStack {
        PartyDetailView(partyHandler: PartyHandler(), partyId: "1")
    }
}
