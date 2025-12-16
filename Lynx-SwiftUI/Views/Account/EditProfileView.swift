import SwiftUI
import PhotosUI
import OSLog
import TOCropViewController

struct EditProfileView: View {
    var profileManager: ProfileManager
    @Environment(\.dismiss) private var dismiss

    @State private var profilePictureItem: PhotosPickerItem?
    @State private var newProfilePictureData: Data?
    @State private var newProfilePicture: Image?

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""

    @State private var showSavingChanges = false

    @State private var showDeleteAccountConfirmation = false
    @State private var showFailedToDeleteAccount = false
    @State private var showMergeAccountsNotAvailable = false

    private let tocropDelegate = TOCropDelegate()

    init(profileManager: ProfileManager) {
        self.profileManager = profileManager
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                changeProfilePicture
                Form {
                    nameAndEmailEditableSection
                    mergeAccountsSection
                    deleteAccountButton
                }
                Spacer()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(showSavingChanges)
            .confirmationDialog("Confirm Deletion of Account", isPresented: $showDeleteAccountConfirmation) {
                Button("Cancel", role: .cancel) {
                    showDeleteAccountConfirmation = false
                }
                Button("Delete Account", role: .destructive) {
                    showSavingChanges = true
#if DEBUG
                    LoginHandler.signOut()
#else
                    deleteAccount { result in
                        switch result {
                        case .success(_):
                            LoginHandler.signOut()
                        case .failure(let error):
                            Logger.editProfileView.error("Failed to delete account: \(error)")
                        }
                        showSavingChanges = false
                    }
#endif
                }
            } message: {
                Text("Are you sure you want to proceed with deleting your account? This action cannot be undone.")
            }
            .alert("Failed to Delete Account", isPresented: $showFailedToDeleteAccount) { }
            .alert("Feature Not Available", isPresented: $showMergeAccountsNotAvailable) { } message: {
                Text("Merging your Google or Apple accounts together is not yet available. Stay tuned for updates!")
            }
            .toolbar {
                ToolbarItemGroup(placement: .confirmationAction) {
                    if showSavingChanges {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Button {
                            showSavingChanges = true
                            saveEdits(
                                withFirstName: firstName,
                                lastName: lastName,
                                email: email,
                                profilePictureData: newProfilePictureData
                            ) {
                                showSavingChanges = false
                                dismiss()
                            }
                        } label: {
                            Text("Save")
                                .fontWeight(.bold)
                        }
                    }
                }
            }
        }
        .onAppear {
            if let profile = profileManager.profile {
                firstName = profile.firstName
                lastName = profile.lastName
                email = profile.email
            }
            
            tocropDelegate.didCropImage = { croppedImage in
                newProfilePicture = Image(uiImage: croppedImage)
            }
        }
        .disabled(showSavingChanges)
    }
    
    private var changeProfilePicture: some View {
        VStack {
            if let newProfilePicture {
                newProfilePicture
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(maxWidth: Constants.profilePictureWidth)
            } else {
                if let profilePicture = profileManager.profilePicture {
                    profilePicture
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(maxWidth: Constants.profilePictureWidth)
                } else {
                    ProgressView().padding()
                }
            }
            PhotosPicker("Change Profile Picture", selection: $profilePictureItem)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .onChange(of: profilePictureItem) { _, _ in
                    Task {
                        if let data = try? await profilePictureItem?.loadTransferable(type: Data.self) {
                            newProfilePictureData = data
                            if let uiImage = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    presentTOCropView(withImage: uiImage)
                                }
                            }
                        }
                    }
                }
        }
    }
    
    private var nameAndEmailEditableSection: some View {
        Section {
            HStack {
                Text("Name")
                    .bold()
                    .padding(.trailing)
                
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
            }
            HStack {
                Text("Email")
                    .bold()
                    .padding(.trailing)
                
                TextField("Email", text: $email)
            }
        }
    }
    
    private var mergeAccountsSection: some View {
        Section {
            Button {
                showMergeAccountsNotAvailable = true
            } label: {
                Label("Merge Accounts", systemImage: "shared.with.you")
            }
        }
    }
    
    private var deleteAccountButton: some View {
        Button {
            showDeleteAccountConfirmation = true
        } label: {
            Label("Delete Account", systemImage: "trash.fill")
                .foregroundStyle(showSavingChanges ? .gray : .red)
        }
    }

    // MARK: - Edit Profile Logic
    private func saveEdits(
        withFirstName firstName: String,
        lastName: String,
        email: String,
        profilePictureData: Data? = nil,
        completion: @escaping () -> Void
    ) {
        profileManager.edit(
            newFirstName: firstName,
            newLastName: lastName,
            newEmail: email
        )
#if DEBUG
        completion()
#else
        var profileChanges: [String: Any] = [:]
        profileChanges[ProfileChangesKeys.firstName.rawValue] = firstName
        profileChanges[ProfileChangesKeys.lastName.rawValue] = lastName
        profileChanges[ProfileChangesKeys.email.rawValue] = email

        var waitForPicturePropogate = false
        if let profilePictureData {
            putRequest(newProfilePictureData: profilePictureData)
            waitForPicturePropogate = true
        }

        ApolloLynxClient.editUser(profileChanges: profileChanges) { result in
            switch result {
            case .success(let newProfilePictureURL):
                Logger.editProfileHandler.info("Retrieved new profile picture URL: \(newProfilePictureURL)")
                if let newURL = URL(string: newProfilePictureURL) {
                    // Poll profile pic until it's different or time limit is up
                    if waitForPicturePropogate {
                        self.pollProfilePictureChange(
                            newProfilePictureData: profilePictureData!,
                            newProfilePictureURL: newURL,
                            completion: completion
                        )
                    } else {
                        completion()
                    }
                }
            case .failure(_):
                Logger.editProfileHandler.error("Failed to get new profile picture URL. Using old picture.")
                completion() // Dismiss view and stops ProgressView
            }
        }
#endif
    }

    private func putRequest(newProfilePictureData data: Data) {
        Task {
            ApolloLynxClient.createUserProfilePictureUploadUrl { result in
                switch result {
                case .success(let url):
                    Logger.editProfileHandler.info("Successfully retrieved new URL: \(url)")
                    guard let url = URL(string: url) else {
                        Logger.editProfileHandler.error("Failed to convert String URL into URL coming back from createUserProfilePictureUploadURL")
                        return
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = "PUT"

                    // Set the content type for the request
                    let contentType = "image/jpeg"
                    request.setValue(contentType, forHTTPHeaderField: "Content-Type")

                    request.httpBody = data
                    URLSession.shared.reset { [request] in
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let error = error {
                                Logger.editProfileHandler.error("Failed to upload new profile picture to S3: \(error)")
                                return
                            }

                            if let response = response as? HTTPURLResponse {
                                Logger.editProfileHandler.info("Response status code: \(response.statusCode)")
                            }
                        }.resume()
                    }
                case .failure(_):
                    Logger.editProfileHandler.error("Failed to retrieve URL.")
                }
            }
        }
    }

    private func pollProfilePictureChange(
        newProfilePictureData newData: Data,
        newProfilePictureURL: URL,
        completion: @escaping () -> Void
    ) {
        let pollInterval: TimeInterval = 2.0
        let maxAttempts = 10

        var attempts = 0

        // Start the polling loop
        func poll() {
            Logger.editProfileHandler.debug("Polling attempt #\(attempts)")
            // Check if the profile picture has changed
            getDataAsync(from: newProfilePictureURL) { currentData in
                if newData == currentData {
                    DispatchQueue.main.async {
                        profileManager.update(newProfilePictureURLWith: newProfilePictureURL)
                        completion() // Dismiss view and stop ProgressView
                    }
                } else {
                    // Profile picture hasn't changed yet
                    if attempts < maxAttempts {
                        // Schedule the next poll
                        DispatchQueue.main.asyncAfter(deadline: .now() + pollInterval) {
                            attempts += 1
                            poll()
                        }
                    } else {
                        // Maximum attempts reached, stop polling
                        DispatchQueue.main.async {
                            profileManager.update(newProfilePictureURLWith: newProfilePictureURL)
                            completion()
                        }
                    }
                }
            }
        }

        // Initial poll
        poll()
    }

    private func getDataAsync(from url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                print("Error fetching data from URL: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }

    private func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        ApolloLynxClient.deleteAccount(
            token: UserManager.shared.lynxToken!.accessToken,
            type: .init(rawValue: profileManager.profile!.oauthType)!,
            completion: completion
        )
    }

    private struct Constants {
        static let profilePictureWidth: CGFloat = 110
    }

    private enum ProfileChangesKeys: String {
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
    }
}


// MARK: - TOCropController
extension EditProfileView {
    private final class TOCropDelegate: NSObject, TOCropViewControllerDelegate {
        var didCropImage: ((UIImage) -> Void)?
        
        func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
            didCropImage?(image)
            cropViewController.dismiss(animated: true)
        }
    }
    
    private func presentTOCropView(withImage image: UIImage) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let vc = window?.rootViewController
        
        let cropVC = TOCropViewController(croppingStyle: .circular, image: image)
        cropVC.delegate = tocropDelegate
        cropVC.aspectRatioLockEnabled = true
        cropVC.resetAspectRatioEnabled = false
        vc?.present(cropVC, animated: true, completion: nil)
    }
    
}

#Preview {
    EditProfileView(profileManager: ProfileManager.shared)
}



