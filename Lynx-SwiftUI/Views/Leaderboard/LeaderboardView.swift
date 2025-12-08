import SwiftUI

struct LeaderboardView: View {
    @Environment(ProfileManager.self) private var profileManager

    @State private var verticalDistanceLeaders: [LeaderAttributes] = []
    @State private var topSpeedLeaders: [LeaderAttributes] = []
    @State private var distanceLeaders: [LeaderAttributes] = []
    @State private var runCountLeaders: [LeaderAttributes] = []

    @State private var parties: [PartyAttributes] = []
    @State private var selectedPartyId: String?

    @State private var showFailedToGetTopLeaders = false
    @State private var showProfile = false
    @State private var showNoPartyAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if parties.count > 1, let selectedPartyId = selectedPartyId {
                    Picker("Party", selection: Binding(
                        get: { selectedPartyId },
                        set: { newValue in
                            self.selectedPartyId = newValue
                            populateLeaderboard()
                        }
                    )) {
                        ForEach(parties, id: \.id) { party in
                            Text(party.name).tag(party.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                }

                ForEach(Array(zip([
                    verticalDistanceLeaders, topSpeedLeaders, distanceLeaders, runCountLeaders
                ], [
                    LeaderboardCategory.verticalDistance(), .topSpeed(), .distance(), .runCount(),
                ])), id: \.1) { leaders, category in
                    TopLeadersForCategoryView(
                        partyId: selectedPartyId,
                        topLeaders: leaders,
                        category: category
                    )
                }
            }
            .padding()
            .alert("Unable to Load Leaderboard", isPresented: $showFailedToGetTopLeaders) {
                Button("Retry") {
                    populateLeaderboard()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("We couldn't load the leaderboard data. Please check your internet connection and try again.")
            }
            .alert("No Party Found", isPresented: $showNoPartyAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You need to be in a party to view leaderboards. Create or join a party from the Parties tab.")
            }
            .navigationTitle("Leaderboard")
            .scrollContentBackground(.hidden)
            .toolbar {
                profileButton
            }
            .task {
                loadPartiesAndLeaderboard()
            }
            .refreshable { // TODO: Refresh being wonky on simulator?
                populateLeaderboard()
            }
            .sheet(isPresented: $showProfile) {
                AccountView()
            }
        }
    }
    
    private func loadPartiesAndLeaderboard() {
        ApolloLynxClient.getParties { result in
            switch result {
            case .success(let fetchedParties):
                parties = fetchedParties
                if let firstParty = fetchedParties.first {
                    selectedPartyId = firstParty.id
                    populateLeaderboard()
                } else {
                    showNoPartyAlert = true
                }
            case .failure(_):
                showFailedToGetTopLeaders = true
            }
        }
    }

    private func populateLeaderboard() {
        guard let partyId = selectedPartyId else {
            showNoPartyAlert = true
            return
        }

        ApolloLynxClient.getAllPartyLeaderboards(
            partyId: partyId,
            for: .season,
            limit: Constants.topThree,
            inMeasurementSystem: profileManager.measurementSystem
        ) { result in
            switch result {
            case .success(let leaderboards):
                distanceLeaders = leaderboards[.distance] ?? []
                runCountLeaders = leaderboards[.runCount] ?? []
                topSpeedLeaders = leaderboards[.topSpeed] ?? []
                verticalDistanceLeaders = leaderboards[.verticalDistance] ?? []
            case .failure(_):
                showFailedToGetTopLeaders = true
            }
        }
    }

    private var profileButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ProfileButton(showProfile: $showProfile)
        }
    }

    private struct Constants {
        static let topThree: Int = 3
    }
}

enum LeaderboardCategory: Equatable, Hashable {
    case distance(headerLabelText: String = "Distance", headerSystemImage: String = "arrow.right")
    case runCount(headerLabelText: String = "Run Count", headerSystemImage: String = "figure.skiing.downhill")
    case topSpeed(headerLabelText: String = "Top Speed", headerSystemImage: String = "flame")
    case verticalDistance(headerLabelText: String = "Vertical Distance", headerSystemImage: String = "arrow.down")
    
    var headerLabelText: String {
        switch self {
        case .distance(let labelText, _),
                .runCount(let labelText, _),
                .topSpeed(let labelText, _),
                .verticalDistance(let labelText, _):
            return labelText
        }
    }
    
    var headerSystemImage: String {
        switch self {
        case .distance(_, let systemImage),
                .runCount(_, let systemImage),
                .topSpeed(_, let systemImage),
                .verticalDistance(_, let systemImage):
            return systemImage
        }
    }
    
    var correspondingSort: LeaderboardSort {
        switch self {
        case .distance:
            return .distance
        case .runCount:
            return .runCount
        case .topSpeed:
            return .topSpeed
        case .verticalDistance:
            return .verticalDistance
        }
    }
}



#Preview {
    LeaderboardView()
}
