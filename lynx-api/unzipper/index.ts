import {
    DeleteObjectCommand,
    GetObjectCommand,
    PutObjectCommand,
    S3Client
} from "@aws-sdk/client-s3";
import { Readable } from "stream";
import { ParseOne } from "unzipper";

const targetBucket = "lynx-slopes-unzipped";

const renameFileFunction = (originalFileName: string) => {
    return `${originalFileName.split(".")[0]}.xml`;
};

const createS3Client = (): S3Client => {
    if (!process.env.AWS_REGION) throw new Error("AWS_REGION Is Not Defined");
    return new S3Client({ region: process.env.AWS_REGION });
};

export async function handler(event: any, context: any) {
    const s3Client = createS3Client();
    for (const record of event.Records) {
        const bucket = decodeURIComponent(record.s3.bucket.name);
        const fileName = decodeURIComponent(record.s3.object.key)
            .split("")
            .map((letter) => (letter === "+" ? " " : letter))
            .join("");

        const getObjectRequest = new GetObjectCommand({ Bucket: bucket, Key: fileName });
        const getObjectResponse = await s3Client.send(getObjectRequest);
        const fileStream = (getObjectResponse?.Body as Readable).pipe(
            ParseOne(/Metadata\.xml/, { forceStream: true })
        );

        const targetFile = renameFileFunction(fileName);
        const putObjectRequest = new PutObjectCommand({
            Bucket: targetBucket,
            Key: targetFile,
            Body: fileStream
        });
        await s3Client.send(putObjectRequest);
        console.log(`File ${targetFile} uploaded to bucket ${targetBucket} successfully.`);

        const deleteObjectRequest = new DeleteObjectCommand({ Bucket: bucket, Key: fileName });
        await s3Client.send(deleteObjectRequest);
        console.log("Zipped file deleted successfully.");
    }
}
