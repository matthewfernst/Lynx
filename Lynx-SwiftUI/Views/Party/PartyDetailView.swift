//
//  PartyDetailView.swift
//  Lynx-SwiftUI
//
//  Created by Claude on 12/7/24.
//

import SwiftUI

struct PartyDetailView: View {
    @Environment(ProfileManager.self) private var profileManager
    @Bindable var partyHandler: PartyHandler
    let partyId: String

    @State private var selectedSort: LeaderboardSort = .verticalDistance
    @State private var selectedTimeframe: Timeframe = .season
    @State private var showLeaveConfirmation = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            if partyHandler.isLoadingDetails {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let details = partyHandler.selectedPartyDetails {
                VStack(spacing: 24) {
                    PartyInfoSection(details: details)

                    PartyLeaderboardSection(
                        details: details,
                        selectedSort: $selectedSort,
                        selectedTimeframe: $selectedTimeframe,
                        profileManager: profileManager,
                        onSortChange: { sort, timeframe in
                            partyHandler.fetchPartyDetails(
                                partyId: partyId,
                                sortBy: sort,
                                timeframe: timeframe
                            )
                        }
                    )

                    PartyMembersSection(details: details)

                    if !details.invitedUsers.isEmpty {
                        PartyInvitedUsersSection(details: details)
                    }

                    PartyActionsSection(
                        details: details,
                        profileManager: profileManager,
                        onLeave: { showLeaveConfirmation = true },
                        onDelete: { showDeleteConfirmation = true }
                    )
                }
                .padding()
            }
        }
        .navigationTitle(partyHandler.selectedPartyDetails?.name ?? "Party")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .onAppear {
            partyHandler.fetchPartyDetails(partyId: partyId)
        }
        .refreshable {
            partyHandler.fetchPartyDetails(
                partyId: partyId,
                sortBy: selectedSort,
                timeframe: selectedTimeframe
            )
        }
        .alert("Leave Party", isPresented: $showLeaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                partyHandler.leaveParty(partyId: partyId) { _ in }
            }
        } message: {
            Text("Are you sure you want to leave this party?")
        }
        .alert("Delete Party", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                partyHandler.deleteParty(partyId: partyId) { _ in }
            }
        } message: {
            Text("Are you sure you want to delete this party? This action cannot be undone.")
        }
    }
}

struct PartyInfoSection: View {
    let details: PartyDetails

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Party Manager")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(details.partyManager.firstName) \(details.partyManager.lastName)")
                        .font(.headline)
                }
                Spacer()
            }

            HStack(spacing: 20) {
                VStack {
                    Text("\(details.users.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Members")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()

                VStack {
                    Text("\(details.invitedUsers.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Invited")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
}

struct PartyLeaderboardSection: View {
    let details: PartyDetails
    @Binding var selectedSort: LeaderboardSort
    @Binding var selectedTimeframe: Timeframe
    let profileManager: ProfileManager
    let onSortChange: (LeaderboardSort, Timeframe) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Leaderboard")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                Menu {
                    Picker("Sort By", selection: $selectedSort) {
                        Text("Vertical Distance").tag(LeaderboardSort.verticalDistance)
                        Text("Distance").tag(LeaderboardSort.distance)
                        Text("Top Speed").tag(LeaderboardSort.topSpeed)
                        Text("Run Count").tag(LeaderboardSort.runCount)
                    }
                } label: {
                    HStack {
                        Text(sortLabel)
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                .onChange(of: selectedSort) { _, newValue in
                    onSortChange(newValue, selectedTimeframe)
                }

                Menu {
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        Text("Season").tag(Timeframe.season)
                        Text("Month").tag(Timeframe.month)
                        Text("Week").tag(Timeframe.week)
                        Text("Day").tag(Timeframe.day)
                        Text("All Time").tag(Timeframe.allTime)
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
                    onSortChange(selectedSort, newValue)
                }

                Spacer()
            }

            if details.leaderboard.isEmpty {
                Text("No stats yet for this timeframe")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(details.leaderboard.enumerated()), id: \.element.id) { index, entry in
                        PartyLeaderboardRow(
                            entry: entry,
                            rank: index + 1,
                            sortBy: selectedSort,
                            measurementSystem: profileManager.measurementSystem
                        )
                    }
                }
            }
        }
    }

    private var sortLabel: String {
        switch selectedSort {
        case .verticalDistance: return "Vertical"
        case .distance: return "Distance"
        case .topSpeed: return "Speed"
        case .runCount: return "Runs"
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

struct PartyLeaderboardRow: View {
    let entry: PartyLeaderboardEntry
    let rank: Int
    let sortBy: LeaderboardSort
    let measurementSystem: MeasurementSystem

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.headline)
                .foregroundStyle(rank <= 3 ? .yellow : .secondary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.firstName) \(entry.lastName)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let stats = entry.stats {
                    Text(statValue(stats))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let stats = entry.stats {
                Text(mainStat(stats))
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(8)
    }

    private func mainStat(_ stats: UserStatsAttributes) -> String {
        switch sortBy {
        case .verticalDistance:
            return String(format: "%.0f %@", stats.verticalDistance, measurementSystem.feetOrMeters)
        case .distance:
            return String(format: "%.1f %@", stats.distance, measurementSystem == .imperial ? "mi" : "km")
        case .topSpeed:
            return String(format: "%.1f %@", stats.topSpeed, measurementSystem.milesOrKilometersPerHour)
        case .runCount:
            return "\(stats.runCount)"
        }
    }

    private func statValue(_ stats: UserStatsAttributes) -> String {
        "\(stats.runCount) runs"
    }
}

struct PartyMembersSection: View {
    let details: PartyDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Members (\(details.users.count))")
                .font(.title3)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                ForEach(details.users, id: \.id) { user in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct PartyInvitedUsersSection: View {
    let details: PartyDetails

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
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct PartyActionsSection: View {
    let details: PartyDetails
    let profileManager: ProfileManager
    let onLeave: () -> Void
    let onDelete: () -> Void

    private var isManager: Bool {
        profileManager.profile?.id == details.partyManager.id
    }

    var body: some View {
        VStack(spacing: 12) {
            if isManager {
                Button(action: onDelete) {
                    Label("Delete Party", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Button(action: onLeave) {
                    Label("Leave Party", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PartyDetailView(partyHandler: PartyHandler(), partyId: "1")
    }
}
