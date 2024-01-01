//
//  LoginView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift
import FacebookLogin

struct LoginView: View {
    @Environment(ProfileManager.self) private var profileManager
    
    private var loginHandler = LoginHandler()
    private var appleSignInHandler = AppleSignInHandler()
    private var googleSignInHandler = GoogleSignInHandler()
    private var facebookSignInHandler = FacebookSignInHandler()
    
    @State private var showSignInError = false
    @State private var showInvitationSheet = false
    @State private var isSigningIn = false
    
    // Aniamtion States
    @State private var moveInLogo = false
    @State private var moveInApple = false
    @State private var moveInGoogle = false
    @State private var moveInFacebook = false
    
    var body: some View {
        ZStack {
            backgroundLynxImage
            signLynxLogoAndSignInButtonStack
                .alert("Failed to Sign In", isPresented: $showSignInError) {
                    Button("OK") {
                        withAnimation {
                            isSigningIn = false
                        }
                    }
                } message: {
                    Text(
                        "It looks like we weren't able to sign you in. Please try again. If the issue continues, please contact the developers."
                    )
                }
        }
        .sheet(isPresented: $showInvitationSheet, content: {
            InvitationKeyView(isSigningIn: $isSigningIn) { // TODO: Some way to do this better??
                loginHandler.loginUser(profileManager: profileManager) { result in
                    switch result {
                    case .success(_):
                        profileManager.update(signInWith: true)
                    case .failure(_):
                        showSignInError = true
                    }
                }
            }
            .interactiveDismissDisabled()
        })
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                moveInLogo = true
            }
            withAnimation(.easeInOut(duration: 0.45).delay(0.3)) {
                moveInApple = true
            }
            withAnimation(.easeInOut(duration: 0.45).delay(0.45)) {
                moveInGoogle = true
            }
            withAnimation(.easeInOut(duration: 0.45).delay(0.6)) {
                moveInFacebook = true
            }
        }
    }
    
    // MARK: - Views
    private var backgroundLynxImage: some View {
        Image("LynxSignIn")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
    }
    
    private var signInWithAppleButton: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        }  onCompletion: { result in
            withAnimation {
                isSigningIn = true
            }
            appleSignInHandler.onCompletion(
                result,
                isSigningIn: $isSigningIn,
                showErrorSigningIn: $showSignInError
            ) { attributes, oauthToken in
                loginHandler.commonSignIn(
                    profileManager: profileManager,
                    withProfileAttributes: attributes,
                    oauthToken: oauthToken,
                    showInvitationSheet: $showInvitationSheet,
                    showSignInError: $showSignInError
                )
            }
        }
        .signInWithAppleButtonStyle(.white)
        .frame(
            width: Constants.SignInButton.width,
            height: Constants.SignInButton.height
        )
    }
    
    private var signInWithGoogleButton: some View {
        signInButton(company: "Google") {
            googleSignInHandler.signIn(
                isSigningIn: $isSigningIn,
                showErrorSigningIn: $showSignInError
            ) { attributes, oauthToken in
                loginHandler.commonSignIn(
                    profileManager: profileManager,
                    withProfileAttributes: attributes,
                    oauthToken: oauthToken,
                    showInvitationSheet: $showInvitationSheet,
                    showSignInError: $showSignInError
                )
            }
        }
    }
    
    private var signInWithFacebookButton: some View {
        signInButton(company: "Facebook") {
            facebookSignInHandler.signIn(
                isSigningIn: $isSigningIn,
                showErrorSigningIn: $showSignInError
            ) { attributes, oauthToken in
                loginHandler.commonSignIn(
                    profileManager: profileManager,
                    withProfileAttributes: attributes,
                    oauthToken: oauthToken,
                    showInvitationSheet: $showInvitationSheet,
                    showSignInError: $showSignInError
                )
            }
        }
    }
    
    private func signInButton(company: String, handler: @escaping () -> Void) -> some View {
        Button {
            withAnimation {
                isSigningIn = true
            }
            handler()

        } label: {
            logoAndSignInText(company: company)
        }
        .buttonStyle(SignInButtonStyle())
        .frame(
            width: Constants.SignInButton.width,
            height: Constants.SignInButton.height
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: Constants.SignInButton.cornerRadius
            )
        )
    }
    
    private struct SignInButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity)
                .padding()
                .background(configuration.isPressed ? .gray : .white)
                .transition(.opacity)
        }
    }
    
    private func logoAndSignInText(company: String) -> some View {
        HStack(spacing: Constants.SignInButton.spacing) {
            Image("\(company)Logo")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.logoWidth)
            
            Text("Sign in with \(company)")
                .foregroundStyle(.black)
                .font(
                    .system(size: Constants.SignInButton.fontSize,
                            weight: .medium)
                )
        }
    }
    
    
    private var signInProgressView: some View {
        ProgressView("Signing in...")
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .foregroundStyle(.white)
            .padding(.bottom)
    }
    
    @ViewBuilder
    private var signLynxLogoAndSignInButtonStack: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 15) {
                Spacer()
                Image("LynxLogo")
                    .resizable()
                    .scaledToFit()
                    .opacity(moveInLogo ? 1 : 0)
                    .frame(width: Constants.Logo.width)
                    .position(
                        x: geometry.size.width / 10 - Constants.Logo.xOffset,
                        y: geometry.size.height / 2.2 - Constants.Logo.yOffset
                    )
                if isSigningIn {
                    signInProgressView
                } else {
                    signInWithAppleButton
                        .offset(y: moveInApple ? 10 : 250)
                    signInWithGoogleButton
                        .offset(y: moveInGoogle ? 10 : 200)
                    signInWithFacebookButton
                        .offset(y: moveInFacebook ? 10 : 150)
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    
    // MARK: - Constants
    private struct Constants {
        struct Logo {
            static let width: CGFloat = 150
            static let xOffset: CGFloat = -90
            static let yOffset: CGFloat = -40
        }
        
        struct SignInButton {
            static let width: CGFloat = 280
            static let height: CGFloat = 40
            static let cornerRadius: CGFloat = 7
            static let fontSize: CGFloat = 15
            static let spacing: CGFloat = 4
        }
        
        static let logoWidth: CGFloat = 14
    }
}

#Preview {
    LoginView()
}
