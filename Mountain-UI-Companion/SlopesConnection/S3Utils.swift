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

struct S3Utils {
    private static let bucketName = "mountain-ui-app-slopes-zipped"
    private static let s3Client = try! S3Client(region: "us-east-1")
    
    static func uploadSlopesDataToS3(uuid: String, file: URL) async throws {
        let fileKey = "\(uuid)/\(file.lastPathComponent)"
        let fileData = try Data(contentsOf: file)
        
        let _ = try await S3Utils.createFile(key: fileKey, data: fileData)
    }
    
    static func createFile(key: String, data: Data) async throws -> PutObjectOutputResponse {
        let dataStream = ByteStream.from(data: data)
        let input = PutObjectInput(
            body: dataStream,
            bucket: bucketName,
            key: key
        )
        return try await s3Client.putObject(input: input)
    }
}
