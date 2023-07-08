//
//  Profile+Enums.swift
//  Lynx
//
//  Created by Matthew Ernst on 3/14/23.
//

import Foundation

enum DefaultProfilePictureIndex: Int, CaseIterable
{
    case accountSettings = 0
    case logBook = 1
}

enum EditProfileSections: Int, CaseIterable
{
    case changeProfilePicture = 0
    case changeNameAndEmail = 1
    case mergeAccountsOrSignOut = 2
    case deleteAccount = 3
}

enum MergeAccountOrSignOutRows: Int, CaseIterable
{
    case mergeAccounts = 0
    case signOut = 1
}

enum NameAndEmailRows: Int, CaseIterable
{
    case name = 0
    case email = 1
}

enum EditProfileTextFieldTags: Int, CaseIterable
{
    case firstName = 0
    case lastName = 1
    case email = 2
}

enum SignInType: String, CaseIterable
{
    case google = "GOOGLE"
    case apple = "APPLE"
}
