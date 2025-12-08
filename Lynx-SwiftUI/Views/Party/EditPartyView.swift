import SwiftUI

struct EditPartyView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var partyHandler: PartyHandler
    let partyId: String
    let currentName: String
    let currentDescription: String?

    @State private var partyName: String
    @State private var partyDescription: String

    init(partyHandler: PartyHandler, partyId: String, currentName: String, currentDescription: String?) {
        self.partyHandler = partyHandler
        self.partyId = partyId
        self.currentName = currentName
        self.currentDescription = currentDescription
        self._partyName = State(initialValue: currentName)
        self._partyDescription = State(initialValue: currentDescription ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Party Name", text: $partyName)
                } header: {
                    Text("Party Name")
                } footer: {
                    Text("Give your party a memorable name")
                }

                Section {
                    TextField("Description (optional)", text: $partyDescription, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Description")
                } footer: {
                    Text("Add a description to let others know what your party is about")
                }
            }
            .navigationTitle("Edit Party")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(partyHandler.isEditingParty)
                }

                ToolbarItem(placement: .confirmationAction) {
                    if partyHandler.isEditingParty {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Button("Save") {
                            editParty()
                        }
                        .disabled(partyName.isEmpty || !hasChanges)
                    }
                }
            }
        }
    }

    private var hasChanges: Bool {
        partyName != currentName || partyDescription != (currentDescription ?? "")
    }

    private func editParty() {
        let descriptionToSave = partyDescription.isEmpty ? nil : partyDescription
        partyHandler.editParty(partyId: partyId, name: partyName, description: descriptionToSave) { success in
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    EditPartyView(
        partyHandler: PartyHandler(),
        partyId: "1",
        currentName: "Test Party",
        currentDescription: "This is a test party"
    )
}
