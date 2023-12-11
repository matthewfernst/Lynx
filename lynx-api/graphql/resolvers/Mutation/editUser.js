"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const auth_1 = require("../../auth");
const dynamodb_1 = require("../../aws/dynamodb");
const editUser = async (_, args, context, info) => {
    await (0, auth_1.checkIsLoggedInAndHasValidInvite)(context);
    for (const data of args.userData) {
        await (0, dynamodb_1.updateItem)(dynamodb_1.DYNAMODB_TABLE_USERS, context.userId, data.key, data.value);
    }
    const queryOutput = await (0, dynamodb_1.getItem)(dynamodb_1.DYNAMODB_TABLE_USERS, context.userId);
    return (0, dynamodb_1.getItemFromDynamoDBResult)(queryOutput);
};
exports.default = editUser;
