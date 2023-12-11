"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const luxon_1 = require("luxon");
const auth_1 = require("../../auth");
const dynamodb_1 = require("../../aws/dynamodb");
const createInviteKey = async (_, args, context, info) => {
    await (0, auth_1.checkIsLoggedInAndHasValidInvite)(context);
    console.log(`Generating invite token for user with id ${context.userId}`);
    const inviteKey = Math.random().toString(10).substring(2, 8);
    const ttl = luxon_1.DateTime.now().toSeconds() + 60 * 60 * 24;
    await (0, dynamodb_1.putItem)(dynamodb_1.DYNAMODB_TABLE_INVITES, { id: inviteKey, ttl });
    return inviteKey;
};
exports.default = createInviteKey;
