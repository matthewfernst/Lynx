//
//  S3Utils.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/13/23.
//
import AWSClientRuntime
import AWSS3
import ClientRuntime
import Foundation
import UIKit

enum S3BucketNames: String {
    case zippedSlopesBucketName = "mountain-ui-app-slopes-zipped"
    case profilePictureBucketName = "mountain-ui-users-profile-pictures"
}

struct S3Utils {
    private static let s3Client = try! S3Client(region: "us-east-1")
    
    
    static func uploadSlopesDataToS3(uuid: String, file: URL) async throws {
        let fileKey = "\(uuid)/\(file.lastPathComponent)"
        let fileData = try Data(contentsOf: file)
        
        do {
            try await uploadData(fileKey: fileKey, fileData: fileData, bucketName: S3BucketNames.zippedSlopesBucketName.rawValue)
        } catch {
            print("\(error)")
        }
    }
    
    static func uploadProfilePictureToS3(uuid: String, picture: UIImage) async throws {
        let fileKey = "\(uuid)/profilePicture"
        let fileData = picture.jpegData(compressionQuality: 8.0)!
        
        do {
            try await uploadData(fileKey: fileKey, fileData: fileData, bucketName: S3BucketNames.profilePictureBucketName.rawValue)
        } catch {
            print("\(error)")
        }
    }
    
    private static func uploadData(fileKey: String, fileData: Data, bucketName: String) async throws {
        let _ = try await createFile(key: fileKey, data: fileData, bucketName: bucketName)
    }


    static func getObjectURL(uuid: String) async -> String {
        let fileKey = "\(uuid)/profilePicture"
        do {
            let inputObject = GetObjectInput(bucket: S3BucketNames.profilePictureBucketName.rawValue, key: fileKey)
            let _ = try await s3Client.getObject(input: inputObject)
            
            // ...
        } catch {
            dump(error)
        }
        
        let s3BucketURL = "https://mountain-ui-users-profile-pictures.s3.amazonaws.com"
        let objectURL = "\(s3BucketURL)/\(fileKey)"
        
        return objectURL
    }

    
    static func createFile(key: String, data: Data, bucketName: String) async throws -> PutObjectOutputResponse {
        let dataStream = ByteStream.from(data: data)
        let input = PutObjectInput(
            body: dataStream,
            bucket: bucketName,
            key: key
        )
        return try await s3Client.putObject(input: input)
    }
}
