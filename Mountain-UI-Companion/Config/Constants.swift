//
//  Constants.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/22/23.
//

import Foundation
import AWSDynamoDB

enum Constants {
    // Settings
    static let twitter = "https://twitter.com/ErnstMatthew"
    static let github = "https://github.com/matthewfernst/Mountain-UI-Companion-App"
    static let buyMeCoffee = "https://www.buymeacoffee.com/matthewfernst"
    static let mountainUIDisplayGitub = "https://github.com/matthewfernst/Mountain-UI"
    
    // AWS
    static let usersTable = "mountain-ui-app-users"
    static let dynamoDbClient = try! DynamoDBClient(region: "us-west-2")
}
