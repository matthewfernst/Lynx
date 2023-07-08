import { DateTime } from "luxon";

import { Context } from "../../index";
import { checkIsLoggedInAndHasValidInvite } from "../../auth";
import { DYNAMODB_TABLE_INVITES, putItem } from "../../aws/dynamodb";

const createInviteKey = async (_: any, args: any, context: Context, info: any): Promise<string> => {
    await checkIsLoggedInAndHasValidInvite(context);
    console.log(`Generating invite token for user with id ${context.userId}`);
    const inviteKey = Math.random().toString(10).substring(2, 8);
    const ttl = DateTime.now().toSeconds() + 60 * 60 * 24;
    await putItem(DYNAMODB_TABLE_INVITES, { id: inviteKey, ttl });
    return inviteKey;
};

export default createInviteKey;
