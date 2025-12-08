import SwiftUI

struct CreatePartyView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var partyHandler: PartyHandler

    @State private var partyName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Party Name", text: $partyName)
                } header: {
                    Text("Party Details")
                } footer: {
                    Text("Choose a name for your party. You can invite friends after creating it.")
                }
            }
            .navigationTitle("Create Party")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(partyHandler.isCreatingParty)
                }

                ToolbarItem(placement: .confirmationAction) {
                    if partyHandler.isCreatingParty {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Button("Create") {
                            createParty()
                        }
                        .disabled(partyName.isEmpty)
                    }
                }
            }
        }
    }

    private func createParty() {
        partyHandler.createParty(name: partyName) { success in
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    CreatePartyView(partyHandler: PartyHandler())
}
