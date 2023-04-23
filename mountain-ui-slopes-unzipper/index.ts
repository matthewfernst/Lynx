import { S3 } from "aws-sdk";
import { ParseOne } from "unzipper";

export const fromBucket = "mountain-ui-app-slopes-zipped";
export const targetBucket = "mountain-ui-app-slopes-unzipped";

export async function handler(event, context) {
    const s3Client = new S3({ region: "us-west-1" });

    for (const record of event.Records) {
        const bucket = decodeURIComponent(record.s3.bucket.name);
        const fileName = decodeURIComponent(record.s3.object.key)
            .split("")
            .map((letter) => (letter === "+" ? " " : letter))
            .join("");

        const fileStream = s3Client
            .getObject({ Bucket: bucket, Key: fileName })
            .createReadStream()
            .pipe(ParseOne("Metadata.xml", { forceStream: true }));

        const targetFile = `${fileName.split("/")[0]}/${fileName
            .split("/")[1]
            .split("-")[0]
            .trim()}.xml`;
        await s3Client
            .upload({ Bucket: targetBucket, Key: targetFile, Body: fileStream })
            .promise();

        console.log(`File ${targetFile} uploaded to bucket ${targetBucket} successfully.`);
    }

    return { statusCode: 200 };
}
