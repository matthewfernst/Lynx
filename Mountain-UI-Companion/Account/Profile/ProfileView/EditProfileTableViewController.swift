//
//  ProfileTableViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

protocol EditProfileDelegate {
    func editProfileCompletionHandler(profile: Profile)
}

class EditProfileTableViewController: UITableViewController
{
    public static var identifier = "EditProfileTableViewController"
    
    public var profile: Profile!
    
    var delegate: EditProfileDelegate?
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let dynamoDBClient = DynamoDBUtils.dynamoDBClient
    private let userTable = DynamoDBUtils.usersTable
    
    private var changedFirstName: String? = nil
    private var changedLastName: String? = nil
    private var changedEmail: String? = nil
    private var changedProfilePicture: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Profile"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(goBackToSettings))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveProfileChangesButtonTapped))
        
        
        self.tableView.delaysContentTouches = true
        
        tableView.register(EditProfilePictureTableViewCell.self, forCellReuseIdentifier: EditProfilePictureTableViewCell.identifier)
        tableView.register(EditNameTableViewCell.self, forCellReuseIdentifier: EditNameTableViewCell.identifier)
        tableView.register(EditEmailTableViewCell.self, forCellReuseIdentifier: EditEmailTableViewCell.identifier)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
    
    @objc func goBackToSettings() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func handleProfilePictureChange(newProfilePicture: UIImage) {
        changedProfilePicture = newProfilePicture
    }
    
    @objc func saveProfileChangesButtonTapped() {
        activityIndicator.startAnimating()
        Task.detached { [weak self] in
            await self?.saveProfileChanges()
        }
    }
    
    private func saveProfileChanges() async {
        let newFirstName = changedFirstName ?? self.profile.firstName
        let newLastName = changedLastName ?? self.profile.lastName
        let newEmail = changedEmail ?? self.profile.email
        
        var newProfilePictureURL = self.profile.profilePictureURL
        if let changedProfilePicture = changedProfilePicture {
            do {
                // Upload new profile picture to S3
                try await S3Utils.uploadProfilePictureToS3(uuid: self.profile.uuid, picture: changedProfilePicture)
                // Get new profile picture's Object URL
                let objectURL = await S3Utils.getObjectURL(uuid: self.profile.uuid)
                newProfilePictureURL = objectURL
            } catch {
                // Handle error
                print("Error uploading profile picture: \(error)")
            }
        }
        
        Task {
            // Update Dynamo
            await DynamoDBUtils.updateDynamoDBItem(uuid: self.profile.uuid,
                                                   newFirstName: newFirstName,
                                                   newLastName: newLastName,
                                                   newEmail: newEmail,
                                                   newProfilePictureURL: newProfilePictureURL ?? "")
        }
        
        Profile.createProfile(uuid: profile.uuid,
                              firstName: newFirstName,
                              lastName: newLastName,
                              email: newEmail,
                              profilePictureURL: newProfilePictureURL) { [unowned self] newProfile in
            
            self.delegate?.editProfileCompletionHandler(profile: newProfile)
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - TableViewController Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return EditProfileSections.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch EditProfileSections(rawValue: indexPath.section) {
        case .changeProfilePicture:
            return 150
        default:
            return -1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch EditProfileSections(rawValue: section) {
        case .changeProfilePicture:
            return 1
        default:
            return 18
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch EditProfileSections(rawValue: section) {
        case .changeProfilePicture:
            return 1
        case .changeNameAndEmail:
            return 2
        case .signOut:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch EditProfileSections(rawValue: indexPath.section) {
        case .changeProfilePicture:
            guard let editProfileCell = tableView.dequeueReusableCell(withIdentifier: EditProfilePictureTableViewCell.identifier, for: indexPath) as? EditProfilePictureTableViewCell else {
                return UITableViewCell()
            }
            
            editProfileCell.configure(withProfile: self.profile, delegate: self)
            
            return editProfileCell
            
        case .changeNameAndEmail:
            switch NameAndEmailRows(rawValue: indexPath.row) {
            case .name:
                guard let editNameCell = tableView.dequeueReusableCell(withIdentifier: EditNameTableViewCell.identifier, for: indexPath) as? EditNameTableViewCell else {
                    return UITableViewCell()
                }
                
                editNameCell.configure(name: profile.name, delegate: self)
                
                return editNameCell
                
            case .email:
                guard let editEmailCell = tableView.dequeueReusableCell(withIdentifier: EditEmailTableViewCell.identifier, for: indexPath) as? EditEmailTableViewCell else { return UITableViewCell()
                }
                editEmailCell.configure(email: profile.email, delegate: self)
                
                return editEmailCell
            default:
                return UITableViewCell()
            }
            
        case .signOut:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
            var configuation = cell.defaultContentConfiguration()
            
            configuation.text = "Sign Out"
            configuation.textProperties.alignment = .center
            configuation.textProperties.color = .red
            
            cell.backgroundColor = .secondarySystemBackground
            cell.contentConfiguration = configuation
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch EditProfileSections(rawValue: indexPath.section) {
        case .signOut:
            self.profile.signOut()
            if let vc = self.storyboard?.instantiateInitialViewController() as? LoginViewController {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
            }
        default:
            break
        }
    }
    
}

// MARK: - Name and Email TextField Delegate
extension EditProfileTableViewController: UITextFieldDelegate {
    
    private func setTextForProfile(text: String, tag: Int) {
        switch EditProfileTextFieldTags(rawValue: tag) {
        case .firstName:
            changedFirstName = text
        case .lastName:
            changedLastName = text
        case .email:
            changedEmail = text
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let text = textField.text else { return false }
        
        setTextForProfile(text: text, tag: textField.tag)
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else { return false }
        text = (text as NSString).replacingCharacters(in: range, with: string)
        
        setTextForProfile(text: text, tag: textField.tag)
        
        return true
    }
}
