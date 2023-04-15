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
    static let dynamoDBClient = try! DynamoDBClient(region: "us-west-1")
    
    static func putDynamoDBItem(profileAttributes: ProfileAttributes) async {
        let itemValues = [
            "id": DynamoDBClientTypes.AttributeValue.s(profileAttributes.id),
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
    
    static func getDynamoDBItem(id: String) async -> [String : DynamoDBClientTypes.AttributeValue]? {
        let keyToGet = ["id" : DynamoDBClientTypes.AttributeValue.s(id)]
        let input = GetItemInput(key: keyToGet, tableName: usersTable)
        do {
            return try await dynamoDBClient.getItem(input: input).item
        } catch {
            print("ERROR in getDynamoDBItem: \(error)")
        }
        return nil
    }
    
    static func updateDynamoDBItem(id: String,
                                   newFirstName: String,
                                   newLastName: String,
                                   newEmail: String,
                                   newProfilePictureURL: String) async {
        let itemKey = ["id" : DynamoDBClientTypes.AttributeValue.s(id)]
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
    
    static func deleteDynamoDBItem(id: String) async {
        let keyToDelete = ["id" : DynamoDBClientTypes.AttributeValue.s(id)]
        
        do {
            let _ = try await dynamoDBClient.deleteItem(input: DeleteItemInput(key: keyToDelete,
                                                                               tableName: usersTable))
        } catch {
            print("ERROR in deleteDynamoDBItem: \(error)")
        }
        
    }
}
