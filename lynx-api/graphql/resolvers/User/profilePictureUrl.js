"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const s3_1 = require("../../aws/s3");
const s3_2 = require("../../aws/s3");
const profilePictureUrl = async (parent, args, context, info) => {
    if (await (0, s3_1.checkIfObjectInBucket)(s3_2.profilePictureBucketName, parent.id)) {
        console.log(`Found S3 profile picture for user ${parent.id}`);
        return `https://${s3_2.profilePictureBucketName}.s3.us-west-1.amazonaws.com/${parent.id}`;
    }
    else if (parent.profilePictureUrl) {
        return parent.profilePictureUrl;
    }
    else {
        return null;
    }
};
exports.default = profilePictureUrl;
