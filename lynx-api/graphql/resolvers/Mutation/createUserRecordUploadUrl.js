"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const s3_1 = require("../../aws/s3");
const auth_1 = require("../../auth");
const createUserRecordUploadUrl = async (_, args, context, info) => {
    await (0, auth_1.checkIsLoggedInAndHasValidInvite)(context);
    console.log(`Creating UserRecord Upload URL For User ID ${context.userId}`);
    return await Promise.all(args.requestedPaths.map((requestedPath) => (0, s3_1.createSignedUploadUrl)(s3_1.fromRunRecordsBucket, `${context.userId}/${requestedPath}`)));
};
exports.default = createUserRecordUploadUrl;
