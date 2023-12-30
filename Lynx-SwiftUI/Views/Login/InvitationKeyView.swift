//
//  InvitationKeyView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/1/23.
//

import SwiftUI
import OSLog

struct InvitationKeyView: View {
    @Binding var isSigningIn: Bool
    @Environment(\.dismiss) private var dismiss
    private let completion: (()-> Void)
    
    @State private var key = ""
    @State private var showDontHaveInvitationAlert = false
    @State private var showInvalidKeyAlert = false
    
    init(isSigningIn: Binding<Bool>, completion: @escaping () -> Void) {
        self._isSigningIn = isSigningIn
        self.completion = completion
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Invitation Key")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.top)

                Spacer()
                
                Text(Constants.explanation)
                    .multilineTextAlignment(.center)
                
                ZStack {
                    keyInput
                    backgroundField
                }
                .padding()
                Button {
                    showDontHaveInvitationAlert = true
                } label: {
                    Text("Don't have an invitation key?")
                        .font(.callout)
                }
                .padding(.bottom)
                
                ProgressView("Verifying...")
                    .opacity(keyLengthEqualToInputLength ? 1 : 0)
                
                Spacer()
            }
            .padding()
            .alert("Need an Invitation Key?", isPresented: $showDontHaveInvitationAlert) {} message: {
                Text(Constants.howToGetInviteKey)
            }
            .alert("Invalid Key", isPresented: $showInvalidKeyAlert) {
                Button {
                    key = ""
                } label: {
                    Text("Dismiss")
                }
            } message: {
                Text(Constants.invalidKeyExplanation)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isSigningIn = false
                        dismiss()
                    }
                }
            }

        }
    }
    
    private var backgroundField: some View {
        let boundKey = Binding<String>(get: { self.key }, set: { newValue in
            self.key = newValue
            self.submitKey()
        })
        
        return TextField("", text: boundKey, onCommit: submitKey)
            .keyboardType(.numberPad)
            .foregroundStyle(.clear)
            .tint(.clear)
            
    }
    
    private func submitKey() {
        guard !key.isEmpty else { return }
        
        if keyLengthEqualToInputLength {
            ApolloLynxClient.submitInviteKey(with: key) { result in
                switch result {
                case .success(_):
                    Logger.invitationKeySheet.info("Invitation successfully validated.")
                    dismiss()
                    completion()
                case .failure(_):
                    Logger.invitationKeySheet.error("Invitation failed to validate.")
                    showInvalidKeyAlert = true
                }
            }
        }
        
        // If the user pastes in a code, we truncate the string to the first inputLength characters
        if key.count > Constants.KeyInput.inputLength {
            key = String(key.prefix(Constants.KeyInput.inputLength))
            submitKey()
        }
    }

    private var keyInput: some View {
        HStack {
            ForEach(0..<Constants.KeyInput.inputLength, id: \.self) { index in
                if let digit = getDigit(forKeyIndex: index) {
                    Text(digit)
                        .font(.system(size: Constants.KeyInput.Font.size, weight: .semibold))
                        .frame(width: Constants.KeyInput.inputFrameWidth)
                        .padding(.horizontal, Constants.KeyInput.horizontalPadding)
                } else {
                    RoundedRectangle(cornerRadius: Constants.KeyInput.cornerRadius)
                        .frame(
                            width: Constants.KeyInput.inputFrameWidth,
                            height: Constants.KeyInput.inputFrameHeight
                        )
                        .padding(.horizontal, Constants.KeyInput.horizontalPadding)
                        .padding(.vertical, Constants.KeyInput.verticalPadding)
                }
                
                if index == (Constants.KeyInput.inputLength / 2) - 1 {
                    Spacer()
                        .frame(width: Constants.KeyInput.separationWidth)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private var keyLengthEqualToInputLength: Bool {
        withAnimation {
            key.count == Constants.KeyInput.inputLength
        }
    }
    
    private func getDigit(forKeyIndex index: Int) -> String? {
        if !key.isEmpty,
           let currentIndex = key.index(key.startIndex, offsetBy: index, limitedBy: key.index(before: key.endIndex)) {
            return String(key[currentIndex])
        }
        return nil
        
    }
    
    
    private struct Constants {
        static let explanation = """
                                 An invitation key is needed to create an account. Enter your key to continue.
                                 """
        
        static let howToGetInviteKey = """
                                       Invitation keys are required to create an account with Lynx. If you don't have an invitation key, you can request one from a friend who already has an account.
                                       """
        
        static let invalidKeyExplanation = """
                                            The key entered is not recognized in our system. This could be because your invitation has expired. Please double-check the key and try again. If you believe there is an error, please contact our developers for assistance.
                                            """
        
        struct KeyInput {
            static let inputLength: Int = 6
            
            static let inputFrameWidth: CGFloat = 20
            static let inputFrameHeight: CGFloat = 5
            
            static let cornerRadius: CGFloat = 25
            
            static let horizontalPadding: CGFloat = 8
            static let verticalPadding: CGFloat = 18
            
            static let separationWidth: CGFloat = 30
            
            struct Font {
                static let size: CGFloat = 28
            }
        }
    }
}

#Preview {
    InvitationKeyView(isSigningIn: .constant(true)) {
        
    }
}
