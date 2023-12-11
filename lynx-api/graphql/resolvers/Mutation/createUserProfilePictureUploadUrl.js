"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const s3_1 = require("../../aws/s3");
const auth_1 = require("../../auth");
const createUserProfilePictureUploadUrl = async (_, args, context, info) => {
    await (0, auth_1.checkIsLoggedInAndHasValidInvite)(context);
    console.log(`Creating Profile Picture Upload URL For User ID ${context.userId}`);
    return await (0, s3_1.createSignedUploadUrl)(s3_1.profilePictureBucketName, context.userId);
};
exports.default = createUserProfilePictureUploadUrl;
