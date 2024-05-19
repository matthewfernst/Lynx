import { captureAWSv3Client } from "aws-xray-sdk";
import {
    S3Client,
    GetObjectCommand,
    HeadObjectCommand,
    ListObjectsCommand,
    PutObjectCommand,
    DeleteObjectCommand,
    _Object
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { NodeJsClient } from "@smithy/types";

import { GraphQLError } from "graphql";

import { DEPENDENCY_ERROR } from "../types";
import { NodeHttpHandler } from "@smithy/node-http-handler";

if (!process.env.AWS_REGION) throw new GraphQLError("AWS_REGION Is Not Defined");
const awsClient = new S3Client({ region: process.env.AWS_REGION });
export const s3Client = captureAWSv3Client(awsClient) as NodeJsClient<S3Client>;

export const createSignedUploadUrl = async (bucketName: string, path: string): Promise<string> => {
    try {
        const command = new PutObjectCommand({ Bucket: bucketName, Key: path });
        return await getSignedUrl(s3Client, command);
    } catch (err) {
        console.error(err);
        throw new GraphQLError("Error creating url for file upload", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export const checkIfObjectInBucket = async (bucketName: string, path: string) => {
    const customS3Client = new S3Client({
        region: process.env.AWS_REGION,
        requestHandler: new NodeHttpHandler({ requestTimeout: 400 })
    });
    try {
        const headObjectRequest = new HeadObjectCommand({ Bucket: bucketName, Key: path });
        await customS3Client.send(headObjectRequest);
        return true;
    } catch (err: any) {
        if (err.name === "NotFound") {
            return false;
        }
        console.error(err);
        throw new GraphQLError("Error checking if object in bucket", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export const getObjectNamesInBucket = async (
    bucketName: string,
    prefix: string = ""
): Promise<string[]> => {
    try {
        const listObjectsRequest = new ListObjectsCommand({ Bucket: bucketName, Prefix: prefix });
        const listObjectsResponse = await s3Client.send(listObjectsRequest);
        if (!listObjectsResponse.Contents) {
            return [];
        }
        const predicate = (content: _Object) => content.Key as string;
        return listObjectsResponse.Contents.filter(predicate).map(predicate);
    } catch (err) {
        console.error(err);
        throw new GraphQLError(`Error retrieving records from bucket with prefix ${prefix}`, {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export const getRecordFromBucket = async (bucketName: string, key: string): Promise<string> => {
    try {
        const getObjectRequest = new GetObjectCommand({ Bucket: bucketName, Key: key });
        const getObjectResponse = await s3Client.send(getObjectRequest);
        if (!getObjectResponse.Body) {
            throw new GraphQLError(`Error reading information about item in bucket`);
        }
        return await getObjectResponse.Body.transformToString();
    } catch (err) {
        console.error(err);
        throw new GraphQLError(`Error retrieving record from bucket`, {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export const deleteObjectsInBucket = async (bucketName: string, prefix: string) => {
    try {
        const deleteObjectRequest = new DeleteObjectCommand({ Bucket: bucketName, Key: prefix });
        await s3Client.send(deleteObjectRequest);
    } catch (err) {
        console.error(err);
        throw new GraphQLError(`Error deleting records from bucket`, {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};
