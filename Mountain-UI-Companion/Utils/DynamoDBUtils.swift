//
//  DynamoDBUtils.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/12/23.
//

import Foundation
import AWSDynamoDB
import ClientRuntime

struct DynamoDBUtils
{
    static let usersTable = "mountain-ui-app-users"
    static let dynamoDBClient = try! DynamoDBClient(region: "us-west-2")
    
    static func putDynamoDBItem(profileAttributes: ProfileAttributes) async {
        let itemValues = [
            "uuid": DynamoDBClientTypes.AttributeValue.s(profileAttributes.uuid),
            "firstName": DynamoDBClientTypes.AttributeValue.s(profileAttributes.firstName),
            "lastName": DynamoDBClientTypes.AttributeValue.s(profileAttributes.lastName),
            "email": DynamoDBClientTypes.AttributeValue.s(profileAttributes.email),
            "profilePictureURL": DynamoDBClientTypes.AttributeValue.s(profileAttributes.profilePictureURL)
        ]
        let input = PutItemInput(item: itemValues, tableName: usersTable)
        do {
            _ = try await dynamoDBClient.putItem(input: input)
        } catch {
            print("ERROR in putDynamoDBItem: \(error)")
        }
    }
    
    static func getDynamoDBItem(uuid: String) async -> [String : DynamoDBClientTypes.AttributeValue]? {
        let keyToGet = ["uuid" : DynamoDBClientTypes.AttributeValue.s(uuid)]
        let input = GetItemInput(key: keyToGet, tableName: usersTable)
        do {
            return try await dynamoDBClient.getItem(input: input).item
        } catch {
            print("ERROR in getDynamoDBItem: \(error)")
        }
        return nil
    }
    
    static func updateDynamoDBItem(uuid: String,
                                   newFirstName: String,
                                   newLastName: String,
                                   newEmail: String,
                                   newProfilePictureURL: String) async {
        let itemKey = ["uuid" : DynamoDBClientTypes.AttributeValue.s(uuid)]
        let updatedValues = [
            "firstName": DynamoDBClientTypes.AttributeValueUpdate(action: .put, value: DynamoDBClientTypes.AttributeValue.s(newFirstName)),
            "lastName": DynamoDBClientTypes.AttributeValueUpdate(action: .put, value: DynamoDBClientTypes.AttributeValue.s(newLastName)),
            "email": DynamoDBClientTypes.AttributeValueUpdate(action: .put, value: DynamoDBClientTypes.AttributeValue.s(newEmail)),
            "profilePictureURL": DynamoDBClientTypes.AttributeValueUpdate(action: .put, value: DynamoDBClientTypes.AttributeValue.s(newProfilePictureURL))
        ]
        do {
            let _ = try await dynamoDBClient.updateItem(input: UpdateItemInput(attributeUpdates: updatedValues, key: itemKey, tableName: usersTable))
            
        } catch {
            print("ERROR in updateDynamoDBItem: \(error)")
        }
    }
    
    static func deleteDynamoDBItem(uuid: String) async {
        let keyToDelete = ["uuid" : DynamoDBClientTypes.AttributeValue.s(uuid)]
        
        do {
            let _ = try await dynamoDBClient.deleteItem(input: DeleteItemInput(key: keyToDelete,
                                                                               tableName: usersTable))
        } catch {
            print("ERROR in deleteDynamoDBItem: \(error)")
        }
        
    }
}
