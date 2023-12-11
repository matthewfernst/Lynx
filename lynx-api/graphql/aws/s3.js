"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteObjectsInBucket = exports.getRecordFromBucket = exports.getObjectNamesInBucket = exports.checkIfObjectInBucket = exports.createSignedUploadUrl = exports.toRunRecordsBucket = exports.fromRunRecordsBucket = exports.profilePictureBucketName = void 0;
const client_s3_1 = require("@aws-sdk/client-s3");
const s3_request_presigner_1 = require("@aws-sdk/s3-request-presigner");
exports.profilePictureBucketName = "lynx-profile-pictures";
exports.fromRunRecordsBucket = "lynx-slopes-zipped";
exports.toRunRecordsBucket = "lynx-slopes-unzipped";
const createS3Client = () => {
    if (!process.env.AWS_REGION)
        throw new Error("AWS_REGION Is Not Defined");
    return new client_s3_1.S3Client({ region: process.env.AWS_REGION });
};
const createSignedUploadUrl = async (bucketName, path) => {
    const s3Client = createS3Client();
    try {
        const command = new client_s3_1.PutObjectCommand({ Bucket: bucketName, Key: path });
        return await (0, s3_request_presigner_1.getSignedUrl)(s3Client, command);
    }
    catch (err) {
        console.error(err);
        throw Error("Error creating url for file upload");
    }
};
exports.createSignedUploadUrl = createSignedUploadUrl;
const checkIfObjectInBucket = async (bucketName, path) => {
    const s3Client = createS3Client();
    try {
        const headObjectRequest = new client_s3_1.HeadObjectCommand({
            Bucket: bucketName,
            Key: path
        });
        await s3Client.send(headObjectRequest);
        return true;
    }
    catch (error) {
        return false;
    }
};
exports.checkIfObjectInBucket = checkIfObjectInBucket;
const getObjectNamesInBucket = async (bucketName, prefix = "") => {
    const s3Client = createS3Client();
    try {
        const listObjectsRequest = new client_s3_1.ListObjectsCommand({ Bucket: bucketName, Prefix: prefix });
        const listObjectsResponse = await s3Client.send(listObjectsRequest);
        if (!listObjectsResponse.Contents) {
            return [];
        }
        const predicate = (content) => content.Key;
        return listObjectsResponse.Contents.filter(predicate).map(predicate);
    }
    catch (err) {
        console.error(err);
        throw Error(`Error retrieving records from bucket with prefix ${prefix}`);
    }
};
exports.getObjectNamesInBucket = getObjectNamesInBucket;
const getRecordFromBucket = async (bucketName, key) => {
    const s3Client = createS3Client();
    try {
        const getObjectRequest = new client_s3_1.GetObjectCommand({ Bucket: bucketName, Key: key });
        const getObjectResponse = await s3Client.send(getObjectRequest);
        if (!getObjectResponse.Body) {
            throw new Error(`Error reading information about item in bucket`);
        }
        return await getObjectResponse.Body.transformToString();
    }
    catch (err) {
        console.error(err);
        throw Error(`Error retrieving record from bucket`);
    }
};
exports.getRecordFromBucket = getRecordFromBucket;
const deleteObjectsInBucket = async (bucketName, prefix) => {
    const s3Client = createS3Client();
    try {
        const deleteObjectRequest = new client_s3_1.DeleteObjectCommand({ Bucket: bucketName, Key: prefix });
        await s3Client.send(deleteObjectRequest);
    }
    catch (err) {
        console.error(err);
        throw Error(`Error deleting records from bucket`);
    }
};
exports.deleteObjectsInBucket = deleteObjectsInBucket;
