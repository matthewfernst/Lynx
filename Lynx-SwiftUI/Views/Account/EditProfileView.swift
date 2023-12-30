//
//  EditProfileView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/29/23.
//

import SwiftUI
import PhotosUI
import OSLog

struct EditProfileView: View {
    var profileManager: ProfileManager
    @Environment(\.dismiss) private var dismiss
    
    private var editProfileHandler = EditProfileHandler()
    
    @State private var profilePictureItem: PhotosPickerItem?
    @State private var newProfilePictureData: Data?
    @State private var newProfilePicture: Image?
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    
    @State private var showSavingChanges = false
    
//    @State private var goToLogin = false
    @State private var showDeleteAccountConfirmation = false
    @State private var showFailedToDeleteAccount = false
    @State private var showMergeAccountsNotAvailable = false
    
    init(profileManager: ProfileManager) {
        self.profileManager = profileManager
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                changeProfilePicture
                Form {
                    nameAndEmailEditableSection
                    mergeAndSignOutSection
                    deleteAccount
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
                    editProfileHandler.deleteAccount(profileManager: profileManager) { result in
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
                            editProfileHandler.saveEdits(
                                profileManager: profileManager,
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
        }
        .disabled(showSavingChanges)
//        .fullScreenCover(isPresented: $goToLogin, content: LoginView.init)
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
                AsyncImage(url: profileManager.profile?.profilePictureURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: Constants.profilePictureWidth)
            }
            PhotosPicker("Change Profile Picture", selection: $profilePictureItem)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .onChange(of: profilePictureItem) { _, _ in
                    Task {
                        if let data = try? await profilePictureItem?.loadTransferable(type: Data.self) {
                            newProfilePictureData = data
                            if let uiImage = UIImage(data: data) {
                                newProfilePicture = Image(uiImage: uiImage)
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
    
    private var mergeAndSignOutSection: some View {
        Section {
            Button {
                showMergeAccountsNotAvailable = true
            } label: {
                Label("Merge Accounts", systemImage: "shared.with.you")
            }
            Button {
                LoginHandler.signOut()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.forward")
            }
        }
    }
    
    private var deleteAccount: some View {
        Button {
            showDeleteAccountConfirmation = true
        } label: {
            Label("Delete Account", systemImage: "trash.fill")
                .foregroundStyle(showSavingChanges ? .gray : .red)
        }
    }
    
    private struct Constants {
        static let profilePictureWidth: CGFloat = 110
    }
}


#Preview {
    EditProfileView(profileManager: ProfileManager.shared)
}



