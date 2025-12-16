import OSLog
import SwiftUI

struct PartyView: View {
  @Environment(ProfileManager.self) private var profileManager

  // Party state
  @State private var parties: [PartyAttributes] = []
  @State private var partyInvites: [PartyAttributes] = []
  @State private var isLoadingParties = false
  @State private var isLoadingInvites = false
  @State private var isJoiningParty = false
  @State private var errorMessage: String?

  // UI state
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
          if !partyInvites.isEmpty {
            PartyInvitesSection(
              partyInvites: $partyInvites,
              isLoadingInvites: isLoadingInvites,
              isJoiningParty: isJoiningParty,
              onJoinParty: { partyId in
                joinParty(partyId: partyId) { _ in }
              }
            )
          }

          PartiesListSection(
            parties: $parties,
            isLoadingParties: isLoadingParties
          )
        }
        .padding()
      }
      .background(Color(uiColor: .systemGroupedBackground))
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
        CreatePartyView(onPartyCreated: { newParty in
          parties.append(newParty)
        })
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
      .alert("Slopes Folder Connected", isPresented: $showSlopesFolderAlreadyConnected) {
      } message: {
        Text(
          "When you open the app, we will automatically upload new files to propogate to MountainUI."
        )
      }
      .alert("Error", isPresented: .constant(errorMessage != nil)) {
        Button("OK") {
          errorMessage = nil
        }
      } message: {
        if let errorMessage = errorMessage {
          Text(errorMessage)
        }
      }
      .task {
        refreshAll()
      }
      .refreshable {
        refreshAll()
      }
    }
  }

  private func fetchParties() {
    isLoadingParties = true
    errorMessage = nil

    ApolloLynxClient.getParties { [parties] result in
      DispatchQueue.main.async {
        self.isLoadingParties = false
        switch result {
        case .success(let fetchedParties):
          self.parties = fetchedParties
        case .failure(let error):
          self.errorMessage = "Failed to load parties"
          Logger.partyView.error("Error fetching parties: \(error)")
        }
      }
    }
  }

  private func fetchPartyInvites() {
    isLoadingInvites = true
    errorMessage = nil

    ApolloLynxClient.getPartyInvites { [partyInvites] result in
      DispatchQueue.main.async {
        self.isLoadingInvites = false
        switch result {
        case .success(let fetchedInvites):
          self.partyInvites = fetchedInvites
        case .failure(let error):
          self.errorMessage = "Failed to load party invites"
          Logger.partyView.error("Error fetching party invites: \(error)")
        }
      }
    }
  }

  private func joinParty(partyId: String, completion: @escaping (Bool) -> Void) {
    isJoiningParty = true
    errorMessage = nil

    ApolloLynxClient.joinParty(partyId: partyId) { result in
      DispatchQueue.main.async {
        self.isJoiningParty = false
        switch result {
        case .success:
          self.partyInvites.removeAll { $0.id == partyId }
          self.fetchParties()
          completion(true)
        case .failure(let error):
          self.errorMessage = "Failed to join party"
          Logger.partyView.error("Error joining party: \(error)")
          completion(false)
        }
      }
    }
  }

  private func refreshAll() {
    fetchParties()
    fetchPartyInvites()
  }
}

extension Logger {
  static let partyView = Logger(subsystem: "com.lynx", category: "PartyView")
}

struct PartiesListSection: View {
  @Binding var parties: [PartyAttributes]
  let isLoadingParties: Bool
  @State private var hasAppeared = false

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if isLoadingParties {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding()
      } else if parties.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "person.3")
            .font(.system(size: 48))
            .foregroundStyle(.secondary)
            .symbolEffect(.bounce, value: hasAppeared)
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
        .opacity(hasAppeared ? 1 : 0)
        .scaleEffect(hasAppeared ? 1 : 0.8)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: hasAppeared)
        .onAppear {
          withAnimation {
            hasAppeared = true
          }
        }
      } else {
        ForEach(Array(parties.enumerated()), id: \.element.id) { index, party in
          NavigationLink {
            PartyDetailView(partyId: party.id)
          } label: {
            PartyCard(party: party)
          }
          .buttonStyle(PlainButtonStyle())
          .opacity(hasAppeared ? 1 : 0)
          .offset(y: hasAppeared ? 0 : 20)
          .animation(
            .spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1),
            value: hasAppeared)
        }
        .onAppear {
          withAnimation {
            hasAppeared = true
          }
        }
      }
    }
  }
}

struct PartyInvitesSection: View {
  @Binding var partyInvites: [PartyAttributes]
  let isLoadingInvites: Bool
  let isJoiningParty: Bool
  let onJoinParty: (String) -> Void
  @State private var hasAppeared = false

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: "envelope.badge")
          .foregroundStyle(.blue)
          .symbolEffect(.bounce, value: hasAppeared)
        Text("Party Invites")
          .font(.title2)
          .fontWeight(.bold)
        Spacer()
      }
      .opacity(hasAppeared ? 1 : 0)
      .offset(x: hasAppeared ? 0 : -20)
      .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasAppeared)

      if isLoadingInvites {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding()
      } else {
        ForEach(Array(partyInvites.enumerated()), id: \.element.id) { index, party in
          PartyInviteCard(
            party: party,
            isJoiningParty: isJoiningParty,
            onJoin: { onJoinParty(party.id) }
          )
          .opacity(hasAppeared ? 1 : 0)
          .scaleEffect(hasAppeared ? 1 : 0.9)
          .animation(
            .spring(response: 0.6, dampingFraction: 0.75).delay(0.1 + Double(index) * 0.1),
            value: hasAppeared)
        }
      }
    }
    .onAppear {
      withAnimation {
        hasAppeared = true
      }
    }
  }
}

struct PartyCard: View {
  let party: PartyAttributes
  @State private var isPressed = false

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

      if let description = party.description, !description.isEmpty {
        Text(description)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
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
    .scaleEffect(isPressed ? 0.97 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    .onLongPressGesture(
      minimumDuration: .infinity, maximumDistance: .infinity,
      pressing: { pressing in
        isPressed = pressing
      }, perform: {})
  }
}

struct PartyInviteCard: View {
  let party: PartyAttributes
  let isJoiningParty: Bool
  let onJoin: () -> Void

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
        Button(action: onJoin) {
          if isJoiningParty {
            ProgressView()
              .progressViewStyle(.circular)
              .frame(maxWidth: .infinity)
          } else {
            Text("Accept")
              .frame(maxWidth: .infinity)
          }
        }
        .buttonStyle(.borderedProminent)
        .disabled(isJoiningParty)

        Button(action: {
        }) {
          Text("Decline")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(isJoiningParty)
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
  PartyView()
}
