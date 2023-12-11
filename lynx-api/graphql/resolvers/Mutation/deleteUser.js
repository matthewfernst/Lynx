"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const axios_1 = __importDefault(require("axios"));
const auth_1 = require("../../auth");
const dynamodb_1 = require("../../aws/dynamodb");
const s3_1 = require("../../aws/s3");
const deleteUser = async (_, args, context, info) => {
    await (0, auth_1.checkIsLoggedInAndHasValidInvite)(context);
    if (args.options?.tokensToInvalidate) {
        args.options.tokensToInvalidate.forEach(async (token) => await invalidateToken(token.type, token.token));
    }
    await (0, s3_1.deleteObjectsInBucket)(s3_1.profilePictureBucketName, context.userId);
    await (0, s3_1.deleteObjectsInBucket)(s3_1.toRunRecordsBucket, context.userId);
    const result = await (0, dynamodb_1.deleteItem)(dynamodb_1.DYNAMODB_TABLE_USERS, context.userId);
    return result.Attributes;
};
const invalidateToken = async (tokenType, token) => {
    switch (tokenType) {
        case "APPLE":
            return await invalidateAppleToken(token);
    }
};
const invalidateAppleToken = async (token) => {
    const invalidateTokenData = {
        client_id: process.env.APPLE_CLIENT_ID,
        client_secret: process.env.APPLE_CLIENT_SECRET,
        token: token
    };
    return await axios_1.default.post("https://appleid.apple.com/auth/revoke", invalidateTokenData);
};
exports.default = deleteUser;
