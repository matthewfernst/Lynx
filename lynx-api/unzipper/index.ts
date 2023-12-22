import { DeleteObjectCommand, GetObjectCommand } from "@aws-sdk/client-s3";
import { Upload } from "@aws-sdk/lib-storage";
import { Entry, Parse, ParseStream as IncompleteTypedParseStream } from "unzipper";

import { s3Client } from "../graphql/aws/s3";

type ParseStream = IncompleteTypedParseStream & {
    [Symbol.asyncIterator]: () => AsyncIterableIterator<Entry>;
};

const renameFileFunction = (originalFileName: string) => {
    return `${originalFileName.split(".")[0]}.xml`;
};

export async function handler(event: any, context: any) {
    for (const record of event.Records) {
        const bucket = decodeURIComponent(record.s3.bucket.name);
        const objectKey = decodeURIComponent(record.s3.object.key).replaceAll("+", " ");

        const targetFile = renameFileFunction(objectKey);
        const getObjectRequest = new GetObjectCommand({ Bucket: bucket, Key: objectKey });
        const getObjectResponse = await s3Client.send(getObjectRequest);
        const objectBody = getObjectResponse.Body;
        if (!objectBody) {
            throw new Error(`No body found for object ${objectKey} in bucket ${bucket}`);
        }

        const outputStream = objectBody.pipe(Parse({ forceStream: true })) as ParseStream;
        for await (const entry of outputStream) {
            if (entry.type !== "File" && entry.path !== "Metadata.xml") {
                entry.autodrain();
            }
            const upload = new Upload({
                client: s3Client,
                params: { Bucket: targetBucket, Key: targetFile, Body: entry }
            });
            await upload.done();
            console.log(`File ${targetFile} uploaded to bucket ${targetBucket} successfully.`);

            const deleteObjectRequest = new DeleteObjectCommand({ Bucket: bucket, Key: objectKey });
            await s3Client.send(deleteObjectRequest);
            console.log("Zipped file deleted successfully.");
        }
    }
}
