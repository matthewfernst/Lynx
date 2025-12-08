import SwiftUI
import OSLog

struct InvitationKeyView: View {
    @Binding var isSigningIn: Bool
    @Environment(\.dismiss) private var dismiss
    private let completion: (()-> Void)
    
    private var inviteKeyHandler = InvitationKeyHandler()
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
                    .opacity(inviteKeyHandler.keyLengthEqualToInputLength ? 1 : 0)
                
                Spacer()
            }
            .padding()
            .alert("Need an Invitation Key?", isPresented: $showDontHaveInvitationAlert) {} message: {
                Text(Constants.howToGetInviteKey)
            }
            .alert("Invalid Key", isPresented: $showInvalidKeyAlert) {
                Button {
                    inviteKeyHandler.resetKey()
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
        let boundKey = Binding<String>(get: { inviteKeyHandler.key }, set: { newValue in
            // this set code is getting called twice for some reason 🤷‍♂️
            if newValue == inviteKeyHandler.key { return }
            
            inviteKeyHandler.key = newValue
            inviteKeyHandler.submitKey { correct in
                if correct {
                    dismiss()
                    completion()
                } else {
                    showInvalidKeyAlert = true
                }
            }
        })
        
        return TextField("", text: boundKey)
            .keyboardType(.numberPad)
            .foregroundStyle(.clear)
            .tint(.clear)
    }

    private var keyInput: some View {
        HStack {
            ForEach(0..<InvitationKeyHandler.Constants.inputLength, id: \.self) { index in
                if let digit = inviteKeyHandler.getDigit(forKeyIndex: index) {
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
                
                if index == (InvitationKeyHandler.Constants.inputLength / 2) - 1 {
                    Spacer()
                        .frame(width: Constants.KeyInput.separationWidth)
                }
            }
        }
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
