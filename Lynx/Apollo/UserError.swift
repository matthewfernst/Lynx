//
//  UserError.swift
//  Lynx
//
//  Created by Matthew Ernst on 4/30/23.
//

import Foundation

enum UserError: Error {
    case noAuthorizationTokenReturned
    case noProfileAttributesReturned
}
