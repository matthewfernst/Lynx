import { DeleteObjectCommand, GetObjectCommand } from "@aws-sdk/client-s3";
import { Upload } from "@aws-sdk/lib-storage";
import { S3Event } from "aws-lambda";
import { Entry, Parse, ParseStream as IncompleteTypedParseStream } from "unzipper";

import { checkIfObjectInBucket, s3Client } from "../graphql/aws/s3";
import { SLOPES_UNZIPPED_BUCKET } from "../infrastructure/stacks/lynxApiStack";
import { NodeJsRuntimeStreamingBlobPayloadOutputTypes } from "@smithy/types";

type ParseStream = IncompleteTypedParseStream & {
    [Symbol.asyncIterator]: () => AsyncIterableIterator<Entry>;
};

export async function handler(event: S3Event) {
    for (const record of event.Records) {
        const bucket = decodeURIComponent(record.s3.bucket.name);
        const objectKey = decodeURIComponent(record.s3.object.key).replaceAll("+", " ");

        const getObjectRequest = new GetObjectCommand({ Bucket: bucket, Key: objectKey });
        const getObjectResponse = await s3Client.send(getObjectRequest);
        const objectBody = getObjectResponse.Body as NodeJsRuntimeStreamingBlobPayloadOutputTypes;
        if (!objectBody) {
            throw new Error(`No body found for object ${objectKey} in bucket ${bucket}`);
        }

        const outputStream = objectBody.pipe(Parse({ forceStream: true })) as ParseStream;
        for await (const entry of outputStream) {
            if (entry.path === "Metadata.xml") {
                return await uploadAndDelete(bucket, objectKey, entry);
            } else {
                entry.autodrain();
            }
        }
    }
}

const uploadAndDelete = async (bucket: string, objectKey: string, entry: Entry) => {
    const targetFile = renameFileFunction(objectKey);
    const fileExists = await checkIfObjectInBucket(SLOPES_UNZIPPED_BUCKET, targetFile);
    if (!fileExists) {
        await new Upload({
            client: s3Client,
            params: { Bucket: SLOPES_UNZIPPED_BUCKET, Key: targetFile, Body: entry }
        }).done();
        console.info(
            `File ${targetFile} uploaded to bucket ${SLOPES_UNZIPPED_BUCKET} successfully.`
        );
    }

    const deleteObjectRequest = new DeleteObjectCommand({ Bucket: bucket, Key: objectKey });
    await s3Client.send(deleteObjectRequest);
    console.info("Zipped file deleted successfully.");
};

const renameFileFunction = (originalFileName: string) => {
    return `${originalFileName.split(".")[0]}.xml`;
};
