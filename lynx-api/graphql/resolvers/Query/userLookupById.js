"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const dynamodb_1 = require("../../aws/dynamodb");
const userLookupById = async (_, args, context, info) => {
    const queryOutput = await (0, dynamodb_1.getItem)(dynamodb_1.DYNAMODB_TABLE_USERS, args.id);
    return (0, dynamodb_1.getItemFromDynamoDBResult)(queryOutput);
};
exports.default = userLookupById;
