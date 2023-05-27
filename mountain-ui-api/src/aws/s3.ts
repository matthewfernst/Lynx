import {
    S3Client,
    GetObjectCommand,
    HeadObjectCommand,
    ListObjectsCommand,
    PutObjectCommand
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const createS3Client = (): S3Client => {
    if (!process.env.AWS_REGION) throw new Error("AWS_REGION Is Not Defined");
    return new S3Client({ region: process.env.AWS_REGION });
};

export const createSignedUploadUrl = async (bucketName: string, path: string) => {
    const s3Client = createS3Client();
    try {
        const command = new PutObjectCommand({ Bucket: bucketName, Key: path });
        return getSignedUrl(s3Client, command);
    } catch (err) {
        console.error(err);
        throw Error("Error creating url for file upload");
    }
};

export const checkIfObjectInBucket = async (bucketName: string, path: string) => {
    const s3Client = createS3Client();
    try {
        const headObjectRequest = new HeadObjectCommand({
            Bucket: bucketName,
            Key: path
        });
        await s3Client.send(headObjectRequest);
        return true;
    } catch (error) {
        return false;
    }
};

export const getRecordsFromBucket = async (bucketName: string, prefix: string = "") => {
    const s3Client = createS3Client();
    try {
        const listObjectsRequest = new ListObjectsCommand({ Bucket: bucketName, Prefix: prefix });
        const listObjectsResponse = await s3Client.send(listObjectsRequest);
        if (!listObjectsResponse.Contents) {
            throw new Error("Error retrieving info of items in bucket");
        }
        return await Promise.all(
            listObjectsResponse.Contents.map(async (content) => {
                const getObjectRequest = new GetObjectCommand({
                    Bucket: bucketName,
                    Key: content.Key
                });
                const getObjectResponse = await s3Client.send(getObjectRequest);
                if (!getObjectResponse.Body) {
                    throw new Error("Error reading information about item in bucket");
                }
                return await getObjectResponse.Body.transformToString();
            })
        );
    } catch (err) {
        console.error(err);
        throw Error("Error retrieving records from bucket with prefix");
    }
};
