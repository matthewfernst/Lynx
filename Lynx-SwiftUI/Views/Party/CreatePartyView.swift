import SwiftUI
import OSLog

struct CreatePartyView: View {
    @Environment(\.dismiss) private var dismiss
    let onPartyCreated: (PartyAttributes) -> Void

    @State private var partyName = ""
    @State private var partyDescription = ""
    @State private var isCreatingParty = false
    @State private var errorMessage: String?

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
            .navigationTitle("Create Party")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isCreatingParty)
                }

                ToolbarItem(placement: .confirmationAction) {
                    if isCreatingParty {
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
        isCreatingParty = true
        errorMessage = nil
        let descriptionToSave = partyDescription.isEmpty ? nil : partyDescription

        ApolloLynxClient.createParty(name: partyName, description: descriptionToSave) { result in
            DispatchQueue.main.async {
                self.isCreatingParty = false
                switch result {
                case .success(let newParty):
                    onPartyCreated(newParty)
                    dismiss()
                case .failure(let error):
                    self.errorMessage = "Failed to create party"
                    Logger.createPartyView.error("Error creating party: \(error)")
                }
            }
        }
    }
}

extension Logger {
    static let createPartyView = Logger(subsystem: "com.lynx", category: "CreatePartyView")
}

#Preview {
    CreatePartyView(onPartyCreated: { _ in })
}
