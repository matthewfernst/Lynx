import {
    S3Client,
    GetObjectCommand,
    HeadObjectCommand,
    ListObjectsCommand,
    PutObjectCommand,
    DeleteObjectCommand,
    ListObjectVersionsCommandOutput,
    _Object
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export const profilePictureBucketName = "lynx-profile-pictures";
export const fromRunRecordsBucket = "lynx-slopes-zipped";
export const toRunRecordsBucket = "lynx-slopes-unzipped";

const createS3Client = (): S3Client => {
    if (!process.env.AWS_REGION) throw new Error("AWS_REGION Is Not Defined");
    return new S3Client({ region: process.env.AWS_REGION });
};

export const createSignedUploadUrl = async (bucketName: string, path: string): Promise<string> => {
    const s3Client = createS3Client();
    try {
        const command = new PutObjectCommand({ Bucket: bucketName, Key: path });
        return await getSignedUrl(s3Client, command);
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

export const getObjectNamesInBucket = async (
    bucketName: string,
    prefix: string = ""
): Promise<string[]> => {
    const s3Client = createS3Client();
    try {
        const listObjectsRequest = new ListObjectsCommand({ Bucket: bucketName, Prefix: prefix });
        const listObjectsResponse = await s3Client.send(listObjectsRequest);
        if (!listObjectsResponse.Contents) {
            return [];
        }
        const predicate = (content: any) => content.Key;
        return listObjectsResponse.Contents.filter(predicate).map(predicate);
    } catch (err) {
        console.error(err);
        throw Error(`Error retrieving records from bucket with prefix ${prefix}`);
    }
};

export const getRecordFromBucket = async (bucketName: string, key: string): Promise<string> => {
    const s3Client = createS3Client();
    try {
        const getObjectRequest = new GetObjectCommand({ Bucket: bucketName, Key: key });
        const getObjectResponse = await s3Client.send(getObjectRequest);
        if (!getObjectResponse.Body) {
            throw new Error(`Error reading information about item in bucket`);
        }
        return await getObjectResponse.Body.transformToString();
    } catch (err) {
        console.error(err);
        throw Error(`Error retrieving record from bucket`);
    }
};

export const deleteObjectsInBucket = async (bucketName: string, prefix: string) => {
    const s3Client = createS3Client();
    try {
        const deleteObjectRequest = new DeleteObjectCommand({ Bucket: bucketName, Key: prefix });
        await s3Client.send(deleteObjectRequest);
    } catch (err) {
        console.error(err);
        throw Error(`Error deleting records from bucket`);
    }
};