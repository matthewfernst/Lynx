import SwiftUI

struct CreatePartyView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var partyHandler: PartyHandler

    @State private var partyName = ""
    @State private var isCreating = false

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
                    .disabled(isCreating)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createParty()
                    }
                    .disabled(partyName.isEmpty || isCreating)
                }
            }
        }
    }

    private func createParty() {
        isCreating = true
        partyHandler.createParty(name: partyName) { success in
            isCreating = false
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    CreatePartyView(partyHandler: PartyHandler())
}
