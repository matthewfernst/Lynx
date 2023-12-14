import { DateTime } from "luxon";

import { Context } from "../../index";
import { checkHasUserId, checkIsLoggedInAndHasValidInvite } from "../../auth";
import { INVITES_TABLE, putItem } from "../../aws/dynamodb";

const createInviteKey = async (_: any, args: any, context: Context, info: any): Promise<string> => {
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedInAndHasValidInvite(userId);
    console.log(`Generating invite token for user with id ${userId}`);
    const inviteKey = Math.random().toString(10).substring(2, 8);
    const ttl = DateTime.now().toSeconds() + 60 * 60 * 24;
    await putItem(INVITES_TABLE, { id: inviteKey, ttl });
    return inviteKey;
};

export default createInviteKey;
