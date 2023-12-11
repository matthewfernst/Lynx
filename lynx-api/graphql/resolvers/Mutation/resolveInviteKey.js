"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const apollo_server_lambda_1 = require("apollo-server-lambda");
const auth_1 = require("../../auth");
const dynamodb_1 = require("../../aws/dynamodb");
const resolveInviteKey = async (_, args, context, info) => {
    await (0, auth_1.checkIsLoggedIn)(context);
    const queryOutput = await (0, dynamodb_1.getItem)(dynamodb_1.DYNAMODB_TABLE_INVITES, args.inviteKey);
    const inviteInfo = (await (0, dynamodb_1.getItemFromDynamoDBResult)(queryOutput));
    if (!inviteInfo && args.inviteKey !== process.env.ESCAPE_INVITE_HATCH) {
        throw new apollo_server_lambda_1.UserInputError("Invalid Invite Token Provided");
    }
    const updateOutput = await (0, dynamodb_1.updateItem)(dynamodb_1.DYNAMODB_TABLE_USERS, context.userId, "validatedInvite", true);
    await (0, dynamodb_1.deleteItem)(dynamodb_1.DYNAMODB_TABLE_INVITES, args.inviteKey);
    return (0, dynamodb_1.getItemFromDynamoDBResult)(updateOutput);
};
exports.default = resolveInviteKey;
