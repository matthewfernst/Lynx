import SwiftUI

struct PartyInvitesView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var partyHandler: PartyHandler

    var body: some View {
        List {
            if partyHandler.isLoadingInvites {
                Section {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            } else if partyHandler.partyInvites.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No Party Invites")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("You don't have any pending party invitations.")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            } else {
                Section {
                    ForEach(partyHandler.partyInvites, id: \.id) { party in
                        PartyInviteCard(party: party, partyHandler: partyHandler)
                    }
                }
            }
        }
        .navigationTitle("Party Invites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .refreshable {
            partyHandler.fetchPartyInvites()
        }
    }
}

#Preview {
    NavigationStack {
        PartyInvitesView(partyHandler: PartyHandler())
    }
}
