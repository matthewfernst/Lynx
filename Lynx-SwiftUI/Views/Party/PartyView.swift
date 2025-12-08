import SwiftUI

struct PartyView: View {
    @Environment(ProfileManager.self) private var profileManager
    @Bindable var partyHandler: PartyHandler
    @State private var showCreateParty = false
    @State private var showProfile = false
    @State private var showUploadFilesSheet = false
    @State private var showUploadProgress = false
    @State private var showSlopesFolderAlreadyConnected = false
    @State private var folderConnectionHandler = FolderConnectionHandler()

    private var slopesFolderIsConnected: Bool {
        BookmarkManager.shared.bookmark != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !partyHandler.partyInvites.isEmpty {
                        PartyInvitesSection(partyHandler: partyHandler)
                    }

                    PartiesListSection(partyHandler: partyHandler)
                }
                .padding()
            }
            .navigationTitle("Parties")
            .scrollContentBackground(.hidden)
            .toolbar {
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateParty = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileButton(showProfile: $showProfile)
                }
            }
            .sheet(isPresented: $showCreateParty) {
                CreatePartyView(partyHandler: partyHandler)
            }
            .sheet(isPresented: $showProfile) {
                AccountView()
            }
            .sheet(isPresented: $showUploadFilesSheet) {
                FolderConnectionView(
                    showUploadProgressView: $showUploadProgress,
                    folderConnectionHandler: folderConnectionHandler
                )
            }
            .sheet(isPresented: $showUploadProgress) {
                FileUploadProgressView(
                    folderConnectionHandler: folderConnectionHandler
                )
            }
            .alert("Slopes Folder Connected", isPresented: $showSlopesFolderAlreadyConnected) {} message: {
                Text("When you open the app, we will automatically upload new files to propogate to MountainUI.")
            }
            .alert("Error", isPresented: .constant(partyHandler.errorMessage != nil)) {
                Button("OK") {
                    partyHandler.errorMessage = nil
                }
            } message: {
                if let errorMessage = partyHandler.errorMessage {
                    Text(errorMessage)
                }
            }
            .task {
                partyHandler.refreshAll()
            }
            .refreshable {
                partyHandler.refreshAll()
            }
        }
    }
}

struct PartiesListSection: View {
    @Bindable var partyHandler: PartyHandler

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if partyHandler.isLoadingParties {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if partyHandler.parties.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.3")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No Parties Yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Create a party to compete with friends!")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(partyHandler.parties, id: \.id) { party in
                    NavigationLink {
                        PartyDetailView(partyHandler: partyHandler, partyId: party.id)
                    } label: {
                        PartyCard(party: party)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct PartyInvitesSection: View {
    @Bindable var partyHandler: PartyHandler

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "envelope.badge")
                    .foregroundStyle(.blue)
                Text("Party Invites")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }

            if partyHandler.isLoadingInvites {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(partyHandler.partyInvites, id: \.id) { party in
                    PartyInviteCard(party: party, partyHandler: partyHandler)
                }
            }
        }
    }
}

struct PartyCard: View {
    let party: PartyAttributes

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(party.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 16) {
                Label("\(party.userCount)", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if party.invitedUserCount > 0 {
                    Label("\(party.invitedUserCount)", systemImage: "envelope.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct PartyInviteCard: View {
    let party: PartyAttributes
    @Bindable var partyHandler: PartyHandler
    @State private var isJoining = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(party.name)
                    .font(.headline)
                Text("Invited by: \(party.partyManagerName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button(action: {
                    isJoining = true
                    partyHandler.joinParty(partyId: party.id) { success in
                        isJoining = false
                    }
                }) {
                    if isJoining {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Accept")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isJoining)

                Button(action: {
                }) {
                    Text("Decline")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isJoining)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    PartyView(partyHandler: PartyHandler())
}
