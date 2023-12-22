import { DeleteObjectCommand, GetObjectCommand } from "@aws-sdk/client-s3";
import { Upload } from "@aws-sdk/lib-storage";
import { Entry, Parse, ParseStream as IncompleteTypedParseStream } from "unzipper";

import { s3Client } from "../graphql/aws/s3";
import { SLOPES_UNZIPPED_BUCKET } from "../infrastructure/lib/infrastructure";

type ParseStream = IncompleteTypedParseStream & {
    [Symbol.asyncIterator]: () => AsyncIterableIterator<Entry>;
};

export async function handler(event: any, context: any) {
    for (const record of event.Records) {
        const bucket = decodeURIComponent(record.s3.bucket.name);
        const objectKey = decodeURIComponent(record.s3.object.key).replaceAll("+", " ");

        const getObjectRequest = new GetObjectCommand({ Bucket: bucket, Key: objectKey });
        const getObjectResponse = await s3Client.send(getObjectRequest);
        const objectBody = getObjectResponse.Body;
        if (!objectBody) {
            throw new Error(`No body found for object ${objectKey} in bucket ${bucket}`);
        }

        const outputStream = objectBody.pipe(Parse({ forceStream: true })) as ParseStream;
        for await (const entry of outputStream) {
            if (entry.path === "Metadata.xml") {
                await uploadAndDelete(bucket, objectKey, entry);
            } else {
                entry.autodrain();
            }
        }
    }
}

const uploadAndDelete = async (bucket: string, objectKey: string, entry: Entry) => {
    const targetFile = renameFileFunction(objectKey);
    const upload = new Upload({
        client: s3Client,
        params: { Bucket: SLOPES_UNZIPPED_BUCKET, Key: targetFile, Body: entry }
    });
    await upload.done();
    console.log(`File ${targetFile} uploaded to bucket ${SLOPES_UNZIPPED_BUCKET} successfully.`);

    const deleteObjectRequest = new DeleteObjectCommand({ Bucket: bucket, Key: objectKey });
    await s3Client.send(deleteObjectRequest);
    console.log("Zipped file deleted successfully.");
};

const renameFileFunction = (originalFileName: string) => {
    return `${originalFileName.split(".")[0]}.xml`;
};
