"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handler = void 0;
const aws_sdk_1 = require("aws-sdk");
const unzipper_1 = require("unzipper");
const targetBucket = "lynx-slopes-unzipped";
const renameFileFunction = (originalFileName) => {
    return `${originalFileName.split(".")[0]}.xml`;
};
async function handler(event, context) {
    const s3Client = new aws_sdk_1.S3({ region: "us-west-1" });
    for (const record of event.Records) {
        const bucket = decodeURIComponent(record.s3.bucket.name);
        const fileName = decodeURIComponent(record.s3.object.key)
            .split("")
            .map((letter) => (letter === "+" ? " " : letter))
            .join("");
        const fileStream = s3Client
            .getObject({ Bucket: bucket, Key: fileName })
            .createReadStream()
            .pipe((0, unzipper_1.ParseOne)(/Metadata\.xml/, { forceStream: true }));
        const targetFile = renameFileFunction(fileName);
        await s3Client
            .upload({ Bucket: targetBucket, Key: targetFile, Body: fileStream })
            .promise();
        console.log(`File ${targetFile} uploaded to bucket ${targetBucket} successfully.`);
        await s3Client.deleteObject({ Bucket: bucket, Key: fileName });
        console.log("Zipped file deleted successfully.");
    }
    return { statusCode: 200 };
}
exports.handler = handler;
