"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const apollo_server_lambda_1 = require("apollo-server-lambda");
const dynamodb_1 = require("../../aws/dynamodb");
const createUserOrSignIn_1 = require("./createUserOrSignIn");
const auth_1 = require("../../auth");
const s3_1 = require("../../aws/s3");
const combineOAuthAccounts = async (_, args, context, info) => {
    (0, auth_1.checkIsLoggedInAndHasValidInvite)(context);
    const { type, id, token } = args.combineWith;
    const idKey = (0, createUserOrSignIn_1.idKeyFromIdType)(type);
    const userQuery = await (0, dynamodb_1.getItemsByIndex)(dynamodb_1.DYNAMODB_TABLE_USERS, idKey, id);
    const otherUser = (0, dynamodb_1.getItemFromDynamoDBResult)(userQuery);
    if (!otherUser) {
        if (!token) {
            throw new apollo_server_lambda_1.UserInputError("User Does Not Exist and No Token Provided");
        }
        await (0, createUserOrSignIn_1.verifyToken)(type, id, token);
        return await updateUserAndReturnResult(context.userId, idKey, id);
    }
    await (0, dynamodb_1.deleteItem)(dynamodb_1.DYNAMODB_TABLE_USERS, otherUser.id);
    await (0, s3_1.deleteObjectsInBucket)(s3_1.profilePictureBucketName, otherUser.id);
    await (0, s3_1.deleteObjectsInBucket)(s3_1.toRunRecordsBucket, otherUser.id);
    return await updateUserAndReturnResult(context.userId, idKey, id);
};
const updateUserAndReturnResult = async (userId, idKey, id) => {
    await (0, dynamodb_1.updateItem)(dynamodb_1.DYNAMODB_TABLE_USERS, userId, idKey, id);
    const queryOutput = await (0, dynamodb_1.getItem)(dynamodb_1.DYNAMODB_TABLE_USERS, userId);
    return (0, dynamodb_1.getItemFromDynamoDBResult)(queryOutput);
};
exports.default = combineOAuthAccounts;
