import AuthenticationServices
import FacebookLogin
import GoogleSignIn
import GoogleSignInSwift
import OSLog
import SwiftUI

struct LoginView: View {
  @Environment(ProfileManager.self) private var profileManager

  @State private var waveOffset: CGFloat = 0
  @State private var isWaving = false

  @State private var showSignInError = false
  @State private var isSigningIn = false

  // Animation States
  @State private var moveInLogo = false
  @State private var moveInApple = false
  @State private var moveInGoogle = false
  @State private var moveInFacebook = false

  private let funSignInPhrases = [
    Array("Waxing the skis ⛷️"),
    Array("Warming some cocoa 🍫"),
    Array("Drying out Long Johns 👖"),
    Array("Trying to find that other glove 🧤"),
  ]
  @State private var funSignInPhrase: [String.Element] = []

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
    .onAppear {
      funSignInPhrase = funSignInPhrases.randomElement() ?? Array("Signing in...")
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
    } onCompletion: { result in
      withAnimation {
        isSigningIn = true
      }
      handleAppleSignIn(result: result)
    }
    .signInWithAppleButtonStyle(.white)
    .frame(
      width: Constants.SignInButton.width,
      height: Constants.SignInButton.height
    )
  }

  private var signInWithGoogleButton: some View {
    signInButton(company: "Google") {
      handleGoogleSignIn()
    }
  }

  private var signInWithFacebookButton: some View {
    signInButton(company: "Facebook") {
      handleFacebookSignIn()
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
          .system(
            size: Constants.SignInButton.fontSize,
            weight: .medium
          )
        )
    }
  }

  private var signInProgressView: some View {
    VStack {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
        .foregroundStyle(.white)
        .padding(.bottom, 8)
      HStack(spacing: 0) {
        ForEach(0..<funSignInPhrase.count, id: \.self) { index in
          Text(String(funSignInPhrase[index]))
            .foregroundStyle(.white)
            .waveTextAnimation(amplitude: 10, frequency: 0.5, offset: isWaving ? 50 : 0)
            .animation(
              .easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(
                Double(-index) / 20), value: isWaving)
        }
      }
    }
    .padding()
    .onAppear {
      isWaving = true
    }
    .onDisappear {
      isWaving = false
    }
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

  private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
    switch result {
    case .success(let authorization):
      switch authorization.credential {
      case let appleIDCredential as ASAuthorizationAppleIDCredential:
        guard let appleJWT = String(data: appleIDCredential.identityToken!, encoding: .utf8) else {
          Logger.loginView.error("Unable to get Apple ID JWT.")
          showSignInError = true
          return
        }

        Logger.loginView.info("Successfully authorized Apple ID credentials.")

        let attributes = ProfileAttributes(
          id: appleIDCredential.user,
          oauthType: OAuthType.apple.rawValue,
          email: appleIDCredential.email,
          firstName: appleIDCredential.fullName?.givenName,
          lastName: appleIDCredential.fullName?.familyName
        )

        commonSignIn(withOAuthAttributes: attributes, oauthToken: appleJWT)

      default:
        showSignInError = true
        Logger.loginView.error("Failed to authorize Apple ID Credential.")
      }
    case .failure(let error):
      if (error as NSError).code == 1001 {  // Sign in cancelled
        isSigningIn = false
      } else {
        showSignInError = true
        Logger.loginView.error("Failed to authorize request: \(error)")
      }
    }
  }

  private func handleGoogleSignIn() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first,
      let rootViewController = window.rootViewController
    {
      GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
        guard error == nil else {
          let err = error as? NSError
          if err!.domain == kGIDSignInErrorDomain && err!.code == -5 {
            isSigningIn = false
          } else {
            showSignInError = true
          }
          return
        }

        guard let googleId = signInResult?.user.userID,
          let profile = signInResult?.user.profile,
          let oauthToken = signInResult?.user.idToken?.tokenString
        else {
          showSignInError = true
          return
        }

        let name = profile.name.components(separatedBy: " ")
        let (firstName, lastName) = (name[0], name[1])
        let email = profile.email

        var pictureURL: URL? = nil
        if let urlString = profile.imageURL(withDimension: 320)?.absoluteString {
          pictureURL = URL(string: urlString)
        }

        let attributes = ProfileAttributes(
          id: googleId,
          oauthType: OAuthType.google.rawValue,
          email: email,
          firstName: firstName,
          lastName: lastName,
          profilePictureURL: pictureURL
        )

        commonSignIn(withOAuthAttributes: attributes, oauthToken: oauthToken)
      }
    }
  }

  private func handleFacebookSignIn() {
    let fbLoginManager = LoginManager()

    fbLoginManager.logIn(
      permissions: ["public_profile", "email"],
      from: nil
    ) { result, error in
      if error != nil {
        showSignInError = true
        Logger.loginView.error("Error login in with Facebook: \(error)")
        return
      }

      let request = GraphRequest(
        graphPath: "me",
        parameters: ["fields": "id, first_name, last_name, email, picture.width(320).height(320)"]
      )

      if !result!.isCancelled {
        request.start { _, res, _ in
          guard let profileInfo = res as? [String: Any] else {
            showSignInError = true
            Logger.loginView.error("Error login in with Facebook. Unable to get profile data.")
            return
          }
          var profilePictureURL: URL? = nil
          if let profilePictureURLString =
            ((profileInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"]
            as? String
          {
            profilePictureURL = URL(string: profilePictureURLString)
          }

          let attributes = ProfileAttributes(
            id: profileInfo["id"] as! String,
            oauthType: OAuthType.facebook.rawValue,
            email: profileInfo["email"] as? String,
            firstName: profileInfo["first_name"] as? String,
            lastName: profileInfo["last_name"] as? String,
            profilePictureURL: profilePictureURL
          )

          commonSignIn(
            withOAuthAttributes: attributes, oauthToken: AccessToken.current!.tokenString)
        }
      } else {
        isSigningIn = false
      }
    }
  }

  private func commonSignIn(withOAuthAttributes attributes: ProfileAttributes, oauthToken: String) {
    #if DEBUG
      ProfileManager.shared.update(newProfileWith: Profile.debugProfile)
    #else
      ApolloLynxClient.oauthSignIn(
        id: attributes.id,
        oauthType: attributes.oauthType,
        oauthToken: oauthToken,
        email: attributes.email,
        firstName: attributes.firstName,
        lastName: attributes.lastName,
        profilePictureURL: attributes.profilePictureURL
      ) { result in
        switch result {
        case .success(_):
          Logger.loginView.info("Authorization Token successfully received.")
          loginUser()
        case .failure:
          showSignInError = true
        }
      }
    #endif
  }

  private func loginUser() {
    ApolloLynxClient.getProfileInformation { result in
      switch result {
      case .success(let profileAttributes):
        signInUser(profileAttributes: profileAttributes)
      case .failure(let error):
        Logger.loginView.error("Failed to login user. \(error)")
        showSignInError = true
      }
    }
  }

  private func signInUser(profileAttributes: ProfileAttributes) {
    ProfileManager.shared.update(
      newProfileWith: Profile(
        id: profileAttributes.id,
        oauthType: profileAttributes.oauthType,
        firstName: profileAttributes.firstName!,
        lastName: profileAttributes.lastName!,
        email: profileAttributes.email!,
        profilePictureURL: profileAttributes.profilePictureURL
      )
    )

    if ProfileManager.shared.profile != nil {
      ProfileManager.shared.update(signInWith: true)
    } else {
      showSignInError = true
    }
  }

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

struct WaveTextModifier: ViewModifier {
  let amplitude: CGFloat
  let frequency: CGFloat
  var offset: CGFloat

  func body(content: Content) -> some View {
    content
      .offset(y: amplitude * sin((.pi * frequency * offset) + .pi / 2))
  }
}

extension View {
  func waveTextAnimation(amplitude: CGFloat, frequency: CGFloat, offset: CGFloat) -> some View {
    self.modifier(WaveTextModifier(amplitude: amplitude, frequency: frequency, offset: offset))
  }
}

#Preview {
  LoginView()
}
