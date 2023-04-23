import { S3Client, ListObjectsCommand, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const createS3Client = (): S3Client => {
    if (!process.env.AWS_REGION) throw new Error("AWS_REGION Is Not Defined");
    return new S3Client({ region: process.env.AWS_REGION });
};

export const createSignedUploadUrl = async (bucketName: string, path: string) => {
    const s3Client = createS3Client();
    try {
        const command = new GetObjectCommand({ Bucket: bucketName, Key: path });
        return getSignedUrl(s3Client, command);
    } catch (err) {
        console.error(err);
        throw Error("Error creating url for file upload");
    }
};

export const getRecordsFromBucket = async (bucketName: string, path: string = "") => {
    const s3Client = createS3Client();
    try {
        const listObjectsRequest = new ListObjectsCommand({ Bucket: bucketName, Prefix: path });
        const listObjectsResponse = await s3Client.send(listObjectsRequest);
        if (!listObjectsResponse.Contents) {
            throw new Error("Error retrieving contents of bucket");
        }
        return await Promise.all(
            listObjectsResponse.Contents.map(async (content) => {
                const getObjectRequest = new GetObjectCommand({
                    Bucket: bucketName,
                    Key: content.Key
                });
                const getObjectResponse = await s3Client.send(getObjectRequest);
                if (!getObjectResponse.Body) {
                    throw new Error("Error retrieving contents of bucket");
                }
                return await getObjectResponse.Body.transformToString();
            })
        );
    } catch (err) {
        console.error(err);
        throw Error("Error retrieving contents of bucket");
    }
};
